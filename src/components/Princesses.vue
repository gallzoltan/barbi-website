<script setup>
const props = defineProps({
  data: {
    type: Array,
    required: true
  }
});
</script>

<template>
  <div id="princesses" class="py-20 bg-gray-50">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center bg-white border border-gray-200 rounded-lg shadow-sm sm:p-8 dark:bg-grey-800/50" v-for="item in data" :key="item.id">
      <h5 class="mb-2 text-2xl font-bold text-gray-900 dark:text-grey">{{ item.title }}</h5>
      <p class="mb-5 text-base text-gray-500 sm:text-lg dark:text-gray-400">{{ item.description }}</p>
      <div class="max-w-2xl mx-auto">
        <h2 class="mb-5 text-xl text-left font-extrabold tracking-tight text-gray-900 dark:text-grey">Témáink:</h2>
        <ul role="list" class="space-y-4 text-gray-500 dark:text-gray-400">
          <li class="flex space-x-2 rtl:space-x-reverse items-center" v-for="(topic, index) in item.topics" :key="topic.index">
            <svg class="shrink-0 w-3.5 h-3.5 text-blue-600 dark:text-blue-500" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="currentColor" viewBox="0 0 20 20">
              <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="m10 16 4-4-4-4"/>
            </svg>
            <span class="leading-tight">{{ topic }}</span>
          </li>
        </ul>
      </div>      
    </div>
  </div>
</template>