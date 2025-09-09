<template>
    <div class="flex-1 flex flex-col bg-transparent h-full">
        <!-- Messages Area -->
        <div class="flex-1 overflow-y-auto min-h-0" ref="messagesContainer">
            <div class="max-w-4xl mx-auto w-full p-4 space-y-6">
                <!-- Selected Chat Header -->
                <div
                    v-if="chatStore.selectedChat"
                    class="flex items-center justify-between p-4 bg-emerald-500/10 rounded-lg border border-emerald-500/30 backdrop-blur-sm animate-fade-in"
                >
                    <div class="flex items-center gap-3">
                        <div
                            class="w-8 h-8 rounded-full bg-emerald-600 text-white flex items-center justify-center text-sm font-bold shadow-lg"
                        >
                            📝
                        </div>
                        <div>
                            <div class="font-medium text-white">
                                Seçilen Sohbet
                            </div>
                            <div class="text-sm text-emerald-200">
                                {{
                                    formatDate(chatStore.selectedChat.timestamp)
                                }}
                            </div>
                        </div>
                    </div>
                    <button
                        @click="chatStore.clearSelectedChat()"
                        class="px-4 py-2 text-sm bg-gradient-to-r from-emerald-500 to-green-600 text-white rounded-lg hover:from-emerald-600 hover:to-green-700 transition-all duration-300 hover:scale-105 shadow-lg"
                    >
                        Yeni Sohbet
                    </button>
                </div>

                <!-- Welcome Message -->
                <div
                    v-if="
                        chatStore.messages.length === 0 &&
                        !chatStore.selectedChat
                    "
                    class="text-center py-16"
                >
                    <div
                        class="w-20 h-20 mx-auto mb-6 rounded-full bg-gradient-to-br from-emerald-500 to-green-600 text-white flex items-center justify-center text-3xl font-bold shadow-2xl animate-pulse-glow"
                    >
                        AI
                    </div>
                    <h2 class="text-3xl font-bold mb-3 text-white">
                        AI Mesai Analiz Asistanı
                    </h2>
                    <p class="text-emerald-200 mb-8 text-lg max-w-2xl mx-auto">
                        Mesai saatleri, çalışan verileri ve iş kuralları
                        hakkında sorularınızı sorun. Vektör veritabanından
                        güncel bilgilerle size yardımcı olacağım.
                    </p>
                    <div
                        class="grid grid-cols-1 md:grid-cols-2 gap-4 max-w-3xl mx-auto"
                    >
                        <button
                            @click="sendExampleMessage('Mesai saatleri nedir?')"
                            class="p-4 text-left border border-emerald-500/30 rounded-xl hover:bg-emerald-500/20 transition-all duration-300 hover:scale-105 bg-white/5 backdrop-blur-sm group"
                        >
                            <div
                                class="font-semibold text-white group-hover:text-emerald-300 transition-colors"
                            >
                                Mesai saatleri nedir?
                            </div>
                            <div class="text-sm text-emerald-200 mt-1">
                                Çalışma saatleri hakkında detaylı bilgi al
                            </div>
                        </button>
                        <button
                            @click="
                                sendExampleMessage(
                                    'Fazla mesai kuralları nelerdir?'
                                )
                            "
                            class="p-4 text-left border border-emerald-500/30 rounded-xl hover:bg-emerald-500/20 transition-all duration-300 hover:scale-105 bg-white/5 backdrop-blur-sm group"
                        >
                            <div
                                class="font-semibold text-white group-hover:text-emerald-300 transition-colors"
                            >
                                Fazla mesai kuralları
                            </div>
                            <div class="text-sm text-emerald-200 mt-1">
                                Fazla mesai hakkında detaylı bilgi al
                            </div>
                        </button>
                    </div>
                </div>

                <!-- Chat Messages -->
                <div
                    v-for="message in chatStore.messages"
                    :key="message.id"
                    class="group"
                >
                    <!-- AI Message (Left Aligned) -->
                    <div
                        v-if="message.role === 'assistant'"
                        class="flex items-start gap-4 max-w-4xl"
                    >
                        <!-- AI Avatar -->
                        <div
                            class="shrink-0 w-8 h-8 rounded-full bg-gradient-to-br from-emerald-500 to-green-600 text-white flex items-center justify-center text-sm font-bold shadow-lg animate-pulse"
                        >
                            AI
                        </div>

                        <!-- AI Message Content -->
                        <div class="flex-1 min-w-0">
                            <div
                                class="bg-white/10 backdrop-blur-sm border border-emerald-500/30 rounded-2xl p-4 shadow-lg"
                            >
                                <div class="prose prose-sm max-w-none">
                                    <div
                                        class="whitespace-pre-wrap text-white leading-relaxed"
                                    >
                                        {{ message.content }}
                                    </div>
                                </div>
                            </div>

                            <!-- Context Information -->
                            <div
                                v-if="message.contextDetails"
                                class="mt-3 p-4 bg-emerald-500/20 rounded-xl border border-emerald-500/30 backdrop-blur-sm animate-fade-in"
                            >
                                <div
                                    class="flex items-center gap-2 text-sm font-medium text-emerald-300 mb-3"
                                >
                                    <span class="text-lg">📚</span>
                                    Vektör veritabanından bilgi kullanıldı
                                </div>
                                <div class="space-y-2">
                                    <div
                                        v-for="(source, index) in message
                                            .contextDetails.sources"
                                        :key="index"
                                        class="text-sm text-emerald-200 p-3 bg-emerald-500/10 rounded-lg border border-emerald-500/20"
                                    >
                                        <div
                                            class="flex items-center gap-2 mb-1"
                                        >
                                            <span
                                                class="font-semibold text-emerald-300"
                                            >
                                                {{
                                                    message.contextDetails
                                                        .scores[index]
                                                }}%
                                            </span>
                                            <span
                                                class="text-xs text-emerald-300"
                                                >benzerlik</span
                                            >
                                        </div>
                                        <div class="text-emerald-100">
                                            {{ source }}
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- User Message (Right Aligned) -->
                    <div
                        v-else
                        class="flex items-start gap-4 justify-end max-w-4xl ml-auto"
                    >
                        <!-- User Message Content -->
                        <div class="flex-1 min-w-0 max-w-3xl">
                            <div
                                class="bg-gradient-to-r from-blue-600 to-indigo-700 text-white rounded-2xl p-4 shadow-lg ml-auto"
                            >
                                <div class="prose prose-sm max-w-none">
                                    <div
                                        class="whitespace-pre-wrap text-white leading-relaxed"
                                    >
                                        {{ message.content }}
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- User Avatar -->
                        <div
                            class="shrink-0 w-8 h-8 rounded-full bg-gradient-to-br from-blue-600 to-indigo-700 text-white flex items-center justify-center text-sm font-bold shadow-lg"
                        >
                            U
                        </div>
                    </div>
                </div>

                <!-- Loading Indicator -->
                <div
                    v-if="chatStore.isLoading"
                    class="flex items-start gap-4 max-w-4xl"
                >
                    <div
                        class="shrink-0 w-8 h-8 rounded-full bg-emerald-600 text-white flex items-center justify-center text-sm font-bold shadow-lg animate-pulse"
                    >
                        AI
                    </div>
                    <div class="flex-1 min-w-0">
                        <div
                            class="bg-white/10 backdrop-blur-sm border border-emerald-500/30 rounded-2xl p-4 shadow-lg"
                        >
                            <div class="flex items-center gap-3">
                                <div class="flex items-center gap-1">
                                    <div
                                        class="w-2 h-2 rounded-full bg-emerald-400 animate-bounce"
                                    ></div>
                                    <div
                                        class="w-2 h-2 rounded-full bg-emerald-400 animate-bounce"
                                        style="animation-delay: 0.1s"
                                    ></div>
                                    <div
                                        class="w-2 h-2 rounded-full bg-emerald-400 animate-bounce"
                                        style="animation-delay: 0.2s"
                                    ></div>
                                </div>
                                <span class="text-emerald-200"
                                    >Yanıt yazılıyor...</span
                                >
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Scroll Anchor -->
                <div ref="scrollAnchor"></div>
            </div>
        </div>

        <!-- Input Area -->
        <div class="border-t border-emerald-500/30 flex-shrink-0">
            <div class="max-w-4xl mx-auto p-6">
                <form
                    @submit.prevent="sendMessage"
                    class="flex items-end gap-4"
                >
                    <div class="flex-1 relative">
                        <textarea
                            v-model="messageInput"
                            placeholder="Mesajınızı yazın... (Enter ile gönder, Shift+Enter ile yeni satır)"
                            :disabled="chatStore.isLoading"
                            rows="1"
                            class="w-full px-6 py-4 pr-16 rounded-2xl bg-white/10 border border-emerald-500/30 placeholder-emerald-200 text-white focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500 resize-none backdrop-blur-sm transition-all duration-300 text-lg scrollbar-hide"
                            @input="autoResize"
                            @keydown="handleKeyDown"
                            ref="textareaRef"
                        ></textarea>
                        <button
                            type="submit"
                            :disabled="
                                !messageInput.trim() || chatStore.isLoading
                            "
                            class="absolute right-3 bottom-3 p-3 rounded-xl bg-gradient-to-r from-emerald-500 to-green-600 text-white hover:from-emerald-600 hover:to-green-700 disabled:opacity-50 disabled:cursor-not-allowed transition-all duration-300 hover:scale-110 shadow-lg"
                        >
                            <svg
                                class="w-5 h-5"
                                fill="none"
                                stroke="currentColor"
                                viewBox="0 0 24 24"
                            >
                                <path
                                    stroke-linecap="round"
                                    stroke-linejoin="round"
                                    stroke-width="2"
                                    d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8"
                                ></path>
                            </svg>
                        </button>
                    </div>
                </form>
                <div
                    class="mt-3 flex items-center justify-between text-xs text-emerald-200"
                >
                    <span
                        >💡 Örnek sorular için yukarıdaki butonları
                        kullanın</span
                    >
                    <span>🔒 Kişisel bilgilerinizi paylaşmayın</span>
                </div>
            </div>
        </div>
    </div>
