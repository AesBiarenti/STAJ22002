export default defineEventHandler(async (event) => {
  const config = useRuntimeConfig()
  
  try {
    const healthStatus = {
      status: 'healthy',
      timestamp: new Date().toISOString(),
      services: {
        database: 'unknown',
        qdrant: 'unknown',
        ollama: 'unknown',
      },
    }

    // MongoDB bağlantısını kontrol et
    try {
      const mongoose = await import('mongoose')
      if (mongoose.default.connection.readyState === 1) {
        healthStatus.services.database = 'healthy'
      } else {
        healthStatus.services.database = 'unhealthy'
        healthStatus.status = 'degraded'
      }
    } catch (error) {
      healthStatus.services.database = 'unhealthy'
      healthStatus.status = 'degraded'
    }

    // Qdrant bağlantısını kontrol et
    try {
      const { QdrantClient } = await import('~/server/utils/qdrant')
      const qdrant = new QdrantClient(config.qdrantUrl)
      await qdrant.getCollectionInfo()
      healthStatus.services.qdrant = 'healthy'
    } catch (error) {
      healthStatus.services.qdrant = 'unhealthy'
      healthStatus.status = 'degraded'
    }

    // Ollama bağlantısını kontrol et
    try {
      await $fetch(`${config.ollamaUrl.replace('/api', '')}/api/tags`, {
        timeout: 5000,
      })
      healthStatus.services.ollama = 'healthy'
    } catch (error) {
      healthStatus.services.ollama = 'unhealthy'
      healthStatus.status = 'degraded'
    }

    const statusCode = healthStatus.status === 'healthy' ? 200 : 503
    setResponseStatus(event, statusCode)
    return healthStatus
  } catch (error: any) {
    setResponseStatus(event, 503)
    return {
      status: 'unhealthy',
      timestamp: new Date().toISOString(),
      error: error.message,
    }
  }
}) 