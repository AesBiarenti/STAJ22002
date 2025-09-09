export default defineEventHandler(async (event) => {
  try {
    const sessionId = getRouterParam(event, 'sessionId')
    
    if (!sessionId) {
      throw createError({
        statusCode: 400,
        statusMessage: 'Session ID gerekli'
      })
    }
    
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
    
    const session = await ChatSession.findOne({ sessionId }).lean()
    const data = session ? session.messages : []
    
    return {
      success: true,
      data,
      count: data.length
    }
    
  } catch (error: any) {
    console.error('Session mesajları yükleme hatası:', error)
    throw createError({
      statusCode: 500,
      statusMessage: 'Session mesajları yüklenemedi'
    })
  }
}) 