</template>

<script setup>
const chatStore = useChatStore();
const messageInput = ref("");
const textareaRef = ref(null);

// Autoscroll refs
const messagesContainer = ref(null);
const scrollAnchor = ref(null);

const scrollToBottom = async (smooth = true) => {
    await nextTick();
    // Öncelik: container scroll
    if (messagesContainer.value) {
        messagesContainer.value.scrollTo({
            top: messagesContainer.value.scrollHeight,
            behavior: smooth ? "smooth" : "auto",
        });
        return;
    }
    // Alternatif: anchor'a kaydır
    if (scrollAnchor.value && scrollAnchor.value.scrollIntoView) {
        scrollAnchor.value.scrollIntoView({
            behavior: smooth ? "smooth" : "auto",
            block: "end",
        });
    }
};

onMounted(() => {
    scrollToBottom(false);
});

watch(
    () => chatStore.messages.length,
    () => {
        scrollToBottom(true);
    }
);

watch(
    () => chatStore.selectedChatId,
    () => {
        scrollToBottom(false);
    }
);

const sendMessage = async () => {
    if (!messageInput.value.trim() || chatStore.isLoading) return;
    const message = messageInput.value.trim();
    messageInput.value = "";
    await chatStore.sendMessage(message);
    // Reset textarea height
    if (textareaRef.value) {
        textareaRef.value.style.height = "auto";
    }
};

