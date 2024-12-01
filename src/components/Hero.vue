<script setup>
import { ArrowDown } from 'lucide-vue-next';
</script>
<template>
  <div id="home" class="min-h-screen flex items-center justify-center text-center relative">
    <div class="absolute inset-0 parallax bg-[url('/images/hero-bg.jpg')]"></div>
    <div class="parallax-overlay"></div>
    <div class="relative z-10 text-white text-center px-4">
          <h1 class="text-5xl md:text-7xl font-bold mb-6">Mediáció és konfliktuskezelés</h1>
          <p class="text-xl md:text-2xl mb-8">A bizalom csodákat tesz</p>
          <!-- <div class="flex justify-center gap-4 mb-12">
            <Scale class="w-8 h-8" />
            <Users class="w-8 h-8" />
            <Scale class="w-8 h-8" />
          </div> -->
          <ArrowDown class="w-8 h-8 mx-auto animate-bounce" />
        </div>
  </div>
</template>