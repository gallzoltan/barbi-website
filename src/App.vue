<script setup>
import { ref, onMounted } from 'vue';
import NavBar from './components/NavBar.vue'
import Hero from './components/Hero.vue'
import About from './components/About.vue'
import Services from './components/Services.vue'
import Princesses from './components/Princesses.vue';
import Currents from './components/Currents.vue';
import Contact from './components/Contact.vue'
import Footer from './components/Footer.vue'

const heroData = ref({});
const aboutData = ref([]);
const servicesData = ref([]);
const princessesData = ref({});
const currentsData = ref([]);
const contactData = ref({});
const footerData = ref({});

onMounted(async () => {
  const response = await fetch('/database.json');
  const data = await response.json();
  heroData.value = data.hero;
  aboutData.value = data.about;
  servicesData.value = data.services;
  princessesData.value = data.princesses; 
  currentsData.value = data.currents;
  contactData.value = data.contact; 
  footerData.value = data.footer;
});
</script>

<template>
  <NavBar />
  <Hero :data="heroData" />
  <About :data="aboutData"/>
  <Services :data="servicesData"/>
  <Princesses :data="princessesData"/>
  <Currents :data="currentsData"/>
  <Contact :data="contactData"/>
  <Footer :data="footerData"/>
</template>