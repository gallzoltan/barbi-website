<script setup>
import { ref } from 'vue'
import { onMounted, onUnmounted } from 'vue'

const isMenuOpen = ref(false);
const isScrolled = ref(false);

onMounted(() => {
  const handleScroll = () => {
    isScrolled.value = window.scrollY > 50;
  };
  window.addEventListener('scroll', handleScroll);
  onUnmounted(() => {
    window.removeEventListener('scroll', handleScroll);
  });
});
</script>

<template>
  <!-- <nav class="fixed w-full bg-white/90 backdrop-blur-sm z-50 shadow-md"> -->    
  <nav :class="['fixed w-full z-50 transition-all duration-300', isScrolled ? 'bg-white shadow-md py-2' : 'bg-transparent py-4' ]">
    <div class="max-w-7xl mx-auto px-4">
      <div class="flex justify-between items-center h-16">
        <div :class="['text-xl font-bold', isScrolled ? 'text-gray-800' : 'text-white']">Gállné Busai Barbara</div>
        
        <div class="hidden md:flex space-x-8">
          <a href="#home" :class="['hover:opacity-75 transition-opacity', isScrolled ? 'text-gray-800' : 'text-white']">Kezdőlap</a>
          <a href="#about" :class="['hover:opacity-75 transition-opacity', isScrolled ? 'text-gray-800' : 'text-white']">Rólam</a>
          <a href="#services" :class="['hover:opacity-75 transition-opacity', isScrolled ? 'text-gray-800' : 'text-white']">Szolgáltatások</a>
          <a href="#contact" :class="['hover:opacity-75 transition-opacity', isScrolled ? 'text-gray-800' : 'text-white']">Kapcsolat</a>
        </div>

        <button @click="isMenuOpen = !isMenuOpen" class="md:hidden">
          <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path v-if="!isMenuOpen" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
            <path v-else stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
          </svg>
        </button>
      </div>
    </div>

    <div v-if="isMenuOpen" class="md:hidden">
      <div class="px-2 pt-2 pb-3 space-y-1 sm:px-3">
        <a href="#home" class="block px-3 py-2 text-gray-600 hover:text-gray-900">Kezdőlap</a>
        <a href="#about" class="block px-3 py-2 text-gray-600 hover:text-gray-900">Rólam</a>
        <a href="#services" class="block px-3 py-2 text-gray-600 hover:text-gray-900">Szolgáltatások</a>
        <a href="#contact" class="block px-3 py-2 text-gray-600 hover:text-gray-900">Kapcsolat</a>
      </div>
    </div>
  </nav>
</template>