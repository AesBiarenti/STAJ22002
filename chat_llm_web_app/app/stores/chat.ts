import { defineStore } from 'pinia'

interface ChatMessage {
  id: string
  role: 'user' | 'assistant'
  content: string
  timestamp: Date
  context?: string
  contextDetails?: {
    sources: string[]
    scores: number[]
  }
}

interface ChatHistory {
  _id: string
  sessionId: string
  messages: ChatMessage[]
  createdAt: string
  lastActivity: string
  messageCount: number
}

interface ChatSession {
  sessionId: string
  messages: ChatMessage[]
  createdAt: Date
  lastActivity: Date
}

interface ChatStats {
  totalChats: number
  todayChats: number
  weeklyChats: number
  lastChatTime: string | null
  avgResponseLength: number
  contextUsage: {
    withContext: number
    withoutContext: number
  }
}

interface ChatState {
  messages: ChatMessage[]
  history: ChatHistory[]
  stats: ChatStats | null
  isLoading: boolean
  error: string | null
  selectedChat: ChatHistory | null
  selectedChatId: string | null
  currentSessionId: string | null
  sessions: ChatSession[]
}

export const useChatStore = defineStore('chat', {
  state: (): ChatState => ({
    messages: [],
    history: [],
    stats: null,
    isLoading: false,
    error: null,
    selectedChat: null,
    selectedChatId: null,
    currentSessionId: null,
    sessions: []
  }),

  getters: {
    messageHistory: (state) => state.messages.map(msg => ({
      role: msg.role,
      content: msg.content
    })),
    
    currentSession: (state) => {
      if (!state.currentSessionId) return null
      return state.sessions.find(s => s.sessionId === state.currentSessionId)
    },
    
    // Tüm mesaj geçmişini döndür (son 10 mesaj)
    fullMessageHistory: (state) => state.messages.slice(-10).map(msg => ({
      role: msg.role,
      content: msg.content
    }))
  },

  actions: {
    // Yeni sohbet oturumu başlat
    startNewSession() {
      const sessionId = `session_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`
      this.currentSessionId = sessionId
      
      const newSession: ChatSession = {
        sessionId,
        messages: [],
        createdAt: new Date(),
        lastActivity: new Date()
      }
      
      this.sessions.push(newSession)
      console.log('🆕 Yeni sohbet oturumu başlatıldı:', sessionId)
    },

    // Mevcut oturumu devam ettir
    continueSession(sessionId: string) {
      this.currentSessionId = sessionId
      const session = this.sessions.find(s => s.sessionId === sessionId)
      if (session) {
        this.messages = [...session.messages]
        session.lastActivity = new Date()
        console.log('🔄 Oturum devam ettiriliyor:', sessionId)
      }
    },

    async sendMessage(content: string) {
      this.isLoading = true
      this.error = null
      
      // Eğer aktif oturum yoksa yeni başlat
      if (!this.currentSessionId) {
        this.startNewSession()
      }
      
      // Kullanıcı mesajını ekle
      const userMessage: ChatMessage = {
        id: `${this.currentSessionId}_user_${Date.now()}`,
        role: 'user',
        content,
        timestamp: new Date()
      }
      
      // Mevcut mesajlara yeni mesajı ekle (mesajları koru)
      this.messages.push(userMessage)
      
      try {
        console.log('🔍 Chat mesajı gönderiliyor:', content, 'Session:', this.currentSessionId)
        
        // Normal yanıt al (stream olmadan)
        const response = await $fetch('/api/chat', {
          method: 'POST',
          body: {
            message: content,
            history: this.fullMessageHistory,
            sessionId: this.currentSessionId,
            stream: false
          }
        })
        
        console.log('🔍 Chat yanıtı alındı:', response)
        
        // AI yanıtını ekle
        const assistantMessage: ChatMessage = {
          id: `${this.currentSessionId}_assistant_${Date.now()}`,
          role: 'assistant',
          content: response.response,
          timestamp: new Date(),
          context: response.context,
          contextDetails: response.contextDetails
        }
        
        // AI yanıtını da ekle
        this.messages.push(assistantMessage)
        
        // Session'ı güncelle
        const session = this.sessions.find(s => s.sessionId === this.currentSessionId)
        if (session) {
          session.messages = [...this.messages]
          session.lastActivity = new Date()
        }
        
      } catch (error: any) {
        this.error = error.message || 'Mesaj gönderilemedi'
        console.error('Chat hatası:', error)
      } finally {
        this.isLoading = false
      }
    },

    async loadHistory(page: number = 1, limit: number = 50) {
      try {
        const response = await $fetch(`/api/history?page=${page}&limit=${limit}`)
        this.history = response.data
        return response
      } catch (error: any) {
        console.error('Geçmiş yüklenemedi:', error)
        throw error
      }
    },

    // Session mesajlarını veritabanından yükle
    async loadSessionMessages(sessionId: string) {
      try {
        const response = await $fetch(`/api/history/session/${sessionId}`)
        if (response.data && response.data.length > 0) {
          // Veritabanından gelen mesajları doğrudan kullan
          this.messages = response.data.map((item: any) => ({
            id: item.id,
            role: item.role,
            content: item.content,
            timestamp: new Date(item.timestamp),
            context: item.context,
            contextDetails: item.contextUsed ? { sources: [], scores: [] } : undefined
          }))
          console.log('📚 Session mesajları yüklendi:', this.messages.length)
        }
      } catch (error: any) {
        console.error('Session mesajları yüklenemedi:', error)
      }
    },

    // Tek sohbeti sil
    async deleteChat(sessionId: string) {
      try {
        const response = await $fetch(`/api/history/delete/${sessionId}`, {
          method: 'DELETE'
        })
        
        if (response.success) {
          // History'den kaldır
          this.history = this.history.filter(chat => chat.sessionId !== sessionId)
          
          // Eğer silinen sohbet seçiliyse temizle
          if (this.selectedChatId && this.selectedChat?.sessionId === sessionId) {
            this.clearSelectedChat()
          }
          
          console.log('🗑️ Sohbet silindi:', sessionId)
          return true
        }
      } catch (error: any) {
        console.error('Sohbet silme hatası:', error)
        return false
      }
    },

    // Tüm sohbetleri sil
    async clearAllChats() {
      try {
        const response = await $fetch('/api/history/clear-all', {
          method: 'DELETE'
        })
        
        if (response.success) {
          // Tüm history'yi temizle
          this.history = []
          this.clearSelectedChat()
          
          console.log('🗑️ Tüm sohbetler silindi')
          return true
        }
      } catch (error: any) {
        console.error('Tüm sohbetleri silme hatası:', error)
        return false
      }
    },

    async loadStats() {
      try {
        const response = await $fetch('/api/stats')
        this.stats = response.stats
        return response.stats
      } catch (error: any) {
        console.error('İstatistikler yüklenemedi:', error)
        throw error
      }
    },

    clearMessages() {
      this.messages = []
      this.error = null
      this.selectedChat = null
      this.selectedChatId = null
      // Yeni oturum başlat
      this.startNewSession()
      console.log('🗑️ Mesajlar temizlendi, yeni sohbet başlatıldı')
    },

    addMessage(message: ChatMessage) {
      this.messages.push(message)
      
      // Oturumu güncelle
      const session = this.sessions.find(s => s.sessionId === this.currentSessionId)
      if (session) {
        session.messages = [...this.messages]
        session.lastActivity = new Date()
      }
    },

    selectChat(chat: ChatHistory) {
      this.selectedChat = chat
      this.selectedChatId = chat._id
      
      console.log('🔍 Chat store - Sohbet seçiliyor:', chat._id, 'Session:', chat.sessionId)
      
      // Seçilen sohbetin session'ını devam ettir
      if (chat.sessionId) {
        this.continueSession(chat.sessionId)
      }
      
      // Seçilen sohbetin mesajlarını yükle
      this.messages = chat.messages.map((msg: any) => ({
        id: msg.id,
        role: msg.role,
        content: msg.content,
        timestamp: new Date(msg.timestamp),
        context: msg.context,
        contextDetails: msg.contextUsed ? { sources: [], scores: [] } : undefined
      }))
      
      console.log('🔍 Chat store - Mesajlar yüklendi:', this.messages.length)
    },

    clearSelectedChat() {
      this.selectedChat = null
      this.selectedChatId = null
      this.messages = []
      // Yeni oturum başlat
      this.startNewSession()
      console.log('🗑️ Seçili sohbet temizlendi, yeni sohbet başlatıldı')
    },

    // Oturumları temizle (eski oturumları kaldır)
    cleanupSessions() {
      const oneHourAgo = new Date(Date.now() - 60 * 60 * 1000)
      this.sessions = this.sessions.filter(session => 
        session.lastActivity > oneHourAgo
      )
    }
  }
}) 