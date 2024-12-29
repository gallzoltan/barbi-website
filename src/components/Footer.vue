<script setup>
const props = defineProps({
  data: {
    type: Object,
    required: true
  }
});
</script>

<template>
  <footer class="bg-gray-900 text-white py-8 px-4">
    <div class="max-w-4xl mx-auto text-center">
      <p class="mb-4">{{ data.copyright }}</p>
      <div class="text-sm text-gray-400">
        {{ data.text }}
      </div>
    </div>
  </footer>
</template>