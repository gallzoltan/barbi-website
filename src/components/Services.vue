<script setup>
import imgURL from '../assets/img/hero-bg.jpg';

const props = defineProps({
  data: {
    type: Array,
    required: true
  }
});
const bgImage = `url(${imgURL})`;
</script>

<template>
  <div id="services" class="min-h-screen flex items-center relative py-20">
    <!-- <div class="absolute inset-0 parallax bg-[url('/assets/img/hero-bg.jpg')]"></div> -->
    <div :style="{ backgroundImage: bgImage }" class="absolute inset-0 parallax"></div>
    <div class="parallax-overlay"></div>
    <div class="relative z-10 max-w-7xl mx-auto px-4">
      <h2 class="text-4xl font-bold text-white text-center mb-16">Szolgáltatások</h2>
      <div class="grid md:grid-cols-3 gap-8">
        <div v-for="service in data" :key="service.id" class="bg-white/10 backdrop-blur-sm p-8 rounded-lg">
          <h3 class="text-2xl font-semibold text-white mb-4">
            {{ service.title }}
          </h3>
          <p class="text-white/90">
            {{ service.description }}
          </p>
        </div>
      </div>
    </div>
  </div>
</template>