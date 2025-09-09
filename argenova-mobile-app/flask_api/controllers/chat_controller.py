from flask import Blueprint, request, jsonify
from services.ai_service import ai_service
from services.qdrant_service import qdrant_service
from models.employee import ChatRequest, ChatResponse, EmbeddingRequest, EmbeddingResponse, ContextRequest, ContextResponse
import logging
import json
import re
from datetime import datetime

logger = logging.getLogger(__name__)

chat_bp = Blueprint('chat', __name__)

@chat_bp.route('/chat', methods=['POST'])
def chat():
    """Gelişmiş chat completion endpoint - Web uygulaması yaklaşımı"""
    try:
        data = request.get_json()
        chat_request = ChatRequest(**data)

        # Chat history'yi al (varsa)
        history = data.get('history', [])
        
        logger.info(f"Chat isteği: {chat_request.question}")

        # 1. Kullanıcı mesajından embedding oluştur
        embedding_result = ai_service.generate_embedding(chat_request.question)
        if not embedding_result["success"]:
            logger.error("Embedding oluşturulamadı")
            return jsonify({
                "answer": "Üzgünüm, mesajınızı işleyemedim. Lütfen tekrar deneyin.",
                "success": False,
                "error": "EMBEDDING_FAILED"
            }), 500
        
        embedding = embedding_result["embedding"]
        
        # 2. Vektör veritabanında arama yap
        logger.info("🔍 Vektör arama başlıyor...")
        search_results = qdrant_service.search_by_embedding(embedding, chat_request.question, limit=5)
        
        logger.info(f"📊 Arama sonucu sayısı: {len(search_results) if search_results else 0}")
        
        # 3. Context oluştur - benzerlik skoruna göre filtrele
        context = ''
        context_used = False
        relevant_sources = []
        
        if search_results and len(search_results) > 0:
            # Debug: Skorları logla
            for i, result in enumerate(search_results):
                logger.info(f"Sonuç {i+1}: Score={result.get('score', 0)}, Payload={result.get('payload', {}).get('isim', 'N/A')}")
            
            # Benzerlik skoruna göre filtrele (0.1 threshold - daha düşük)
            relevant_results = [
                result for result in search_results 
                if result.get('score', 0) > 0.1
            ][:3]  # En fazla 3 sonuç kullan
            
            if relevant_results:
                context_parts = []
                for result in relevant_results:
                    payload = result.get('payload', {})
                    # Çalışan verilerini text formatına çevir (chat.post.ts yaklaşımı)
                    if payload.get('isim'):
                        # Toplam mesai saatlerini hesapla
                        toplam_mesai_list = payload.get('toplam_mesai', [])
                        toplam_saat = sum(toplam_mesai_list) if toplam_mesai_list else 0
                        
                        # Günlük mesai detaylarını formatla
                        gunluk_mesai_list = payload.get('gunluk_mesai', [])
                        gunluk_detay = ""
                        if gunluk_mesai_list and len(gunluk_mesai_list) > 0:
                            son_hafta = gunluk_mesai_list[-1]  # Son haftanın verisi
                            gunluk_detay = f"Pazartesi: {son_hafta.get('pazartesi', 0)}h, Salı: {son_hafta.get('sali', 0)}h, Çarşamba: {son_hafta.get('carsamba', 0)}h, Perşembe: {son_hafta.get('persembe', 0)}h, Cuma: {son_hafta.get('cuma', 0)}h"
                        
                        text = f"Çalışan: {payload['isim']}, Toplam Mesai: {toplam_saat} saat, Günlük Mesai: {gunluk_detay}"
                        context_parts.append(text)
                        relevant_sources.append({
                            'text': f"{payload['isim']}: {toplam_saat} saat",
                            'score': round(result.get('score', 0) * 100)
                        })
                
                context = '\n\n'.join(context_parts)
                context_used = True
                logger.info(f"Context oluşturuldu: {len(context_parts)} kaynak")
                logger.info(f"Context içeriği: {context[:200]}...")
        
        # 4. System prompt hazırla
        if context_used:
            system_prompt = f"""Sen gelişmiş bir mesai analiz asistanısın. Aşağıdaki güvenilir çalışan verilerini kullanarak kapsamlı analizler yap:

{context}

YETENEKLERİN:
1. **Çalışan Raporları**: Tüm çalışanlar hakkında detaylı raporlar oluştur
2. **Mesai Analizi**: Günlük, haftalık, aylık mesai saatlerini analiz et
3. **Sıralama ve Filtreleme**: Çalışanları mesai saatlerine göre sırala
4. **İstatistiksel Analiz**: Ortalama, en yüksek, en düşük mesai saatlerini hesapla
5. **Karşılaştırma**: Çalışanları birbirleriyle karşılaştır
6. **Trend Analizi**: Mesai trendlerini ve değişimleri analiz et
7. **Öneriler**: Mesai optimizasyonu için öneriler sun

DETAYLI TALİMATLAR:
- Cevabını mutlaka Türkçe ver
- Sadece verilen bilgileri kullan, uydurma yapma
- KISA VE NET yanıtlar ver (maksimum 3-4 cümle)
- Sayısal verileri net göster (saat, yüzde)
- Sıralama yaparken sadece isim ve mesai saati ver
- Gereksiz açıklamalar yapma
- Eğer bilgi yoksa "Bu bilgi mevcut verilerde bulunmuyor" de
- Doğal ve anlaşılır dil kullan

ÖRNEK SORULAR VE YANITLAR:
- "Tüm çalışanları mesai saatlerine göre sırala" → "Ahmet: 45 saat, Mehmet: 42 saat, Ayşe: 40 saat"
- "En fazla mesai yapan 5 çalışanı göster" → "1. Ahmet (45h), 2. Mehmet (42h), 3. Ayşe (40h)"
- "Ortalama mesai saatini hesapla" → "Ortalama: 38.5 saat"
- "Mesai saatleri 40'ın üzerinde olanları bul" → "Ahmet (45h), Mehmet (42h)" """
        else:
            system_prompt = """Sen gelişmiş bir mesai analiz asistanısın. Mesai saatleri, çalışan verileri ve iş kuralları hakkında kapsamlı analizler yapabilirsin.

YETENEKLERİN:
1. **Genel Mesai Analizi**: Standart mesai kuralları ve hesaplamaları
2. **İstatistiksel Bilgiler**: Ortalama mesai, fazla mesai hesaplamaları
3. **Yasal Bilgiler**: İş kanunu ve mesai yönetmelikleri
4. **Öneriler**: Mesai optimizasyonu ve verimlilik artırma
5. **Raporlama**: Farklı rapor formatları ve analiz yöntemleri

DETAYLI TALİMATLAR:
- Cevabını mutlaka Türkçe ver
- KISA VE NET yanıtlar ver (maksimum 2-3 cümle)
- Eğer kesin bilgi yoksa, bunu belirt
- Doğal ve anlaşılır dil kullan
- Gereksiz açıklamalar yapma"""
        
        # 5. Chat mesajlarını hazırla
        messages = [
            {
                "role": "system",
                "content": system_prompt
            }
        ]
        
        # Chat history'yi ekle (son 5 mesaj)
        for msg in history[-5:]:
            if msg.get('role') in ['user', 'assistant']:
                messages.append({
                    "role": msg['role'],
                    "content": msg.get('content', '')
                })
        
        # Kullanıcı mesajını ekle
        messages.append({
            "role": "user",
            "content": chat_request.question
        })
        
        logger.info(f"Chat mesajları hazırlandı: {len(messages)} mesaj")
        
        # 6. AI yanıtı al
        completion_result = ai_service.generate_completion_with_messages(
            messages,
            temperature=0.2,  # Daha tutarlı yanıtlar için
            max_tokens=500    # Kısa yanıtlar için
        )
        
        if not completion_result["success"]:
            logger.error("AI yanıtı alınamadı")
            return jsonify({
                "answer": "Üzgünüm, şu anda yanıt veremiyorum. Lütfen daha sonra tekrar deneyin.",
                "success": False,
                "error": "AI_RESPONSE_FAILED"
            }), 500
        
        ai_response = completion_result["answer"]
        
        # 7. Log'u kaydet
        try:
            log_data = {
                "message": chat_request.question,
                "response": ai_response,
                "timestamp": str(datetime.now()),
                "context_used": context_used,
                "context_length": len(context),
                "sources_count": len(relevant_sources)
            }
            
            # Log dosyasına kaydet
            with open("logs/chat_logs.json", "a", encoding="utf-8") as f:
                f.write(json.dumps(log_data, ensure_ascii=False) + "\n")
                
        except Exception as log_error:
            logger.warning(f"Log kaydedilemedi: {log_error}")
        
        # 8. Yanıtı döndür
        response_data = {
            "answer": ai_response,
            "success": True,
            "context_used": context_used,
            "context_info": {
                "sources_count": len(relevant_sources),
                "context_length": len(context)
            }
        }
        
        if relevant_sources:
            response_data["sources"] = relevant_sources
        
        logger.info(f"Chat yanıtı başarılı: {len(ai_response)} karakter")

        return jsonify(response_data), 200
        
    except Exception as e:
        logger.error(f"Chat Controller Error: {e}")
        return jsonify({
            "answer": "Bir hata oluştu. Lütfen tekrar deneyin.",
            "success": False,
            "error": str(e)
        }), 500

