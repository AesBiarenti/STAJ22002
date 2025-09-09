export class QdrantClient {
  private baseUrl: string
  private collectionName = 'ai_vectors'
  private vectorSize = 384 // all-minilm embedding boyutu

  constructor(baseUrl: string) {
    this.baseUrl = baseUrl
  }

  // String ID'yi sayısal ID'ye çevir
  private stringToId(str: string): number {
    let hash = 0
    for (let i = 0; i < str.length; i++) {
      const char = str.charCodeAt(i)
      hash = (hash << 5) - hash + char
      hash = hash & hash
    }
    return Math.abs(hash)
  }

  async createCollection() {
    try {
      // Önce koleksiyonun mevcut olup olmadığını kontrol et
      try {
        const collectionInfo = await this.getCollectionInfo()
        
        if (collectionInfo) {
          if (collectionInfo.config?.params?.vectors?.size) {
            const currentVectorSize = collectionInfo.config.params.vectors.size
            if (currentVectorSize !== this.vectorSize) {
              console.log(`⚠️ Koleksiyon vector boyutu uyumsuz: ${currentVectorSize} vs ${this.vectorSize}`)
              console.log('❌ Otomatik silme yapılmadı! Lütfen koleksiyonu manuel olarak silin ve tekrar başlatın.')
              return false
            } else {
              console.log('ℹ️ Qdrant koleksiyonu zaten mevcut:', this.collectionName)
              return true
            }
          } else {
            console.log('⚠️ Qdrant koleksiyonunda vector boyutu bilgisi bulunamadı, mevcut koleksiyon korunuyor...')
            return true
          }
        }
      } catch (error: any) {
        if (error.status === 404) {
          console.log('Koleksiyon mevcut değil, oluşturuluyor...')
        } else {
          throw error
        }
      }

      const response = await $fetch(`${this.baseUrl}/collections/${this.collectionName}`, {
        method: 'PUT',
        body: {
          vectors: {
            size: this.vectorSize,
            distance: 'Cosine'
          }
        }
      })
      console.log('✅ Qdrant koleksiyonu oluşturuldu:', this.collectionName, `(vector size: ${this.vectorSize})`)
      return response
    } catch (error: any) {
      if (error.status === 409) {
        console.log('Koleksiyon zaten mevcut')
        return true
      }
      console.error('❌ Qdrant koleksiyonu oluşturulamadı:', error.message)
      return false
    }
  }

  async addVector(id: string, vector: number[], payload: any) {
    try {
      const numericId = this.stringToId(id)
      const finalPayload = payload || { text: id }
      const response = await $fetch(`${this.baseUrl}/collections/${this.collectionName}/points`, {
        method: 'PUT',
        body: {
          points: [{
            id: numericId,
            vector,
            payload: finalPayload
          }]
        }
      })
      return true
    } catch (error: any) {
      return false
    }
  }

  async searchVector(vector: number[], limit: number = 5, filter?: any) {
    const body: any = {
      vector,
      limit,
      with_payload: true
    }
    if (filter) body.filter = filter
    const response = await $fetch(`${this.baseUrl}/collections/${this.collectionName}/points/search`, {
      method: 'POST',
      body
    })
    return response
  }

  async getCollectionInfo() {
    const response = await $fetch(`${this.baseUrl}/collections/${this.collectionName}`)
    return response
  }

  async getAllVectors(limit: number = 100) {
    const response = await $fetch(`${this.baseUrl}/collections/${this.collectionName}/points?limit=${limit}&with_payload=true`)
    return response
  }

  async clearCollection() {
    const response = await $fetch(`${this.baseUrl}/collections/${this.collectionName}/points`, {
      method: 'DELETE',
      body: {
        points: {
          all: true
        }
      }
    })
    return response
  }

  async scrollPoints(filter: any, limit: number = 100) {
    const response = await $fetch(`${this.baseUrl}/collections/${this.collectionName}/points/scroll`, {
      method: 'POST',
      body: {
        filter,
        limit,
        with_payload: true
      }
    })
    return response
  }
} 