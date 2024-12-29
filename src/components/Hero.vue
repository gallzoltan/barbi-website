<script setup>
import { ArrowDown } from 'lucide-vue-next';
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
  <div id="home" class="min-h-screen flex items-center justify-center text-center relative">
    <div :style="{ backgroundImage: bgImage }" class="absolute inset-0 parallax"></div>
    <div class="parallax-overlay"></div>
    <div class="relative z-10 text-white text-center px-4">
          <h1 class="text-5xl md:text-7xl font-bold mb-6">{{ data.title }}</h1>
          <p class="text-xl md:text-2xl mb-8">{{ data.subtitle }}</p>
          <ArrowDown class="w-8 h-8 mx-auto animate-bounce" />
        </div>
  </div>
</template>