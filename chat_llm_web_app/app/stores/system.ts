import { defineStore } from 'pinia'

interface SystemStatus {
  database: 'healthy' | 'unhealthy' | 'unknown'
  qdrant: 'healthy' | 'unhealthy' | 'unknown'
  ollama: 'healthy' | 'unhealthy' | 'unknown'
}

interface SystemState {
  status: SystemStatus
  isLoading: boolean
  error: string | null
  lastCheck: Date | null
}

export const useSystemStore = defineStore('system', {
  state: (): SystemState => ({
    status: {
      database: 'unknown',
      qdrant: 'unknown',
      ollama: 'unknown'
    },
    isLoading: false,
    error: null,
    lastCheck: null
  }),

  getters: {
    isHealthy: (state) => 
      state.status.database === 'healthy' && 
      state.status.qdrant === 'healthy' && 
      state.status.ollama === 'healthy',
    
    overallStatus: (state) => {
      const healthyCount = Object.values(state.status).filter(s => s === 'healthy').length
      const totalCount = Object.keys(state.status).length
      
      if (healthyCount === totalCount) return 'healthy'
      if (healthyCount > 0) return 'degraded'
      return 'unhealthy'
    }
  },

  actions: {
    async checkHealth() {
      this.isLoading = true
      this.error = null
      
      try {
        console.log('🔍 Health check başlıyor...')
        const response = await $fetch('/api/health')
        console.log('🔍 Health check sonucu:', response)
        this.status = response.services
        this.lastCheck = new Date()
      } catch (error: any) {
        console.error('❌ Health check hatası:', error)
        this.error = error.message || 'Sistem durumu kontrol edilemedi'
        // Hata durumunda tüm servisleri unknown yap
        this.status = {
          database: 'unknown',
          qdrant: 'unknown',
          ollama: 'unknown'
        }
      } finally {
        this.isLoading = false
      }
    },

    async getVectorStatus() {
      try {
        const response = await $fetch('/api/vectors/status')
        return response
      } catch (error: any) {
        console.error('Vektör durumu hatası:', error)
        throw error
      }
    },

    async populateVectors(texts: string[]) {
      try {
        const response = await $fetch('/api/vectors/populate', {
          method: 'POST',
          body: { texts }
        })
        return response
      } catch (error: any) {
        console.error('Vektör doldurma hatası:', error)
        throw error
      }
    }
  }
}) 