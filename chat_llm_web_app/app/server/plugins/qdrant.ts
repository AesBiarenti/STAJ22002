import { QdrantClient } from '~/server/utils/qdrant'

export default defineNitroPlugin(async (nitroApp) => {
  const config = useRuntimeConfig()
  
  try {
    const qdrant = new QdrantClient(config.qdrantUrl)
    await qdrant.createCollection()
    console.log('✅ Qdrant vektör veritabanı hazır')
    
    // Global olarak erişilebilir hale getir
    nitroApp.qdrant = qdrant
  } catch (error) {
    console.error('❌ Qdrant başlatılamadı:', error)
  }
}) 