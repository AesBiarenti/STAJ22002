<template>
    <div
        class="bg-white/10 backdrop-blur-sm border border-emerald-500/30 rounded-lg p-6"
    >
        <h3 class="text-lg font-semibold mb-4 text-white">Vektör Yöneticisi</h3>

        <!-- Vector Status -->
        <div class="mb-3">
            <div class="flex items-center justify-between mb-2">
                <span class="text-sm font-medium text-emerald-200">Durum</span>
                <button
                    @click="loadVectorStatus"
                    :disabled="isLoadingStatus"
                    class="text-xs px-3 py-1 bg-gradient-to-r from-emerald-500 to-green-600 text-white rounded hover:from-emerald-600 hover:to-green-700 disabled:opacity-50 transition-all duration-300 hover:scale-105"
                >
                    {{ isLoadingStatus ? "..." : "Yenile" }}
                </button>
            </div>
            <div v-if="vectorStatus" class="text-sm text-emerald-200">
                <div class="grid grid-cols-2 gap-4">
                    <div
                        class="bg-emerald-500/10 p-3 rounded-lg border border-emerald-500/20"
                    >
                        <div class="text-xs text-emerald-300/70 mb-1">
                            Toplam Vektör
                        </div>
                        <div class="text-lg font-semibold text-emerald-200">
                            {{ vectorStatus.collection?.points_count || 0 }}
                        </div>
                        <div class="text-xs text-emerald-300/60">
                            Kayıtlı veri
                        </div>
                    </div>
                    <div
                        class="bg-blue-500/10 p-3 rounded-lg border border-blue-500/20"
                    >
                        <div class="text-xs text-blue-300/70 mb-1">
                            Vektör Boyutu
                        </div>
                        <div class="text-lg font-semibold text-blue-200">
                            {{
                                vectorStatus.collection?.config?.params?.vectors
                                    ?.size || 384
                            }}
                        </div>
                        <div class="text-xs text-blue-300/60">
                            Boyut (dimension)
                        </div>
                    </div>
                </div>
                <div class="mt-3 text-xs text-emerald-300/60">
                    💡 Bu istatistikler Qdrant vektör veritabanındaki kayıtlı
                    veri sayısını gösterir
                </div>
            </div>
        </div>

        <!-- Excel Upload -->
        <div class="mb-4">
            <div class="text-sm font-medium mb-2 text-emerald-200">
                Excel Dosyası Yükle
            </div>
            <div
                class="border-2 border-dashed border-emerald-500/30 rounded-lg p-4 text-center bg-white/5 backdrop-blur-sm"
            >
                <input
                    ref="fileInput"
                    type="file"
                    accept=".xlsx,.xls,.csv"
                    @change="handleFileUpload"
                    class="hidden"
                />
                <button
                    @click="$refs.fileInput.click()"
                    :disabled="isUploading"
                    class="w-full px-4 py-2 text-sm bg-gradient-to-r from-emerald-500 to-green-600 text-white rounded hover:from-emerald-600 hover:to-green-700 disabled:opacity-50 transition-all duration-300 hover:scale-105 shadow-lg"
                >
                    {{ isUploading ? "Yükleniyor..." : "Excel Dosyası Seç" }}
                </button>
                <div class="mt-2 text-xs text-emerald-200">
                    .xlsx, .xls, .csv dosyaları desteklenir
                </div>
            </div>

            <!-- Upload Progress -->
            <div v-if="uploadProgress > 0 && uploadProgress < 100" class="mt-2">
                <div class="flex justify-between text-xs mb-1">
                    <span>İşleniyor...</span>
                    <span>{{ uploadProgress }}%</span>
                </div>
                <div
                    class="w-full bg-neutral-200 dark:bg-neutral-700 rounded-full h-1"
                >
                    <div
                        class="bg-blue-600 h-1 rounded-full"
                        :style="{ width: uploadProgress + '%' }"
                    ></div>
                </div>
            </div>

            <!-- Upload Result -->
            <div
                v-if="uploadResult"
                class="mt-2 p-2 text-xs rounded"
                :class="
                    uploadResult.success
                        ? 'bg-green-100 dark:bg-green-900/20 text-green-800 dark:text-green-300'
                        : 'bg-red-100 dark:bg-red-900/20 text-red-800 dark:text-red-300'
                "
            >
                {{ uploadResult.message }}
            </div>
        </div>

        <!-- Manual Text Input -->
        <div class="mb-4">
            <div class="text-sm font-medium mb-2 text-emerald-200">
                Manuel Metin Ekle
            </div>
            <textarea
                v-model="vectorTexts"
                placeholder="Her satıra bir metin..."
                rows="3"
                class="w-full px-3 py-2 text-sm rounded bg-white/10 border border-emerald-500/30 placeholder-emerald-200 text-white focus:outline-none focus:ring-2 focus:ring-emerald-500 backdrop-blur-sm"
            ></textarea>
            <button
                @click="addVectors"
                :disabled="!vectorTexts.trim() || isAddingVectors"
                class="mt-2 w-full px-3 py-2 text-sm bg-gradient-to-r from-emerald-500 to-green-600 text-white rounded hover:from-emerald-600 hover:to-green-700 disabled:opacity-50 transition-all duration-300 hover:scale-105 shadow-lg"
            >
                {{ isAddingVectors ? "Ekleniyor..." : "Vektör Ekle" }}
            </button>
        </div>

        <!-- Results -->
        <div
            v-if="addResult"
            class="mb-4 p-3 text-sm rounded"
            :class="
                addResult.success
                    ? 'bg-emerald-500/20 text-emerald-200 border border-emerald-500/30'
                    : 'bg-red-500/20 text-red-200 border border-red-500/30'
            "
        >
            {{
                addResult.success
                    ? `${addResult.successful}/${addResult.total} eklendi`
                    : "Hata oluştu"
            }}
        </div>
    </div>
