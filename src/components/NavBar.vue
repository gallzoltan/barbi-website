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
    <div class="max-w-6xl mx-auto px-4">
      <div class="flex justify-between items-center">
        <div :class="['text-xl font-bold', isScrolled ? 'text-gray-800' : 'text-white']">Gállné Busai Barbara</div>
        
        <div class="hidden md:flex space-x-8">
          <a href="#home" :class="['hover:opacity-75 transition-opacity focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 rounded', isScrolled ? 'text-gray-800' : 'text-white']">Kezdőlap</a>
          <a href="#about" :class="['hover:opacity-75 transition-opacity focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 rounded', isScrolled ? 'text-gray-800' : 'text-white']">Rólam</a>
          <a href="#services" :class="['hover:opacity-75 transition-opacity focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 rounded', isScrolled ? 'text-gray-800' : 'text-white']">Keresztény konfliktusmegoldás</a>
          <a href="#princesses" :class="['hover:opacity-75 transition-opacity focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 rounded', isScrolled ? 'text-gray-800' : 'text-white']">Áldott Királylányok</a>
          <a href="#currents" :class="['hover:opacity-75 transition-opacity focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 rounded', isScrolled ? 'text-gray-800' : 'text-white']">Aktuális</a>
          <a href="#contact" :class="['hover:opacity-75 transition-opacity focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 rounded', isScrolled ? 'text-gray-800' : 'text-white']">Kapcsolat</a>
        </div>

        <button
          @click="isMenuOpen = !isMenuOpen"
          class="md:hidden p-3 min-w-[44px] min-h-[44px] flex items-center justify-center focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 rounded"
          :class="isScrolled ? 'text-gray-800' : 'text-white'"
          aria-label="Menü megnyitása"
          :aria-expanded="isMenuOpen"
        >
          <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24" aria-hidden="true">
            <path v-if="!isMenuOpen" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
            <path v-else stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
          </svg>
        </button>
      </div>
    </div>

    <div v-if="isMenuOpen" class="md:hidden bg-white shadow-md">
      <div class="px-2 pt-2 pb-3 space-y-1 sm:px-3">
        <a href="#home" class="block px-3 py-3 text-gray-800 hover:bg-gray-100 rounded focus:outline-none focus:ring-2 focus:ring-inset focus:ring-primary-500">Kezdőlap</a>
        <a href="#about" class="block px-3 py-3 text-gray-800 hover:bg-gray-100 rounded focus:outline-none focus:ring-2 focus:ring-inset focus:ring-primary-500">Rólam</a>
        <a href="#services" class="block px-3 py-3 text-gray-800 hover:bg-gray-100 rounded focus:outline-none focus:ring-2 focus:ring-inset focus:ring-primary-500">Keresztény konfliktusmegoldás</a>
        <a href="#princesses" class="block px-3 py-3 text-gray-800 hover:bg-gray-100 rounded focus:outline-none focus:ring-2 focus:ring-inset focus:ring-primary-500">Áldott Királylányok</a>
        <a href="#currents" class="block px-3 py-3 text-gray-800 hover:bg-gray-100 rounded focus:outline-none focus:ring-2 focus:ring-inset focus:ring-primary-500">Aktuális</a>
        <a href="#contact" class="block px-3 py-3 text-gray-800 hover:bg-gray-100 rounded focus:outline-none focus:ring-2 focus:ring-inset focus:ring-primary-500">Kapcsolat</a>
      </div>
    </div>
  </nav>
</template>