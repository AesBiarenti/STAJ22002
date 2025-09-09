export class QdrantClient {
  private baseUrl: string
  private collectionName = 'ai_vectors'

  constructor(baseUrl: string) {
    this.baseUrl = baseUrl
  }

  async createCollection() {
    try {
      // Önce koleksiyonun var olup olmadığını kontrol et
      try {
        await this.getCollectionInfo()
        console.log('✅ Koleksiyon zaten mevcut:', this.collectionName)
        return true
      } catch (error: any) {
        if (error.status === 404) {
          console.log('📝 Koleksiyon bulunamadı, oluşturuluyor...')
        } else {
          throw error
        }
      }

      // Koleksiyon yoksa oluştur
      const response = await $fetch(`${this.baseUrl}/collections/${this.collectionName}`, {
        method: 'PUT',
        body: {
          vectors: {
            size: 384,
            distance: 'Cosine'
          }
        }
      })
      console.log('✅ Qdrant koleksiyonu oluşturuldu:', this.collectionName)
      return response
    } catch (error: any) {
      if (error.status === 409) {
        console.log('✅ Koleksiyon zaten mevcut')
        return true
      }
      console.error('❌ Koleksiyon oluşturulamadı:', error)
      throw error
    }
  }

  async addVector(id: string, vector: number[], payload: any) {
    const response = await $fetch(`${this.baseUrl}/collections/${this.collectionName}/points`, {
      method: 'PUT',
      body: {
        points: [{
          id,
          vector,
          payload
        }]
      }
    })
    return response
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