</template>

<script setup>
const systemStore = useSystemStore();

const vectorTexts = ref("");
const vectorStatus = ref(null);
const addResult = ref(null);
const uploadResult = ref(null);
const isLoadingStatus = ref(false);
const isAddingVectors = ref(false);
const isUploading = ref(false);
const uploadProgress = ref(0);
const fileInput = ref(null);

const loadVectorStatus = async () => {
    isLoadingStatus.value = true;
    try {
        const result = await systemStore.getVectorStatus();
        vectorStatus.value = result;
    } catch (error) {
        console.error("Vektör durumu yüklenemedi:", error);
    } finally {
        isLoadingStatus.value = false;
    }
};

const handleFileUpload = async (event) => {
    const file = event.target.files[0];
    if (!file) return;

    isUploading.value = true;
    uploadProgress.value = 0;
    uploadResult.value = null;

    try {
        const formData = new FormData();
        formData.append("file", file);

        // Simulate progress
        const progressInterval = setInterval(() => {
            if (uploadProgress.value < 90) {
                uploadProgress.value += 10;
            }
        }, 100);

        console.log("🔍 Excel dosyası yükleniyor...");
        const response = await fetch("/api/vectors/upload-excel", {
            method: "POST",
            body: formData,
        });
        console.log("🔍 Excel yükleme yanıtı:", response.status);

        clearInterval(progressInterval);
        uploadProgress.value = 100;

        const result = await response.json();

        if (response.ok) {
            uploadResult.value = {
                success: true,
                message: `✅ ${result.successful} çalışan başarıyla eklendi${
                    result.details
                        ? ` (${result.details.toplam_satir} satır işlendi)`
                        : ""
                } - Eski veriler otomatik olarak temizlendi`,
            };
            await loadVectorStatus();
        } else {
            uploadResult.value = {
                success: false,
                message: result.error || "Dosya yüklenirken hata oluştu",
            };
        }
    } catch (error) {
        uploadResult.value = {
            success: false,
            message: "Dosya yüklenirken hata oluştu: " + error.message,
        };
    } finally {
        isUploading.value = false;
        uploadProgress.value = 0;
        // Reset file input
        if (fileInput.value) {
            fileInput.value.value = "";
        }
    }
};

const addVectors = async () => {
    if (!vectorTexts.value.trim()) return;

    isAddingVectors.value = true;
    try {
        const texts = vectorTexts.value
            .split("\n")
            .filter((text) => text.trim());
        const result = await systemStore.populateVectors(texts);
        addResult.value = result;
        vectorTexts.value = "";
        await loadVectorStatus();
    } catch (error) {
        addResult.value = { success: false, error: error.message };
    } finally {
        isAddingVectors.value = false;
    }
};

const formatBytes = (bytes) => {
    if (bytes === 0) return "0 B";
    const k = 1024;
    const sizes = ["B", "KB", "MB", "GB"];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + " " + sizes[i];
};

onMounted(() => {
    loadVectorStatus();
});
</script>
