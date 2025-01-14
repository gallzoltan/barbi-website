<script setup>
import { ref, onMounted } from 'vue';
import NavBar from './components/NavBar.vue'
import Hero from './components/Hero.vue'
import About from './components/About.vue'
import Services from './components/Services.vue'
import Contact from './components/Contact.vue'
import Footer from './components/Footer.vue'

const heroData = ref({});
const aboutData = ref([]);
const servicesData = ref([]);
const footerData = ref({});

onMounted(async () => {
  const response = await fetch('/database.json');
  const data = await response.json();
  heroData.value = data.hero;
  aboutData.value = data.about;
  servicesData.value = data.services;  
  footerData.value = data.footer;
});
</script>

<template>
  <NavBar />
  <Hero :data="heroData"/>
  <About :data="aboutData"/>
  <Services :data="servicesData"/>
  <Contact />
  <Footer :data="footerData"/>
</template>