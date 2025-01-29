<script setup>
const props = defineProps({
  data: {
    type: Object,
    required: true
  }
});
</script>

<template>
  <div id="contact" class="py-20 bg-gray-50">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <h2 class="text-3xl font-bold text-center text-gray-900 mb-8">Kapcsolat</h2>
        <div class="max-w-lg mx-auto">
          <div class="bg-white p-6 rounded-lg shadow-md">
            <div class="text-center">
              <p class="mb-2">Ha kérdése van, vagy szeretne jelentkezni valamelyik programunkra, kérjük, vegye fel velünk a kapcsolatot az alábbi elérhetőségek valamelyikén:</p>
              <p class="mb-2"><strong>Email:</strong> info@busaibarbara.hu</p>
              <p class="mb-2"><strong>Telefon:</strong> +36 30 413 5685</p>
            </div>
          </div>
        </div>
      </div>
  </div>
</template>
