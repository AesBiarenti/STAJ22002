from pydantic import BaseModel, Field
from typing import Optional, List, Dict
from datetime import datetime

class EmployeeBase(BaseModel):
    isim: str = Field(..., description="Çalışan adı")
    toplam_mesai: List[int] = Field(..., description="Toplam mesai saatleri listesi")
    tarih_araligi: List[str] = Field(..., description="Tarih aralıkları listesi")
    gunluk_mesai: List[Dict[str, int]] = Field(..., description="Haftanın günlerine göre mesai saatleri listesi")

class EmployeeCreate(EmployeeBase):
    pass

class EmployeeUpdate(BaseModel):
    isim: Optional[str] = None
    toplam_mesai: Optional[List[int]] = None
    tarih_araligi: Optional[List[str]] = None
    gunluk_mesai: Optional[List[Dict[str, int]]] = None

class EmployeeResponse(EmployeeBase):
    id: int
    created_at: Optional[datetime] = None
    
    class Config:
        from_attributes = True

class ChatRequest(BaseModel):
    question: str = Field(..., description="Kullanıcı sorusu")

class ChatResponse(BaseModel):
    answer: str
    success: bool = True
    error: Optional[str] = None

class EmbeddingRequest(BaseModel):
    text: str = Field(..., description="Embedding oluşturulacak metin")

class EmbeddingResponse(BaseModel):
    embedding: List[float]
    success: bool = True
    error: Optional[str] = None

class ContextRequest(BaseModel):
    embedding: List[float] = Field(..., description="Arama vektörü")
    query: str = Field(..., description="Arama sorgusu")

class ContextResponse(BaseModel):
    context: List[dict]
    success: bool = True
    error: Optional[str] = None 