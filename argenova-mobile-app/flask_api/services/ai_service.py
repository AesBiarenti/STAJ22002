import requests
import logging
import numpy as np
from typing import Dict, Any, List
from config.settings import Config

logger = logging.getLogger(__name__)

class AIService:
    def __init__(self):
        self.base_url = Config.AI_SERVICE_URL
        self.embedding_model = getattr(Config, "AI_EMBEDDING_MODEL", "all-minilm")
        self.chat_model = getattr(Config, "AI_CHAT_MODEL", "llama3")
        self.timeout = Config.AI_TIMEOUT
        
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
                                        temperature: float = 0.2, 
                                        max_tokens: int = 500) -> Dict[str, Any]:
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
                        "num_predict": max_tokens
                    }
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
    
    def _format_messages_to_prompt(self, messages: List[Dict[str, str]]) -> str:
        """Chat messages'ı Ollama prompt formatına çevir"""
        formatted_parts = []
        
        for message in messages:
            role = message.get('role', 'user')
            content = message.get('content', '')
            
            if role == 'system':
                formatted_parts.append(f"<|system|>\n{content}\n<|/system|>")
            elif role == 'user':
                formatted_parts.append(f"<|user|>\n{content}\n<|/user|>")
            elif role == 'assistant':
                formatted_parts.append(f"<|assistant|>\n{content}\n<|/assistant|>")
        
        # Son assistant yanıtı için boş alan ekle
        formatted_parts.append("<|assistant|>\n")
        
        return "\n".join(formatted_parts)
    
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