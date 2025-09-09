<template>
    <div class="space-y-4">
        <!-- Header -->
        <div class="flex items-center justify-between">
            <h3
                class="text-lg font-semibold text-white flex items-center gap-2"
            >
                <svg
                    class="w-5 h-5 text-emerald-400"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                >
                    <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z"
                    ></path>
                </svg>
                Sohbet Geçmişi
            </h3>
            <div class="flex flex-col items-center gap-2">
                <button
                    @click="loadHistory"
                    :disabled="isLoading"
                    class="flex items-center gap-2 px-3 py-1.5 text-sm bg-gradient-to-r from-emerald-500/20 to-green-600/20 border border-emerald-500/30 text-emerald-300 rounded-lg hover:from-emerald-500/30 hover:to-green-600/30 hover:text-white disabled:opacity-50 transition-all duration-300 hover:scale-105 min-w-[120px] justify-center"
                >
                    <svg
                        v-if="isLoading"
                        class="w-4 h-4 animate-spin"
                        fill="none"
                        stroke="currentColor"
                        viewBox="0 0 24 24"
                    >
                        <path
                            stroke-linecap="round"
                            stroke-linejoin="round"
                            stroke-width="2"
                            d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"
                        ></path>
                    </svg>
                    <span v-else>Yenile</span>
                </button>
                <button
                    @click="showClearAllDialog = true"
                    :disabled="chatStore.history.length === 0"
                    class="flex items-center gap-2 px-3 py-1.5 text-sm bg-gradient-to-r from-red-500/20 to-pink-600/20 border border-red-500/30 text-red-300 rounded-lg hover:from-red-500/30 hover:to-pink-600/30 hover:text-white disabled:opacity-50 disabled:cursor-not-allowed transition-all duration-300 hover:scale-105 min-w-[120px] justify-center"
                >
                    <svg
                        class="w-4 h-4"
                        fill="none"
                        stroke="currentColor"
                        viewBox="0 0 24 24"
                    >
                        <path
                            stroke-linecap="round"
                            stroke-linejoin="round"
                            stroke-width="2"
                            d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"
                        ></path>
                    </svg>
                    Tümünü Sil
                </button>
            </div>
        </div>

        <!-- Empty State -->
        <div
            v-if="chatStore.history.length === 0 && !isLoading"
            class="text-center py-12"
        >
            <div
                class="w-16 h-16 mx-auto mb-4 rounded-full bg-gradient-to-br from-emerald-500/20 to-green-600/20 border border-emerald-500/30 flex items-center justify-center"
            >
                <svg
                    class="w-8 h-8 text-emerald-400"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                >
                    <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z"
                    ></path>
                </svg>
            </div>
            <p class="text-emerald-200 text-sm">Henüz sohbet geçmişi yok</p>
            <p class="text-emerald-300/60 text-xs mt-1">
                İlk sorunuzu sorduğunuzda burada görünecek
            </p>
        </div>

        <!-- Chat List -->
        <div
            v-else
            class="space-y-3 h-[calc(100vh-400px)] overflow-y-auto pr-2"
        >
            <div
                v-for="chat in chatStore.history"
                :key="chat._id"
                @click="selectChat(chat)"
                class="group relative overflow-hidden rounded-xl border border-blue-800/30 bg-gradient-to-r from-blue-900/20 to-indigo-900/20 hover:from-blue-900/30 hover:to-indigo-900/30 cursor-pointer transition-all duration-300 hover:scale-[1.02]"
                :class="
                    selectedChatId === chat._id
                        ? 'ring-2 ring-emerald-500/50 from-emerald-900/30 to-green-900/30'
                        : ''
                "
            >
                <!-- Background Glow Effect -->
                <div
                    class="absolute inset-0 bg-gradient-to-r from-emerald-500/5 to-green-600/5 opacity-0 group-hover:opacity-100 transition-opacity duration-300"
                ></div>

                <!-- Content -->
                <div class="relative p-4">
                    <!-- Header -->
                    <div class="flex items-start justify-between mb-3">
                        <div class="flex items-center gap-2">
                            <div
                                class="w-2 h-2 rounded-full bg-emerald-500"
                            ></div>
                            <span class="text-xs text-emerald-300 font-medium">
                                {{ formatDate(chat.lastActivity) }}
                            </span>
                        </div>
                        <div class="flex items-center gap-1">
                            <div
                                class="px-2 py-1 rounded-full text-xs font-medium bg-emerald-500/20 text-emerald-300 border border-emerald-500/30"
                            >
                                {{ chat.messageCount }} mesaj
                            </div>
                        </div>
                    </div>

                    <!-- Message -->
                    <div class="mb-2">
                        <p
                            class="text-sm text-white font-medium line-clamp-2 group-hover:text-emerald-100 transition-colors"
                        >
                            {{ getFirstMessage(chat) }}
                        </p>
                    </div>

                    <!-- Response Preview -->
                    <div class="mb-3">
                        <p class="text-xs text-emerald-200/70 line-clamp-2">
                            {{ getLastMessage(chat) }}
                        </p>
                    </div>

                    <!-- Bottom Bar -->
                    <div
                        class="flex items-center justify-between pt-2 border-t border-blue-800/20"
                    >
                        <div
                            class="flex items-center gap-2 text-xs text-blue-300/60"
                        >
                            <svg
                                class="w-3 h-3"
                                fill="none"
                                stroke="currentColor"
                                viewBox="0 0 24 24"
                            >
                                <path
                                    stroke-linecap="round"
                                    stroke-linejoin="round"
                                    stroke-width="2"
                                    d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z"
                                ></path>
                            </svg>
                            <span>{{ chat.messageCount }} mesaj</span>
                        </div>
                        <div class="flex items-center gap-2">
                            <div
                                class="text-xs text-emerald-400/60 group-hover:text-emerald-300 transition-colors"
                            >
                                Tıklayın
                            </div>
                            <button
                                @click.stop="openDeleteDialog(chat)"
                                class="p-1.5 rounded-lg bg-red-500/20 border border-red-500/30 text-red-300 hover:bg-red-500/30 hover:text-white transition-all duration-300 hover:scale-110 opacity-0 group-hover:opacity-100"
                            >
                                <svg
                                    class="w-3 h-3"
                                    fill="none"
                                    stroke="currentColor"
                                    viewBox="0 0 24 24"
                                >
                                    <path
                                        stroke-linecap="round"
                                        stroke-linejoin="round"
                                        stroke-width="2"
                                        d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"
                                    ></path>
                                </svg>
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Pagination -->
        <div
            v-if="chatStore.history.length > 0"
            class="flex items-center justify-between pt-4 border-t border-blue-800/30"
        >
            <button
                @click="loadHistory(currentPage - 1)"
                :disabled="currentPage <= 1"
                class="px-3 py-1.5 text-sm bg-blue-900/30 border border-blue-800/30 text-blue-200 rounded-lg hover:bg-blue-900/50 hover:text-white disabled:opacity-50 disabled:cursor-not-allowed transition-all duration-300"
            >
                <svg
                    class="w-4 h-4"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                >
                    <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M15 19l-7-7 7-7"
                    ></path>
                </svg>
            </button>

            <div class="flex items-center gap-2">
                <span class="text-sm text-blue-300">Sayfa</span>
                <span
                    class="px-3 py-1 text-sm bg-emerald-500/20 border border-emerald-500/30 text-emerald-300 rounded-lg font-medium"
                >
                    {{ currentPage }}
                </span>
            </div>

            <button
                @click="loadHistory(currentPage + 1)"
                :disabled="chatStore.history.length < 50"
                class="px-3 py-1.5 text-sm bg-blue-900/30 border border-blue-800/30 text-blue-200 rounded-lg hover:bg-blue-900/50 hover:text-white disabled:opacity-50 disabled:cursor-not-allowed transition-all duration-300"
            >
                <svg
                    class="w-4 h-4"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                >
                    <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M9 5l7 7-7 7"
                    ></path>
                </svg>
            </button>
        </div>
    </div>

    <!-- Delete Confirmation Dialog -->
    <div
        v-if="showDeleteDialog"
        class="fixed inset-0 bg-black/50 backdrop-blur-sm flex items-center justify-center z-50"
    >
        <div
            class="bg-gradient-to-br from-slate-900 to-blue-950 border border-red-500/30 rounded-2xl p-6 max-w-md w-full mx-4 shadow-2xl"
        >
            <div class="flex items-center gap-3 mb-4">
                <div
                    class="w-10 h-10 rounded-full bg-red-500/20 border border-red-500/30 flex items-center justify-center"
                >
                    <svg
                        class="w-5 h-5 text-red-400"
                        fill="none"
                        stroke="currentColor"
                        viewBox="0 0 24 24"
                    >
                        <path
                            stroke-linecap="round"
                            stroke-linejoin="round"
                            stroke-width="2"
                            d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L3.732 16.5c-.77.833.192 2.5 1.732 2.5z"
                        ></path>
                    </svg>
                </div>
                <h3 class="text-lg font-semibold text-white">Sohbeti Sil</h3>
            </div>
            <p class="text-gray-300 mb-6">
                Bu sohbeti silmek istediğinizden emin misiniz? Bu işlem geri
                alınamaz.
            </p>
            <div class="flex items-center gap-3">
                <button
                    @click="confirmDelete"
                    class="flex-1 px-4 py-2 bg-gradient-to-r from-red-500 to-pink-600 text-white rounded-lg hover:from-red-600 hover:to-pink-700 transition-all duration-300 font-medium"
                >
                    Evet, Sil
                </button>
                <button
                    @click="showDeleteDialog = false"
                    class="flex-1 px-4 py-2 bg-gradient-to-r from-gray-600 to-gray-700 text-white rounded-lg hover:from-gray-700 hover:to-gray-800 transition-all duration-300 font-medium"
                >
                    İptal
                </button>
            </div>
        </div>
    </div>

    <!-- Clear All Confirmation Dialog -->
    <div
        v-if="showClearAllDialog"
        class="fixed inset-0 bg-black/50 backdrop-blur-sm flex items-center justify-center z-50"
    >
        <div
            class="bg-gradient-to-br from-slate-900 to-blue-950 border border-red-500/30 rounded-2xl p-6 max-w-md w-full mx-4 shadow-2xl"
        >
            <div class="flex items-center gap-3 mb-4">
                <div
                    class="w-10 h-10 rounded-full bg-red-500/20 border border-red-500/30 flex items-center justify-center"
                >
                    <svg
                        class="w-5 h-5 text-red-400"
                        fill="none"
                        stroke="currentColor"
                        viewBox="0 0 24 24"
                    >
                        <path
                            stroke-linecap="round"
                            stroke-linejoin="round"
                            stroke-width="2"
                            d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L3.732 16.5c-.77.833.192 2.5 1.732 2.5z"
                        ></path>
                    </svg>
                </div>
                <h3 class="text-lg font-semibold text-white">
                    Tüm Sohbetleri Sil
                </h3>
            </div>
            <p class="text-gray-300 mb-6">
                Tüm sohbet geçmişini silmek istediğinizden emin misiniz? Bu
                işlem geri alınamaz ve tüm sohbetler kalıcı olarak silinecektir.
            </p>
            <div class="flex items-center gap-3">
                <button
                    @click="confirmClearAll"
                    class="flex-1 px-4 py-2 bg-gradient-to-r from-red-500 to-pink-600 text-white rounded-lg hover:from-red-600 hover:to-pink-700 transition-all duration-300 font-medium"
                >
                    Evet, Tümünü Sil
                </button>
                <button
                    @click="showClearAllDialog = false"
                    class="flex-1 px-4 py-2 bg-gradient-to-r from-gray-600 to-gray-700 text-white rounded-lg hover:from-gray-700 hover:to-gray-800 transition-all duration-300 font-medium"
                >
                    İptal
                </button>
            </div>
        </div>
    </div>
