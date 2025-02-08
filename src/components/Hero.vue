<script setup>
import { ArrowDown } from 'lucide-vue-next';
import imgBg from '/assets/img/cloud-bg.jpg';
import imgMediator from '/assets/img/mediator.jpg';

const props = defineProps({
  data: {
    type: Object,
    required: true
  }
});
const bgImage = `url(${imgBg})`;

</script>
<template>
  <div id="home" class="min-h-screen flex items-center justify-center text-center relative">
    <div :style="{ backgroundImage: bgImage }" class="absolute inset-0 parallax"></div>
    <div class="parallax-overlay"></div>
    <div class="relative z-10 text-white text-center px-4">
      <div class="max-w-7xl mx-auto px-4">
        <div class="grid md:grid-cols-2 gap-12 items-center">
          <div>
            <img :src="imgMediator" alt="Mediátor" class="rounded-lg shadow-xl">
          </div>
          <div>
            <h2 class="text-4xl font-bold mb-6">"{{ data.title }}" </h2><!-- <span class="text-4xl">{{ data.subtitle }}</span> -->
            <p class="text-lg text-justify mb-6">
              {{ data.p1 }}
            </p>
            <p class="text-lg text-justify mb-6">
              {{ data.p2 }}
            </p>
            <ArrowDown class="w-8 h-8 mx-auto animate-bounce" />
          </div>
        </div>
      </div>      
    </div>
  </div>
</template>