<script setup lang="ts">
import { computed } from 'vue'
import GestureTable from './GestureTable.vue'
import { DEFAULT_GESTURE_DEMOS } from '../defaultGestureDemos'
import { gestureName, gestureUi, useSiteLocale } from '../i18n'

const locale = useSiteLocale()

const SHORTCUT: Record<string, string> = {
  up: '⌃↑',
  down: '⌃↓',
}

const columns = computed(() => gestureUi(locale.value).columns)

const rows = computed(() => {
  const trigger = gestureUi(locale.value).trigger
  return DEFAULT_GESTURE_DEMOS.map((d) => {
    const name = gestureName(d.path, locale.value)
    const chord = SHORTCUT[d.path]
    return {
      path: d.path,
      action: chord ? `${name} (${chord})` : name,
      note: trigger,
    }
  })
})

defineProps<{
  heading?: string
  subheading?: string
}>()
</script>

<template>
  <GestureTable
    :heading="heading"
    :subheading="subheading"
    :columns="columns"
    :rows="rows"
  />
</template>
