export default defineEventHandler(async (event) => {
  try {
    const query = getQuery(event)
    const limit = parseInt(query.limit as string) || 50
    const page = parseInt(query.page as string) || 1
    const skip = (page - 1) * limit
    
    const mongoose = await import('mongoose')
    const ChatLog = mongoose.default.model('ChatLog', new mongoose.default.Schema({
      message: String,
      response: String,
      timestamp: Date,
      context: String
    }))
    
    const chats = await ChatLog.find()
      .sort({ timestamp: -1 })
      .skip(skip)
      .limit(limit)
      .lean()
    
    const total = await ChatLog.countDocuments()
    
    return {
      success: true,
      data: chats,
      pagination: {
        page,
        limit,
        total,
        pages: Math.ceil(total / limit)
      }
    }
    
  } catch (error: any) {
    console.error('Sohbet geçmişi hatası:', error)
    throw createError({
      statusCode: 500,
      statusMessage: 'Sohbet geçmişi alınamadı'
    })
  }
}) 