@chat_bp.route('/chat/context', methods=['POST'])
def get_context():
    """Context endpoint (semantic search)"""
    try:
        data = request.get_json()
        context_request = ContextRequest(**data)
        
        context = qdrant_service.search_by_embedding(
            context_request.embedding, 
            context_request.query
        )
        
        response = ContextResponse(context=context)
        return jsonify(response.dict()), 200
        
    except Exception as e:
        logger.error(f"Context Controller Error: {e}")
        
        # Hata durumunda tüm verileri döndür
        try:
            all_employees = qdrant_service.list_employees()
            return jsonify({
                "context": all_employees,
                "success": False,
                "error": "FALLBACK_TO_ALL_DATA"
            }), 200
        except Exception as fallback_err:
            return jsonify({
                "context": [],
                "success": False,
                "error": str(e)
            }), 500

@chat_bp.route('/embedding', methods=['POST'])
def generate_embedding():
    """Embedding endpoint"""
    try:
        data = request.get_json()
        embedding_request = EmbeddingRequest(**data)
        
        result = ai_service.generate_embedding(embedding_request.text)
        
        response = EmbeddingResponse(
            embedding=result["embedding"],
            success=result["success"],
            error=result.get("error")
        )
        
        return jsonify(response.dict()), 200
        
    except Exception as e:
        logger.error(f"Embedding Controller Error: {e}")
        
        # Fallback embedding
        import numpy as np
        fallback_embedding = list(np.random.random(384))
        
        return jsonify({
            "embedding": fallback_embedding,
            "success": False,
            "error": "EMBEDDING_FALLBACK"
        }), 200 