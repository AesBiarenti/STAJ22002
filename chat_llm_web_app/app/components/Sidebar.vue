<template>
    <!-- Mobile Overlay -->
    <div
        v-if="isOpen"
        class="fixed inset-0 bg-black/60 backdrop-blur-md z-40 md:hidden"
        @click="$emit('close')"
    ></div>

    <div
        :class="[
            'bg-gradient-to-b from-slate-900/95 via-blue-950/90 to-indigo-950/95 backdrop-blur-xl border-r border-blue-800/30 shadow-2xl flex flex-col transition-all duration-700 ease-in-out z-50',
            isOpen ? 'w-full md:w-96' : 'w-0',
            'fixed md:relative inset-y-0 left-0',
        ]"
    >
        <!-- Close Button -->
        <button
            v-if="isOpen"
            @click="$emit('close')"
            class="absolute right-3 md:-right-5 top-4 w-10 h-10 rounded-full bg-gradient-to-r from-emerald-500 to-green-600 text-white flex items-center justify-center hover:from-emerald-600 hover:to-green-700 transition-all duration-300 hover:scale-110 shadow-lg z-10 border border-emerald-400/30"
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
                    d="M6 18L18 6M6 6l12 12"
                ></path>
            </svg>
        </button>

        <!-- Tab Navigation -->
        <div class="px-4 pt-4" v-show="isOpen">
            <div
                class="bg-slate-800/50 rounded-xl p-1 backdrop-blur-sm border border-blue-800/20"
            >
                <button
                    @click="activeTab = 'history'"
                    :class="[
                        'flex-1 px-4 py-3 text-sm font-medium transition-all duration-300 rounded-lg relative overflow-hidden',
                        activeTab === 'history'
                            ? 'text-white bg-gradient-to-r from-emerald-500/20 to-green-600/20 border border-emerald-500/30 shadow-lg'
                            : 'text-blue-200 hover:text-white hover:bg-blue-600/20',
                    ]"
                >
                    <span class="relative z-10 flex items-center gap-2">
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
                                d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"
                            ></path>
                        </svg>
                        Sohbet Geçmişleri
                    </span>
                    <div
                        v-if="activeTab === 'history'"
                        class="absolute inset-0 bg-gradient-to-r from-emerald-500/10 to-green-600/10 animate-pulse"
                    ></div>
                </button>
                <button
                    @click="activeTab = 'vectors'"
                    :class="[
                        'flex-1 px-4 py-3 text-sm font-medium transition-all duration-300 rounded-lg relative overflow-hidden',
                        activeTab === 'vectors'
                            ? 'text-white bg-gradient-to-r from-emerald-500/20 to-green-600/20 border border-emerald-500/30 shadow-lg'
                            : 'text-blue-200 hover:text-white hover:bg-blue-600/20',
                    ]"
                >
                    <span class="relative z-10 flex items-center gap-2">
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
                                d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"
                            ></path>
                        </svg>
                        Vektör Yöneticisi
                    </span>
                    <div
                        v-if="activeTab === 'vectors'"
                        class="absolute inset-0 bg-gradient-to-r from-emerald-500/10 to-green-600/10 animate-pulse"
                    ></div>
                </button>
            </div>
        </div>

        <!-- Tab Content -->
        <div class="flex-1 overflow-y-auto p-4" v-show="isOpen">
            <!-- Sohbet Geçmişleri Tab -->
            <div
                v-if="activeTab === 'history'"
                class="space-y-4 animate-fade-in"
            >
                <div
                    class="bg-gradient-to-r from-blue-900/30 to-indigo-900/30 rounded-xl p-4 border border-blue-800/30 backdrop-blur-sm"
                >
                    <ChatHistory :onChatSelect="handleChatSelect" />
                </div>
            </div>

            <!-- Vektör Yöneticisi Tab -->
            <div
                v-if="activeTab === 'vectors'"
                class="space-y-6 animate-fade-in"
            >
                <div
                    class="bg-gradient-to-r from-emerald-900/30 to-green-900/30 rounded-xl p-4 border border-emerald-800/30 backdrop-blur-sm"
                >
                    <h3
                        class="text-white font-semibold mb-3 flex items-center gap-2"
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
                                d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"
                            ></path>
                        </svg>
                        Vektör Yönetimi
                    </h3>
                    <VectorManager />
                </div>

                <div
                    class="bg-gradient-to-r from-cyan-900/30 to-blue-900/30 rounded-xl p-4 border border-cyan-800/30 backdrop-blur-sm"
                >
                    <h3
                        class="text-white font-semibold mb-3 flex items-center gap-2"
                    >
                        <svg
                            class="w-5 h-5 text-cyan-400"
                            fill="none"
                            stroke="currentColor"
                            viewBox="0 0 24 24"
                        >
                            <path
                                stroke-linecap="round"
                                stroke-linejoin="round"
                                stroke-width="2"
                                d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"
                            ></path>
                        </svg>
                        Sistem Bilgileri
                    </h3>
                    <SystemInfo />
                </div>
            </div>
        </div>

        <!-- Footer -->
        <div class="p-4 border-t border-blue-800/30" v-show="isOpen">
            <div class="text-center">
                <div class="text-xs text-blue-300/60">
                    Mesai Analiz Sistemi v2.0
                </div>
            </div>
        </div>
    </div>
</template>

<script setup>
const props = defineProps({
    isOpen: {
        type: Boolean,
        default: true,
    },
});

const emit = defineEmits(["close"]);

const activeTab = ref("history");

const handleChatSelect = () => {
    // Mobilde sidebar'ı kapat
    if (window.innerWidth < 768) {
        emit("close");
    }
};
</script>

<style scoped>
.animate-fade-in {
    animation: fadeIn 0.5s ease-out;
}

@keyframes fadeIn {
    from {
        opacity: 0;
        transform: translateY(10px);
    }
    to {
        opacity: 1;
        transform: translateY(0);
    }
}
</style>