</template>

<script setup>
const props = defineProps({
    onChatSelect: {
        type: Function,
        default: null,
    },
});

const chatStore = useChatStore();
const isLoading = ref(false);
const currentPage = ref(1);
const selectedChatId = ref(null);
const showDeleteDialog = ref(false);
const showClearAllDialog = ref(false);
const chatToDelete = ref(null);

const loadHistory = async (page = 1) => {
    isLoading.value = true;
    try {
        await chatStore.loadHistory(page, 50);
        currentPage.value = page;
    } catch (error) {
        console.error("Geçmiş yüklenemedi:", error);
    } finally {
        isLoading.value = false;
    }
};

const selectChat = (chat) => {
    selectedChatId.value = chat._id;
    // Chat seçildiğinde chat interface'e bilgi gönder
    chatStore.selectChat(chat);
    console.log("🔍 Sohbet seçildi:", chat._id, chat.sessionId);

    // Mobilde sidebar'ı kapat
    if (props.onChatSelect) {
        props.onChatSelect();
    }
};

const openDeleteDialog = (chat) => {
    chatToDelete.value = chat;
    showDeleteDialog.value = true;
};

const confirmDelete = async () => {
    if (chatToDelete.value) {
        const success = await chatStore.deleteChat(
            chatToDelete.value.sessionId
        );
        if (success) {
            showDeleteDialog.value = false;
            chatToDelete.value = null;
        }
    }
};

const confirmClearAll = async () => {
    const success = await chatStore.clearAllChats();
    if (success) {
        showClearAllDialog.value = false;
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

const getFirstMessage = (chat) => {
    if (chat.messages && chat.messages.length > 0) {
        const firstUserMessage = chat.messages.find(
            (msg) => msg.role === "user"
        );
        return firstUserMessage ? firstUserMessage.content : "Mesaj bulunamadı";
    }
    return "Mesaj bulunamadı";
};

const getLastMessage = (chat) => {
    if (chat.messages && chat.messages.length > 0) {
        const lastMessage = chat.messages[chat.messages.length - 1];
        return lastMessage.content;
    }
    return "Yanıt bulunamadı";
};

// Auto-load history on mount
onMounted(() => {
    loadHistory();
});
</script>

<style scoped>
.line-clamp-1 {
    display: -webkit-box;
    -webkit-line-clamp: 1;
    -webkit-box-orient: vertical;
    overflow: hidden;
}

.line-clamp-2 {
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
}
</style>
