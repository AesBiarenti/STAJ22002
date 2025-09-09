from qdrant_client import QdrantClient
from qdrant_client.models import Distance, VectorParams, PointStruct, Filter, FieldCondition, MatchValue
import logging
from typing import List, Dict, Any, Optional
from config.settings import Config

logger = logging.getLogger(__name__)

class QdrantService:
    def __init__(self):
        self.client = QdrantClient(host=Config.QDRANT_URL.replace('http://', '').split(':')[0],
                                  port=int(Config.QDRANT_URL.split(':')[-1]))
        self.collection_name = Config.QDRANT_COLLECTION
        self.vector_size = Config.QDRANT_VECTOR_SIZE
        
    def create_collection(self) -> bool:
        """Qdrant collection oluştur"""
        try:
            self.client.create_collection(
                collection_name=self.collection_name,
                vectors_config=VectorParams(
                    size=self.vector_size,
                    distance=Distance.COSINE
                )
            )
            logger.info(f"✅ Qdrant collection '{self.collection_name}' oluşturuldu")
            return True
        except Exception as e:
            if "already exists" in str(e):
                logger.info(f"ℹ️ Collection '{self.collection_name}' zaten mevcut")
                return True
            logger.error(f"create_collection error: {e}")
            return False
    
    def list_employees(self) -> List[Dict[str, Any]]:
        """Tüm çalışanları (sayfalama ile) listele"""
        try:
            print('🔍 QdrantService: list_employees başlatılıyor...')
            all_points = []
            offset = None
            page_count = 0
            
            while True:
                page_count += 1
                print(f'🔍 QdrantService: Sayfa {page_count} alınıyor...')
                
                result, next_offset = self.client.scroll(
                collection_name=self.collection_name,
                    with_payload=True,
                    offset=offset
                )
                
                print(f'🔍 QdrantService: Sayfa {page_count} - {len(result)} kayıt alındı')
                all_points.extend(result)
                
                if not next_offset:
                    print(f'🔍 QdrantService: Tüm sayfalar alındı, toplam {len(all_points)} kayıt')
                    break
                offset = next_offset
            
            employees = [
                {
                    "id": point.id,
                    **point.payload
                }
                for point in all_points
            ]
            
            print(f'🔍 QdrantService: {len(employees)} çalışan döndürülüyor')
            return employees
            
        except Exception as e:
            print(f'❌ QdrantService: list_employees hatası: {e}')
            logger.error(f"list_employees error: {e}")
            raise Exception(f"Çalışan verileri alınamadı: {e}")
    
    def add_employee(self, employee_data: Dict[str, Any]) -> Dict[str, Any]:
        """Çalışan ekle"""
        try:
            import time
            point_id = int(time.time() * 1000)
            
            vector = employee_data.get('vector')
            if vector is None:
                # Qdrant koleksiyonunun vektör boyutuna göre örnek bir vektör oluştur
                vector = [0.0] * self.vector_size
            
            # Debug: Veriyi logla
            print(f"🔍 Qdrant'a ekleniyor: ID={point_id}, İsim={employee_data.get('isim', 'N/A')}")
            print(f"🔍 Vector boyutu: {len(vector)}")
            print(f"🔍 Payload boyutu: {len(str(employee_data))}")
            
            point = PointStruct(
                id=point_id,
                vector=vector,
                payload=employee_data
            )
            
            result = self.client.upsert(
                collection_name=self.collection_name,
                points=[point]
            )
            
            print(f"✅ Qdrant'a eklendi: {result}")
            
            return {"id": point_id, **employee_data}
        except Exception as e:
            logger.error(f"add_employee error: {e}")
            print(f"❌ Qdrant ekleme hatası: {e}")
            raise Exception(f"Çalışan eklenemedi: {e}")
    
    def update_employee(self, employee_id: int, employee_data: Dict[str, Any]) -> Dict[str, Any]:
        """Çalışan güncelle"""
        try:
            # Önce sil, sonra ekle
            self.delete_employee(employee_id)
            return self.add_employee(employee_data)
        except Exception as e:
            logger.error(f"update_employee error: {e}")
            raise Exception(f"Çalışan güncellenemedi: {e}")
    
    def delete_employee(self, employee_id: int) -> Dict[str, Any]:
        """Çalışan sil"""
        try:
            self.client.delete(
                collection_name=self.collection_name,
                points_selector=[employee_id]
            )
            return {"id": employee_id}
        except Exception as e:
            logger.error(f"delete_employee error: {e}")
            raise Exception(f"Çalışan silinemedi: {e}")
    
    def delete_all_employees(self):
        """Koleksiyondaki tüm çalışanları sil (koleksiyon sıfırla)"""
        try:
            self.client.delete_collection(self.collection_name)
            logger.info(f"Collection '{self.collection_name}' tamamen silindi. Tekrar oluşturuluyor...")
            self.create_collection()
        except Exception as e:
            logger.error(f"delete_all_employees error: {e}")
            raise Exception(f"Tüm çalışanlar silinemedi: {e}")
    
    def search_by_embedding(self, embedding: List[float], query: str, limit: int = 5) -> List[Dict[str, Any]]:
        """Gelişmiş semantic search - Web uygulaması yaklaşımı"""
        try:
            logger.info(f"🔍 Vektör arama başlıyor... Query: {query[:50]}...")
            
            search_result = self.client.search(
                collection_name=self.collection_name,
                query_vector=embedding,
                limit=limit,
                with_payload=True,
                score_threshold=0.1  # Daha düşük threshold
            )
            
            logger.info(f"📊 Ham arama sonucu: {len(search_result)} kayıt")
            
            if not search_result:
                logger.warning("Vektör arama sonuç vermedi, text-based search'e geçiliyor")
                return self.text_based_search(query)
            
            # Sonuçları formatla ve benzerlik skorunu ekle
            formatted_results = []
            for point in search_result:
                result = {
                    "id": point.id,
                    "score": point.score,
                    "payload": point.payload
                }
                formatted_results.append(result)
            
            # Benzerlik skoruna göre sırala (yüksek skor önce)
            formatted_results.sort(key=lambda x: x['score'], reverse=True)
            
            logger.info(f"✅ Vektör arama tamamlandı: {len(formatted_results)} sonuç")
            return formatted_results
            
        except Exception as e:
            logger.error(f"search_by_embedding error: {e}")
            logger.info("Fallback olarak text-based search kullanılıyor")
            return self.text_based_search(query)
    
    def text_based_search(self, query: str) -> List[Dict[str, Any]]:
        """Text-based search (fallback)"""
        try:
            all_employees = self.list_employees()
            query_lower = query.lower()
            
            filtered = [
                emp for emp in all_employees
                if emp.get('isim', '').lower().find(query_lower) != -1
            ]
            
            return filtered[:20] if filtered else all_employees[:20]
        except Exception as e:
            logger.error(f"text_based_search error: {e}")
            return []

# Singleton instance
qdrant_service = QdrantService() 