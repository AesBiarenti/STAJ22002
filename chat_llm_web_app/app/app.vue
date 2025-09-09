<template>
    <div
        class="min-h-screen bg-gray-50 dark:bg-neutral-900 text-gray-900 dark:text-gray-100"
    >
        <NuxtPage />
    </div>
</template>

<script setup>
// Global error handling
onErrorCaptured((error) => {
    console.error("Global error:", error);
    return false;
});
</script>
