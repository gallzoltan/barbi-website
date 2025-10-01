<script setup>
import bg from '/assets/img/bg_princesses_2.jpg';

const props = defineProps({
  data: {
    type: Object,
    required: true
  }
});
const bgImage = `url(${bg})`;
</script>

<template>
  <div id="princesses" class="min-h-screen flex items-center relative py-section">
    <div :style="{ backgroundImage: bgImage }" class="absolute inset-0 parallax"></div>
    <div class="parallax-overlay"></div>
    <div class="mx-auto z-10 text-white text-center px-4">
      <h2 class="text-4xl font-bold text-white mb-16">{{ data.title }}</h2>
      <div class="bg-white/90 backdrop-blur-sm p-8 rounded-lg shadow-lg">
        <p class="mb-5 text-base text-gray-700 sm:text-lg">{{ data.description }}</p>
        <div class="max-w-2xl mx-auto">
          <h2 class="mb-5 text-xl text-left font-extrabold tracking-tight text-gray-900">Témáink:</h2>
          <ul role="list" class="space-y-4 text-gray-700">
            <li class="flex space-x-2 rtl:space-x-reverse items-center" v-for="(topic, index) in data.topics" :key="topic.index">
              <svg class="shrink-0 w-3.5 h-3.5 text-orange-600" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="currentColor" viewBox="0 0 20 20">
                <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="m10 16 4-4-4-4"/>
              </svg>
              <span class="leading-tight">{{ topic }}</span>
            </li>
          </ul>
        </div>
      </div>
    </div>
  </div>
</template>