<template>
    <div
        class="h-screen flex flex-col bg-gradient-to-br from-slate-950 via-blue-950 to-indigo-950"
    >
        <!-- Minimal Header -->
        <div
            class="flex items-center justify-between px-4 py-3 border-b border-blue-800/40 bg-white/5 backdrop-blur-sm"
        >
            <div class="flex items-center gap-4">
                <button
                    @click="toggleSidebar"
                    class="p-2 rounded-lg bg-emerald-500/20 border border-emerald-500/30 text-emerald-300 hover:bg-emerald-500/30 transition-all duration-300 hover:scale-105"
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
                            d="M4 6h16M4 12h16M4 18h16"
                        ></path>
                    </svg>
                </button>
                <h1 class="text-lg font-semibold text-white">
                    AI Mesai Analiz
                </h1>
            </div>
            <div class="flex items-center gap-2">
                <SystemStatus />
            </div>
        </div>

        <!-- Main Content -->
        <div class="flex-1 flex overflow-hidden relative">
            <!-- Sidebar -->
            <Sidebar :isOpen="sidebarOpen" @close="closeSidebar" />

            <!-- Chat Area -->
            <div
                class="flex-1 flex flex-col md:block"
                :class="{ hidden: sidebarOpen }"
            >
                <ChatInterface />
            </div>
        </div>
    </div>
</template>

<script setup>
definePageMeta({ title: "AI Mesai Analiz Uygulaması" });
const systemStore = useSystemStore();
const sidebarOpen = ref(true);

const toggleSidebar = () => {
    sidebarOpen.value = !sidebarOpen.value;
};

const closeSidebar = () => {
    sidebarOpen.value = false;
};

onMounted(() => {
    systemStore.checkHealth();
});
</script>
