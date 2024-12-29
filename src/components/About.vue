<script setup>
import { Award } from 'lucide-vue-next';
import imgURL from '/src/assets/img/mediator.jpg';
const props = defineProps({
  data: {
    type: Object,
    required: true
  }
});
</script>

<template>
  <div id="about" class="py-20 bg-white">
    <div class="max-w-7xl mx-auto px-4">
      <div class="grid md:grid-cols-2 gap-12 items-center">
        <div>
          <img :src="imgURL" alt="Mediátor" class="rounded-lg shadow-xl">
        </div>
        <div>
          <h2 class="text-4xl font-bold text-gray-900 mb-6">{{ data.title }}</h2>
          <p class="text-lg text-justify text-gray-600 mb-6">
            {{ data.description }}
          </p>
          <ul class="space-y-3">
            <li class="flex items-center">
              <Award class="w-6 h-6 text-blue-600" />
              <span class="text-gray-700">Akkreditált Mediátor</span>
            </li>
          </ul>
        </div>
      </div>
    </div>
  </div>
</template>