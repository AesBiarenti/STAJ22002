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
        
        # 2. Smart Query Detection - Hızlı analiz için
        query_lower = chat_request.question.lower()
        needs_all_data = any(keyword in query_lower for keyword in [
            'en çok', 'en fazla', 'en yüksek', 'sırala', 'listele', 'tüm', 'hepsi', 
            'karşılaştır', 'ortalama', 'toplam', 'kimler', 'hangi', 'kaç kişi'
        ])
        
        context = ''
        context_used = False
        relevant_sources = []
        
        if needs_all_data:
            # TÜM VERİLERİ AL - DOĞRU ANALİZ İÇİN
            logger.info("🚀 Tüm veriler alınıyor (doğru analiz için)...")
            try:
                all_employees = qdrant_service.list_employees()
                logger.info(f"📊 Toplam çalışan sayısı: {len(all_employees)}")
                
                # Mesai saatlerine göre sırala
                employee_hours = []
                for emp in all_employees:
                    toplam_mesai_list = emp.get('toplam_mesai', [])
                    toplam_saat = sum(toplam_mesai_list) if toplam_mesai_list else 0
                    employee_hours.append({
                        'isim': emp.get('isim', 'Bilinmeyen'),
                        'toplam_saat': toplam_saat,
                        'hafta_sayisi': len(toplam_mesai_list)
                    })
                
                # Yüksekten düşüğe sırala
                employee_hours.sort(key=lambda x: x['toplam_saat'], reverse=True)
                
                # Context oluştur - EN FAZLA 10 KİŞİ
                context_parts = []
                for i, emp in enumerate(employee_hours[:10]):
                    context_parts.append(f"{i+1}. {emp['isim']}: {emp['toplam_saat']} saat")
                    relevant_sources.append({
                        'text': f"{emp['isim']}: {emp['toplam_saat']} saat",
                        'score': 100 - (i * 5)  # Sıralama skorları
                    })
                
                context = "MESAI SIRALAMASI (En çoktan en aza):\n" + '\n'.join(context_parts)
                context_used = True
                logger.info(f"✅ Tam veri analizi hazır: {len(employee_hours)} çalışan")
                
            except Exception as e:
                logger.error(f"Tüm veri alma hatası: {e}")
                # Fallback to vector search
                context_used = False
        
        if not context_used:
            # Vektör arama yap (eski metod)
            logger.info("🔍 Vektör arama başlıyor...")
            search_results = qdrant_service.search_by_embedding(embedding, chat_request.question, limit=8)
            
            if search_results and len(search_results) > 0:
                relevant_results = [
                    result for result in search_results 
                    if result.get('score', 0) > 0.05  # Daha düşük threshold
                ][:5]  # En fazla 5 sonuç
                
                if relevant_results:
                    context_parts = []
                    for result in relevant_results:
                        payload = result.get('payload', {})
                        if payload.get('isim'):
                            toplam_mesai_list = payload.get('toplam_mesai', [])
                            toplam_saat = sum(toplam_mesai_list) if toplam_mesai_list else 0
                            
                            text = f"Çalışan: {payload['isim']}, Toplam Mesai: {toplam_saat} saat"
                            context_parts.append(text)
                            relevant_sources.append({
                                'text': f"{payload['isim']}: {toplam_saat} saat",
                                'score': round(result.get('score', 0) * 100)
                            })
                    
                    context = '\n'.join(context_parts)
                    context_used = True
                    logger.info(f"Context oluşturuldu: {len(context_parts)} kaynak")
        
        # 4. HIZLI System prompt hazırla
        if context_used:
            system_prompt = f"""MESAI VERİSİ:
{context}

GÖREV: Sadece verilen mesai verilerini kullanarak KISA VE NET Türkçe yanıt ver.

KURALLAR:
- SADECE TÜRKÇE YAZ
- MAKSIMUM 1-2 CÜMLE
- VERİDEKİ SIRALAMA DOĞRU
- İSİM + SAAT formatı kullan

HIZLI YANIT VER!"""
        else:
            # Context yoksa basit bir prompt kullan
            system_prompt = """SEN BİR TÜRK MESAI UZMANISIIN! SADECE TÜRKÇE YANIT VER!

Mesai analizi hakkında sorulara kısa ve net Türkçe cevaplar ver.

KURALLAR:
- SADECE TÜRKÇE YAZ
- MAKSIMUM 2 CÜMLE
- GENEL MESAI BİLGİLERİ VER
- İNGİLİZCE YAZMA

YANIT DİLİ: TÜRKÇE"""
        
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
        
        # 6. ULTRA HIZLI AI yanıtı al
        completion_result = ai_service.generate_completion_with_messages(
            messages,
            temperature=0.0,   # Deterministik yanıtlar (çok hızlı)
            max_tokens=50      # Çok kısa yanıtlar (maksimum hız)
        )
        
        if not completion_result["success"]:
            logger.error(f"AI yanıtı alınamadı: {completion_result.get('error', 'Unknown error')}")
            
            # DIRECT ANALYSIS - AI olmadan hızlı yanıt
            if context_used and relevant_sources:
                # En çok mesai yapan sorusu için direct yanıt
                if 'en çok' in chat_request.question.lower() or 'en fazla' in chat_request.question.lower():
                    if relevant_sources:
                        top_employee = relevant_sources[0]
                        direct_answer = f"En çok mesai yapan çalışan {top_employee['text']}."
                        
                        return jsonify({
                            "answer": direct_answer,
                            "success": True,
                            "context_used": True,
                            "sources": relevant_sources[:3],
                            "direct_analysis": True
                        }), 200
                
                # Genel fallback
                fallback_answer = f"Veriler bulundu: {', '.join([src['text'] for src in relevant_sources[:3]])}"
                
                return jsonify({
                    "answer": fallback_answer,
                    "success": True,
                    "context_used": True,
                    "sources": relevant_sources,
                    "fallback": True
                }), 200
            
            return jsonify({
                "answer": "AI servisi geçici olarak yanıt veremiyor. Lütfen birkaç saniye sonra tekrar deneyin.",
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