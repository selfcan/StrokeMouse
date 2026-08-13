<script setup lang="ts">
import DefaultTheme from 'vitepress/theme'
import LanguageSwitch from './components/LanguageSwitch.vue'
import SiteFooter from './components/SiteFooter.vue'

const { Layout } = DefaultTheme
</script>

<template>
  <Layout>
    <template #layout-top>
      <div class="sm-backdrop" aria-hidden="true">
        <div class="sm-backdrop__vignette" />
      </div>
      <div class="sm-grain" aria-hidden="true" />
    </template>
    <template #nav-bar-content-after>
      <LanguageSwitch />
    </template>
    <template #nav-screen-content-after>
      <LanguageSwitch variant="screen" />
    </template>
    <template #layout-bottom>
      <SiteFooter />
    </template>
  </Layout>
</template>