const sendExampleMessage = async (message) => {
    await chatStore.sendMessage(message);
};

const autoResize = () => {
    if (textareaRef.value) {
        textareaRef.value.style.height = "auto";
        textareaRef.value.style.height = textareaRef.value.scrollHeight + "px";
    }
};

const handleKeyDown = (event) => {
    if (event.key === "Enter") {
        if (event.shiftKey) {
            // Shift+Enter: Allow new line (do nothing, let default behavior)
            return;
        } else {
            // Enter: Send message
            event.preventDefault();
            sendMessage();
        }
    }
};

const formatTime = (date) => {
    try {
        // Eğer zaten Date objesi ise direkt kullan
        const dateObj = date instanceof Date ? date : new Date(date);

        // Geçerli tarih kontrolü
        if (isNaN(dateObj.getTime())) {
            return "--:--";
        }

        return new Intl.DateTimeFormat("tr-TR", {
            hour: "2-digit",
            minute: "2-digit",
        }).format(dateObj);
    } catch (error) {
        console.error("Saat formatı hatası:", error, date);
        return "--:--";
    }
};

const formatDate = (dateString) => {
    try {
        // Eğer zaten Date objesi ise direkt kullan
        const date =
            dateString instanceof Date ? dateString : new Date(dateString);

        // Geçerli tarih kontrolü
        if (isNaN(date.getTime())) {
            return "Geçersiz tarih";
        }

        return new Intl.DateTimeFormat("tr-TR", {
            year: "numeric",
            month: "short",
            day: "numeric",
            hour: "2-digit",
            minute: "2-digit",
        }).format(date);
    } catch (error) {
        console.error("Tarih formatı hatası:", error, dateString);
        return "Geçersiz tarih";
    }
};
</script>
