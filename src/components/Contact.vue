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
    <div class="max-w-4xl mx-auto px-4">
      <h2 class="text-4xl font-bold text-gray-900 text-center mb-12">Kapcsolat</h2>
      <div class="bg-white rounded-lg shadow-xl p-8">
        <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
          <div>
            <p class="text-gray-700 mb-4">{{ data.p1 }}</p>
            <p class="text-gray-700 mb-4">{{ data.p2 }}</p>
            <p class="text-gray-700 mb-4">{{ data.p3 }}</p>
          </div>
          <!-- <div>
            <h3 class="text-2xl font-bold text-gray-900 mb-4">Üzenet küldése</h3>
            <form action="#" method="POST">
              <div class="grid grid-cols-1 gap-4">
                <input type="text" name="name" id="name" placeholder="Név" class="p-4 bg-gray-100 rounded-lg w-full">
                <input type="email" name="email" id="email" placeholder="Email cím" class="p-4 bg-gray-100 rounded-lg w-full">
                <textarea name="message" id="message" placeholder="Üzenet" class="p-4 bg-gray-100 rounded-lg w-full h-32"></textarea>
                <button type="submit" class="bg-blue-500 text-white font-bold py-2 px-4 rounded-lg">Küldés</button>
              </div>
            </form>
          </div> -->
        </div>
      </div>  
    </div>
  </div>
</template>
