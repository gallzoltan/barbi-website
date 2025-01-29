<script setup>
import { Award } from 'lucide-vue-next';
// import imgURL from '/assets/img/mediator.jpg';
const props = defineProps({
  data: {
    type: Object,
    required: true
  }
});
</script>

<template>
  <div id="about" class="py-20 dark:bg-teal-50 ">
    <div class="max-w-sm mx-auto px-4">
      <h2 class="text-2xl font-bold text-center mb-16">{{ data.title }}</h2>
      <ol class="relative border-s border-gray-200 dark:border-gray-700">
        <li class="mb-10 ms-6" v-for="item in data.main_educations" :key="item.id">            
          <span class="absolute flex items-center justify-center w-6 h-6 bg-blue-100 rounded-full -start-3 ring-white dark:bg-teal-100">
            <svg class="w-2.5 h-2.5 text-blue-800 dark:text-blue-700" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="currentColor" viewBox="0 0 20 20">
              <path d="M20 4a2 2 0 0 0-2-2h-2V1a1 1 0 0 0-2 0v1h-3V1a1 1 0 0 0-2 0v1H6V1a1 1 0 0 0-2 0v1H2a2 2 0 0 0-2 2v2h20V4ZM0 18a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2V8H0v10Zm5-8h10a1 1 0 0 1 0 2H5a1 1 0 0 1 0-2Z"/>
            </svg>
          </span>
          <h3 class="flex items-center mb-1 text-lg font-semibold text-gray-900 dark:text-grey">{{ item.title }}</h3>
          <time class="block mb-2 text-sm font-normal leading-none text-gray-400 dark:text-gray-500">{{ item.date }}</time>
          <p class="mb-4 text-base font-normal text-gray-500 dark:text-gray-400">{{ item.description }}</p>            
        </li>
      </ol>  
      <h2 class="text-2xl font-bold text-center mb-16">{{ data.other_title }}</h2>
      <ol class="relative border-s border-gray-200 dark:border-gray-700">
        <li class="mb-10 ms-6" v-for="item in data.other_educations" :key="item.id">            
          <span class="absolute flex items-center justify-center w-6 h-6 bg-blue-100 rounded-full -start-3 ring-white dark:bg-teal-100">
            <svg class="w-2.5 h-2.5 text-blue-800 dark:text-blue-700" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="currentColor" viewBox="0 0 20 20">
              <path d="M20 4a2 2 0 0 0-2-2h-2V1a1 1 0 0 0-2 0v1h-3V1a1 1 0 0 0-2 0v1H6V1a1 1 0 0 0-2 0v1H2a2 2 0 0 0-2 2v2h20V4ZM0 18a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2V8H0v10Zm5-8h10a1 1 0 0 1 0 2H5a1 1 0 0 1 0-2Z"/>
            </svg>
          </span>
          <h3 class="flex items-center mb-1 text-lg font-semibold text-gray-900 dark:text-grey">{{ item.title }}</h3>
          <time class="block mb-2 text-sm font-normal leading-none text-gray-400 dark:text-gray-500">{{ item.date }}</time>
          <p class="mb-4 text-base font-normal text-gray-500 dark:text-gray-400">{{ item.description }}</p>            
        </li>
      </ol>   
    </div>
  </div>
</template>