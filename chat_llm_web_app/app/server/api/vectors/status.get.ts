export default defineEventHandler(async (event) => {
  const config = useRuntimeConfig()
  
  try {
    const { QdrantClient } = await import('~/server/utils/qdrant')
    const qdrant = new QdrantClient(config.qdrantUrl)
    
    const info = await qdrant.getCollectionInfo()
    
    return {
      success: true,
      collection: info
    }
  } catch (error: any) {
    console.error('Vektör durumu hatası:', error)
    throw createError({
      statusCode: 500,
      statusMessage: 'Vektör veritabanı durumu alınamadı'
    })
  }
}) 