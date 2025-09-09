<template>
    <div class="flex items-center gap-4">
        <!-- Status Indicators -->
        <div class="flex items-center gap-2">
            <div
                v-for="(status, service) in systemStore.status"
                :key="service"
                class="flex items-center gap-1 text-xs"
            >
                <div
                    class="w-2 h-2 rounded-full"
                    :class="getStatusColor(status)"
                ></div>
                <span class="capitalize">{{ service }}</span>
            </div>
        </div>

        <!-- Refresh Button -->
        <button
            @click="systemStore.checkHealth()"
            :disabled="systemStore.isLoading"
            class="px-2 py-1 text-xs bg-neutral-100 dark:bg-neutral-700 text-neutral-700 dark:text-neutral-100 rounded hover:bg-neutral-200 dark:hover:bg-neutral-600 disabled:opacity-50"
        >
            {{ systemStore.isLoading ? "..." : "Yenile" }}
        </button>

        <!-- Error Tooltip -->
        <div v-if="systemStore.error" class="relative group">
            <div
                class="w-4 h-4 rounded-full bg-red-500 flex items-center justify-center text-white text-xs cursor-help"
            >
                !
            </div>
            <div
                class="absolute bottom-full right-0 mb-2 px-2 py-1 bg-red-600 text-white text-xs rounded opacity-0 group-hover:opacity-100 transition-opacity whitespace-nowrap"
            >
                {{ systemStore.error }}
            </div>
        </div>
    </div>
</template>

<script setup>
const systemStore = useSystemStore();

const getStatusColor = (status) => {
    switch (status) {
        case "healthy":
            return "bg-green-500";
        case "unhealthy":
            return "bg-red-500";
        default:
            return "bg-neutral-400";
    }
};

// Başlangıçta health check yap
onMounted(() => {
    systemStore.checkHealth();
});
</script>
