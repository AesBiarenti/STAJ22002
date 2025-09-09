import mongoose from 'mongoose'

export default defineNitroPlugin(async (nitroApp) => {
  const config = useRuntimeConfig()
  
  try {
    await mongoose.connect(config.mongodbUri)
    console.log('✅ MongoDB bağlantısı başarılı')
  } catch (error) {
    console.error('❌ MongoDB bağlantı hatası:', error)
  }
}) 