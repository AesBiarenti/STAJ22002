import { QdrantClient } from '~/server/utils/qdrant'

export default defineEventHandler(async (event) => {
  try {
    const config = useRuntimeConfig()
    const qdrant = new QdrantClient(config.qdrantUrl)
    const status = await qdrant.getCollectionInfo()
    
    return {
      success: true,
      collection: status.result
    }
  } catch (error: any) {
    console.error('Vektör durumu hatası:', error)
    throw createError({
      statusCode: 500,
      statusMessage: 'Vektör durumu alınamadı'
    })
  }
}) 