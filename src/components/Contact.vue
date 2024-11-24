<template>
  <div id="contact" class="py-20 bg-gray-50">
    <div class="max-w-4xl mx-auto px-4">
      <h2 class="text-4xl font-bold text-gray-900 text-center mb-12">Kapcsolat</h2>
      <div class="bg-white rounded-lg shadow-xl p-8">
        <form @submit.prevent="handleSubmit" class="space-y-6">
          <div>
            <label for="name" class="block text-sm font-medium text-gray-700">Név</label>
            <input type="text" id="name" name="name" class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500">
          </div>
          <div>
            <label for="email" class="block text-sm font-medium text-gray-700">Email</label>
            <input type="email" id="email" name="email" class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500">
          </div>
          <div>
            <label for="message" class="block text-sm font-medium text-gray-700">Üzenet</label>
            <textarea id="message" name="message" rows="4" class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"></textarea>
          </div>
          <button type="submit" class="w-full bg-blue-600 text-white px-6 py-3 rounded-md hover:bg-blue-700 transition-colors">
            Üzenet küldése
          </button>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup>
const handleSubmit = () => {
  // Itt lehet implementálni az űrlap küldési logikát
  console.log('Form submitted')
}
</script>