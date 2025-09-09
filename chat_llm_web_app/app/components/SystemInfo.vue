<template>
    <div
        class="bg-neutral-50 dark:bg-neutral-800/50 border border-neutral-200 dark:border-neutral-700 rounded-lg p-4"
    >
        <h3 class="text-sm font-semibold mb-3">Sistem Bilgileri</h3>

        <div class="space-y-3">
            <!-- Overall Status -->
            <div
                class="flex items-center justify-between p-2 rounded border"
                :class="getOverallStatusClass()"
            >
                <div>
                    <div class="text-xs font-medium">Genel Durum</div>
                    <div class="text-xs" :class="getOverallStatusTextClass()">
                        {{ getOverallStatusText() }}
                    </div>
                </div>
                <div
                    class="w-2 h-2 rounded-full"
                    :class="getOverallStatusColor()"
                ></div>
            </div>

            <!-- Services -->
            <div class="space-y-1">
                <div class="text-xs font-medium">Servisler</div>
                <div class="space-y-1">
                    <div
                        v-for="(status, service) in systemStore.status"
                        :key="service"
                        class="flex items-center justify-between text-xs"
                    >
                        <span class="capitalize">{{ service }}</span>
                        <span :class="getServiceStatusClass(status)">{{
                            getServiceStatusText(status)
                        }}</span>
                    </div>
                </div>
            </div>

            <!-- Actions -->
            <div
                class="border-t border-neutral-200 dark:border-neutral-700 pt-3 space-y-2"
            >
                <button
                    @click="clearChat"
                    class="w-full px-3 py-2 text-xs bg-neutral-200 dark:bg-neutral-700 text-neutral-700 dark:text-neutral-100 rounded hover:bg-neutral-300 dark:hover:bg-neutral-600"
                >
                    Sohbeti Temizle
                </button>
                <button
                    @click="refreshAll"
                    class="w-full px-3 py-2 text-xs bg-blue-300 dark:bg-blue-950/40 text-blue-800 dark:text-blue-200 rounded hover:bg-blue-400 dark:hover:bg-blue-950/60"
                >
                    Tümünü Yenile
                </button>
            </div>

            <!-- Version Info -->
            <div
                class="border-t border-neutral-200 dark:border-neutral-700 pt-3"
            >
                <div
                    class="text-xs text-neutral-500 dark:text-neutral-400 space-y-1"
                >
                    <div>Nuxt.js v4.0.3</div>
                    <div>Vue.js v3.5.18</div>
                    <div>Tailwind CSS v3.x</div>
                </div>
            </div>
        </div>
    </div>
</template>

<script setup>
const systemStore = useSystemStore();
const chatStore = useChatStore();

const getOverallStatusClass = () => {
    const status = systemStore.overallStatus;
    switch (status) {
        case "healthy":
            return "bg-green-100 dark:bg-green-900/20 border-green-200 dark:border-green-800";
        case "degraded":
            return "bg-yellow-100 dark:bg-yellow-900/20 border-yellow-200 dark:border-yellow-800";
        default:
            return "bg-red-100 dark:bg-red-900/20 border-red-200 dark:border-red-800";
    }
};

const getOverallStatusTextClass = () => {
    const status = systemStore.overallStatus;
    switch (status) {
        case "healthy":
            return "text-green-700 dark:text-green-300";
        case "degraded":
            return "text-yellow-700 dark:text-yellow-300";
        default:
            return "text-red-700 dark:text-red-300";
    }
};

const getOverallStatusColor = () => {
    const status = systemStore.overallStatus;
    switch (status) {
        case "healthy":
            return "bg-green-500";
        case "degraded":
            return "bg-yellow-500";
        default:
            return "bg-red-500";
    }
};

const getOverallStatusText = () => {
    const status = systemStore.overallStatus;
    switch (status) {
        case "healthy":
            return "Tüm servisler çalışıyor";
        case "degraded":
            return "Bazı servislerde sorun var";
        default:
            return "Sistem hatası";
    }
};

const getServiceStatusClass = (status) => {
    switch (status) {
        case "healthy":
            return "text-green-600 dark:text-green-300";
        case "unhealthy":
            return "text-red-600 dark:text-red-300";
        default:
            return "text-neutral-500 dark:text-neutral-400";
    }
};

const getServiceStatusText = (status) => {
    switch (status) {
        case "healthy":
            return "✓";
        case "unhealthy":
            return "✗";
        default:
            return "?";
    }
};

const clearChat = () => {
    chatStore.clearMessages();
};
const refreshAll = async () => {
    await systemStore.checkHealth();
};
</script>
