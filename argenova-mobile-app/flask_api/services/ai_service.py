import requests
import logging
import numpy as np
from typing import Dict, Any, List
from config.settings import Config
import re

logger = logging.getLogger(__name__)

class AIService:
    def __init__(self):
        self.base_url = Config.AI_SERVICE_URL
        self.embedding_model = getattr(Config, "AI_EMBEDDING_MODEL", "all-minilm")
        self.chat_model = getattr(Config, "AI_CHAT_MODEL", "llama3")
        self.timeout = Config.AI_TIMEOUT
        
    def _is_turkish_response(self, text: str) -> bool:
        """Yanıtın Türkçe olup olmadığını kontrol et"""
        if not text or len(text.strip()) < 5:
            return False
            
        # Türkçe karakterler ve kelimeler
        turkish_chars = ['ç', 'ğ', 'ı', 'ö', 'ş', 'ü', 'Ç', 'Ğ', 'İ', 'Ö', 'Ş', 'Ü']
        turkish_words = ['bir', 'bu', 'şu', 'o', 've', 'ile', 'için', 'kadar', 'çok', 'az', 'çalışan', 'mesai', 'saat']
        
        # İngilizce yaygın kelimeler
        english_words = ['the', 'and', 'or', 'but', 'is', 'are', 'was', 'were', 'have', 'has', 'will', 'would', 'employee', 'work', 'hour']
        
        text_lower = text.lower()
        
        # Türkçe karakter varlığı kontrol et
        has_turkish_chars = any(char in text for char in turkish_chars)
        
        # Türkçe kelime sayısı
        turkish_word_count = sum(1 for word in turkish_words if word in text_lower)
        
        # İngilizce kelime sayısı
        english_word_count = sum(1 for word in english_words if word in text_lower)
        
        # Türkçe olma kriteri
        if has_turkish_chars:
            return True
        if turkish_word_count > english_word_count:
            return True
        if turkish_word_count >= 2 and english_word_count == 0:
            return True
            
        return False
    
    def _force_turkish_response(self, original_response: str, retry_count: int = 0) -> str:
        """Türkçe olmayan yanıtları düzelt"""
        if self._is_turkish_response(original_response):
            return original_response
            
        if retry_count >= 2:  # Maksimum 2 deneme
            return "Anlık veri analizi yapılamadı. Lütfen tekrar deneyin."
            
        # Türkçe zorlaması ile tekrar dene
        turkish_prompt = f"""Aşağıdaki metni Türkçe'ye çevir ve kısa tut:

{original_response}

KURALLAR:
- SADECE TÜRKÇE YAZ
- KISA TUT (MAX 2 CÜMLE)
- MESAI VERİSİ HAKKINDA YANIT VER"""

        try:
            response = requests.post(
                f"{self.base_url}/api/generate",
                json={
                    "model": self.chat_model,
                    "prompt": turkish_prompt,
                    "stream": False,
                    "options": {
                        "temperature": 0.1,
                        "num_predict": 100,
                        "stop": ["English:", "In English", "\n\n"]
                    }
                },
                timeout=30  # Kısa timeout
            )
            
            if response.status_code == 200:
                data = response.json()
                corrected = data.get('response', '').strip()
                if corrected and self._is_turkish_response(corrected):
                    return corrected
        except Exception as e:
            logger.warning(f"Turkish correction failed: {e}")
            
        return "Veri analizi tamamlandı ancak sonuç gösterilemedi."
    
    def generate_completion(self, prompt: str) -> Dict[str, Any]:
        """Basit chat completion"""
        try:
            response = requests.post(
                f"{self.base_url}/api/generate",
                json={
                    "model": self.chat_model,
                    "prompt": prompt,
                    "stream": False
                },
                timeout=self.timeout
            )
            response.raise_for_status()
            
            data = response.json()
            answer = (
                data.get('response') or data.get('text') or str(data)
            )
            
            return {
                "answer": answer,
                "success": True
            }
        except requests.exceptions.ConnectionError:
            logger.error("AI Service connection failed")
            return {
                "answer": "Üzgünüm, AI servisi şu anda kullanılamıyor. Lütfen daha sonra tekrar deneyin.",
                "success": False,
                "error": "AI_SERVICE_UNAVAILABLE"
            }
        except requests.exceptions.Timeout:
            logger.error("AI Service timeout")
            return {
                "answer": "AI servisi yanıt vermiyor. Lütfen daha sonra tekrar deneyin.",
                "success": False,
                "error": "AI_SERVICE_TIMEOUT"
            }
        except Exception as e:
            logger.error(f"AI Service Error: {e}")
            return {
                "answer": f"AI servisinde hata: {e}",
                "success": False,
                "error": str(e)
            }
    
    def generate_completion_with_messages(self, messages: List[Dict[str, str]], 
                                        temperature: float = 0.0, 
                                        max_tokens: int = 50) -> Dict[str, Any]:
        """Gelişmiş chat completion - Chat history desteği"""
        try:
            # Messages'ı Ollama formatına çevir
            prompt = self._format_messages_to_prompt(messages)
            
            response = requests.post(
                f"{self.base_url}/api/generate",
                json={
                    "model": self.chat_model,
                    "prompt": prompt,
                    "stream": False,
                    "options": {
                        "temperature": temperature,
                        "num_predict": max_tokens,
                        "top_p": 0.5,
                        "top_k": 10,
                        "repeat_penalty": 1.0,
                        "stop": ["<|user|>", "<|assistant|>", "\n\n", "User:", "Assistant:", "."],
                        "seed": 42
                    }
                },
                timeout=self.timeout
            )
            response.raise_for_status()
            
            data = response.json()
            raw_answer = (
                data.get('response') or data.get('text') or str(data)
            )
            
            # ✅ TÜRKÇE KONTROLÜ VE DÜZELTİM UYGULAması
            final_answer = self._force_turkish_response(raw_answer.strip())
            
            return {
                "answer": final_answer,
                "success": True,
                "language_corrected": raw_answer != final_answer
            }
        except requests.exceptions.ConnectionError:
            logger.error("AI Service connection failed")
            return {
                "answer": "AI servisi bağlantısında sorun var. Lütfen tekrar deneyin.",
                "success": False,
                "error": "AI_SERVICE_UNAVAILABLE"
            }
        except requests.exceptions.Timeout:
            logger.error("AI Service timeout")
            return {
                "answer": "AI servisi yanıt süresi aşıldı. Lütfen daha kısa soru sorun.",
                "success": False,
                "error": "AI_SERVICE_TIMEOUT"
            }
        except Exception as e:
            logger.error(f"AI Service Error: {e}")
            return {
                "answer": "AI servisinde beklenmeyen hata oluştu. Lütfen tekrar deneyin.",
                "success": False,
                "error": str(e)
            }
    
    def _format_messages_to_prompt(self, messages: List[Dict[str, str]]) -> str:
        """Chat messages'ı Ollama prompt formatına çevir - Türkçe optimized"""
        formatted_parts = []
        
        for message in messages:
            role = message.get('role', 'user')
            content = message.get('content', '')
            
            if role == 'system':
                formatted_parts.append(f"System: {content}")
            elif role == 'user':
                formatted_parts.append(f"Kullanıcı: {content}")
            elif role == 'assistant':
                formatted_parts.append(f"Asistan: {content}")
        
        # Son Türkçe assistant prompt
        formatted_parts.append("Asistan (Türkçe yanıt ver):")
        
        return "\n\n".join(formatted_parts)
    
    def generate_embedding(self, text: str) -> Dict[str, Any]:
        """Embedding oluştur"""
        try:
            response = requests.post(
                f"{self.base_url}/api/embeddings",
                json={
                    "model": self.embedding_model,
                    "prompt": text  # Ollama için 'prompt' kullanılmalı!
                },
                timeout=self.timeout
            )
            response.raise_for_status()
            
            data = response.json()
            embedding = data.get('embedding', [])
            
            # Embedding boyutunu kontrol et
            if len(embedding) != Config.QDRANT_VECTOR_SIZE:
                logger.warning(f"Embedding boyutu beklenenden farklı: {len(embedding)}")
            
            return {
                "embedding": embedding,
                "success": True
            }
        except requests.exceptions.ConnectionError:
            logger.error("AI Service connection failed for embedding")
            return self._generate_fallback_embedding("EMBEDDING_CONNECTION_ERROR")
        except requests.exceptions.Timeout:
            logger.error("AI Service timeout for embedding")
            return self._generate_fallback_embedding("EMBEDDING_TIMEOUT")
        except Exception as e:
            logger.error(f"Embedding API Error: {e}")
            return self._generate_fallback_embedding("EMBEDDING_ERROR")
    
    def _generate_fallback_embedding(self, error_type: str) -> Dict[str, Any]:
        """Fallback embedding oluştur"""
        # Basit embedding simülasyonu
        fallback_embedding = list(np.random.random(Config.QDRANT_VECTOR_SIZE))
        
        return {
            "embedding": fallback_embedding,
            "success": False,
            "error": error_type
        }

# Singleton instance
ai_service = AIService() 