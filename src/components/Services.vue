<script setup>
import imgURL from '/assets/img/bg_conflict.jpg';

const props = defineProps({
  data: {
    type: Array,
    required: true
  }
});
const bgImage = `url(${imgURL})`;
</script>

<template>
  <div id="services" class="min-h-screen flex items-center relative py-section">
    <div :style="{ backgroundImage: bgImage }" class="absolute inset-0 parallax"></div>
    <div class="parallax-overlay"></div>
    <div class="relative z-10 max-w-content mx-auto px-4">
      <h2 class="text-4xl font-bold text-white text-center mb-16">Keresztény konfliktusmegoldás</h2>
      <div class="grid md:grid-cols-2 gap-8">
        <div v-for="service in data" :key="service.id" class="bg-white/90 backdrop-blur-sm p-8 rounded-lg shadow-lg">
          <h3 class="text-2xl font-semibold text-gray-900 mb-4">
            {{ service.title }}
          </h3>
          <p class="text-gray-700 mb-3">
            {{ service.description }}
          </p>
          <p class="text-gray-700">
            {{ service.description2 }}
          </p>
        </div>
      </div>
    </div>
  </div>
</template>