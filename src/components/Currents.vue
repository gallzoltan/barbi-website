<script setup>
import 'vue3-carousel/dist/carousel.css';
import { Carousel, Slide, Navigation } from 'vue3-carousel';

const props = defineProps({
  data: {
    type: Object,
    required: true
  }
});
</script>

<template>
  <div id="currents" class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
    <h2 class="text-2xl font-bold text-center mb-8">Aktuális</h2>
    <Carousel :items-to-show="1.2" :wrap-around="true" :transition="500" class="max-w-4xl mx-auto">
      <Slide v-for="event in data" :key="event.id">
        <div class="carousel__item mx-2">
          <div class="bg-white rounded-lg shadow-lg overflow-hidden">
            <img :src="event.image" :alt="event.title" class="w-full h-48 object-cover">
            <div class="p-6">
              <h3 class="text-xl font-semibold mb-2">{{ event.title }}</h3>
              <p class="text-gray-600 mb-2">{{ event.date }}</p>
              <p class="text-gray-600 font-semibold">Helyszín: {{ event.location }}</p>
              <p class="text-gray-700">{{ event.description }}</p>
              <template v-if="event.link">
                A jelentkezéseket legkésőbb március 7-ig várjuk
                <a :href="event.link" target="_blank" class="text-blue-500 font-semibold mt-4">ezen az űrlapon.</a>
              </template>
            </div>
          </div>
        </div>
      </Slide>
      <template #addons>
        <Navigation />
      </template>
    </Carousel>
  </div>
</template>

<style scoped>
.carousel__item {
  min-height: 500px;
  width: 100%;
}
</style>