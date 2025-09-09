export default defineEventHandler(async (event) => {
  const config = useRuntimeConfig()
  const body = await readBody(event)
  
  try {
    const { message, history = [], sessionId, stream = false } = body
    
    if (!message) {
      throw createError({
        statusCode: 400,
        statusMessage: 'Mesaj gerekli'
      })
    }

    // Mesajı vektör veritabanında ara
    const { generateEmbedding } = await import('~/server/utils/ai')
    const { QdrantClient } = await import('~/server/utils/qdrant')
    
    const embedding = await generateEmbedding(message, config.ollamaUrl, config.ollamaEmbeddingModel)
    const qdrant = new QdrantClient(config.qdrantUrl)
    
    // Daha fazla sonuç al ve benzerlik skoruna göre filtrele
    console.log('🔍 Vektör arama başlıyor...')
    const searchResults = await qdrant.searchVector(embedding, 5)
    console.log('🔍 Vektör arama sonuçları:', searchResults)
    console.log('📊 Arama sonucu sayısı:', searchResults.result?.length || 0)
    
    // Debug: Vektör sayısını kontrol et
    const collectionInfo = await qdrant.getCollectionInfo()
    console.log('📊 Collection bilgisi:', collectionInfo?.result?.points_count || 0)
    
    // Context oluştur - benzerlik skoruna göre filtrele
    let context = ''
    let contextUsed = false
    
    if (searchResults.result && searchResults.result.length > 0) {
      const relevantResults = searchResults.result
        .filter((result: any) => result.score > 0.3) // Cosine similarity için daha düşük threshold
        .slice(0, 3) // En fazla 3 sonuç kullan
      
      if (relevantResults.length > 0) {
        context = relevantResults
          .map((result: any) => result.payload?.text || '')
          .filter(text => text.trim().length > 0)
          .join('\n\n')
        contextUsed = true
        console.log('Context oluşturuldu:', context)
      }
    }
    
    // Chat mesajlarını hazırla
    const systemPrompt = contextUsed 
      ? `Sen bir mesai analiz asistanısın. Aşağıdaki güvenilir bilgileri kullanarak soruları yanıtla:

${context}

Bu bilgileri kullanarak doğru ve güncel yanıtlar ver. Eğer soru bu bilgilerle ilgili değilse, genel bilgilerinle yanıtla. Lütfen verilen bilgileri kullanarak spesifik ve detaylı yanıtlar ver.`
      : `Sen bir mesai analiz asistanısın. Mesai saatleri, çalışan verileri ve iş kuralları hakkında genel bilgilerinle yanıt ver. Eğer kesin bilgi yoksa, bunu belirt.`
    
    console.log('System prompt:', systemPrompt)
    
    const messages = [
      {
        role: 'system',
        content: systemPrompt
      },
      ...history,
      {
        role: 'user',
        content: message
      }
    ]
    
    // Stream modu kontrolü
    if (stream) {
      // Stream response için header'ları ayarla
      setHeader(event, 'Content-Type', 'text/event-stream')
      setHeader(event, 'Cache-Control', 'no-cache')
      setHeader(event, 'Connection', 'keep-alive')
      setHeader(event, 'Access-Control-Allow-Origin', '*')
      setHeader(event, 'Access-Control-Allow-Headers', 'Cache-Control')

      // Stream yanıtı başlat
      const streamResponse = await $fetch(`${config.ollamaUrl}/chat`, {
        method: 'POST',
        body: {
          model: config.ollamaChatModel,
          messages,
          stream: true,
          options: {
            temperature: parseFloat(config.aiTemperature),
            num_predict: parseInt(config.aiMaxTokens)
          }
        }
      })

      // Stream response'u işle
      let fullResponse = ''
      
      for await (const chunk of streamResponse) {
        if (chunk.message?.content) {
          const content = chunk.message.content
          fullResponse += content
          
          // Her kelime için stream gönder
          const words = content.split(' ')
          for (const word of words) {
            if (word.trim()) {
              const data = `data: ${JSON.stringify({
                type: 'word',
                content: word + ' ',
                fullResponse: fullResponse
              })}\n\n`
              
              await sendStream(event, data)
            }
          }
        }
      }

      // Stream'i sonlandır
      await sendStream(event, `data: ${JSON.stringify({
        type: 'done',
        fullResponse: fullResponse
      })}\n\n`)

      // Veritabanına kaydet (session bazlı)
      if (sessionId) {
        const mongoose = await import('mongoose')
        let ChatSession
        try {
          ChatSession = mongoose.default.model('ChatSession')
        } catch {
          ChatSession = mongoose.default.model('ChatSession', new mongoose.default.Schema({
            sessionId: String,
            messages: [{
              role: String,
              content: String,
              timestamp: Date
            }],
            createdAt: Date,
            lastActivity: Date,
            messageCount: Number
          }))
        }

        // Session'ı bul veya oluştur
        let session = await ChatSession.findOne({ sessionId })
        if (!session) {
          session = new ChatSession({
            sessionId,
            messages: [],
            createdAt: new Date(),
            lastActivity: new Date(),
            messageCount: 0
          })
        }

        // Mesajları ekle
        session.messages.push(
          { role: 'user', content: message, timestamp: new Date() },
          { role: 'assistant', content: fullResponse, timestamp: new Date() }
        )
        session.lastActivity = new Date()
        session.messageCount = session.messages.length

        await session.save()
      }

      return
    }

    // Normal yanıt modu
    const { generateChatResponse } = await import('~/server/utils/ai')
    const response = await generateChatResponse(
      messages,
      config.ollamaUrl,
      config.ollamaChatModel,
      parseFloat(config.aiTemperature),
      parseInt(config.aiMaxTokens)
    )
    
    // Session bazlı kaydetme
    if (sessionId) {
      const mongoose = await import('mongoose')
      let ChatSession
      try {
        ChatSession = mongoose.default.model('ChatSession')
      } catch {
        ChatSession = mongoose.default.model('ChatSession', new mongoose.default.Schema({
          sessionId: String,
          messages: [{
            role: String,
            content: String,
            timestamp: Date
          }],
          createdAt: Date,
          lastActivity: Date,
          messageCount: Number
        }))
      }

      // Session'ı bul veya oluştur
      let session = await ChatSession.findOne({ sessionId })
      if (!session) {
        session = new ChatSession({
          sessionId,
          messages: [],
          createdAt: new Date(),
          lastActivity: new Date(),
          messageCount: 0
        })
      }

      // Mesajları ekle
      session.messages.push(
        { role: 'user', content: message, timestamp: new Date() },
        { role: 'assistant', content: response.message?.content || '', timestamp: new Date() }
      )
      session.lastActivity = new Date()
      session.messageCount = session.messages.length

      await session.save()
    }
    
    return {
      success: true,
      response: response.message?.content || '',
      context: contextUsed ? 'Vektör veritabanından bilgi kullanıldı' : 'Genel bilgi kullanıldı',
      contextDetails: contextUsed ? {
        sources: searchResults.result?.slice(0, 3).map((r: any) => r.payload?.text?.substring(0, 100) + '...') || [],
        scores: searchResults.result?.slice(0, 3).map((r: any) => Math.round(r.score * 100)) || []
      } : null
    }
    
  } catch (error: any) {
    console.error('Chat hatası:', error)
    throw createError({
      statusCode: 500,
      statusMessage: error.message || 'Chat işlemi başarısız'
    })
  }
}) 