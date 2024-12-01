<script setup>
import { Award } from 'lucide-vue-next';
</script>

<template>
  <div id="about" class="py-20 bg-white">
    <div class="max-w-7xl mx-auto px-4">
      <div class="grid md:grid-cols-2 gap-12 items-center">
        <div>
          <img src="/images/mediator.jpg" alt="Mediátor" class="rounded-lg shadow-xl">
        </div>
        <div>
          <h2 class="text-4xl font-bold text-gray-900 mb-6">Rólam</h2>
          <p class="text-lg text-justify text-gray-600 mb-6">
            Gállné Busai Barbara vagyok. Keresztény, feleség, mediátor, alternatív vitarendező. 
            Fontosak számomra az emberi kapcsolatok, a minőségi kommunikáció és a felmerülő problémák megoldása. 
            Specializációm az emberek közötti kapcsolat- és bizalomépítés, ahol segítek a feleknek közös megoldást találni, és ezzel segítem Isten országának építését.
          </p>
          <!-- <p class="text-lg text-justify text-gray-600 mb-6">
            Specializációim közé tartozik a családi mediáció, üzleti konfliktusok kezelése és 
            munkajogi viták rendezése.
          </p> -->
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