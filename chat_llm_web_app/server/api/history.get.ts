export default defineEventHandler(async (event) => {
  try {
    const query = getQuery(event)
    const page = parseInt(query.page as string) || 1
    const limit = parseInt(query.limit as string) || 50
    const skip = (page - 1) * limit
    
    const mongoose = await import('mongoose')
    
    // Model zaten tanımlanmışsa tekrar tanımlama
    let ChatSession
    try {
      ChatSession = mongoose.default.model('ChatSession')
    } catch {
      ChatSession = mongoose.default.model('ChatSession', new mongoose.default.Schema({
        sessionId: String,
        messages: [{
          id: String,
          role: String,
          content: String,
      timestamp: Date,
        context: String,
        contextUsed: Boolean
        }],
        createdAt: Date,
        lastActivity: Date,
        messageCount: Number
    }))
    }
    
    // Session'ları son aktivite zamanına göre sırala
    const data = await ChatSession.find()
      .sort({ lastActivity: -1 })
      .skip(skip)
      .limit(limit)
      .lean()
    
    const total = await ChatSession.countDocuments()
    
    return {
      success: true,
      data,
      pagination: {
        page,
        limit,
        total,
        pages: Math.ceil(total / limit)
      }
    }
    
  } catch (error: any) {
    console.error('Geçmiş yükleme hatası:', error)
    throw createError({
      statusCode: 500,
      statusMessage: 'Geçmiş yüklenemedi'
    })
  }
}) 