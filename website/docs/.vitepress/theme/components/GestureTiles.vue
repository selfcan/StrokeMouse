<script setup lang="ts">
import { computed } from 'vue'
import GestureStrokeCanvas from './GestureStrokeCanvas.vue'
import { GESTURE_PATHS } from '../gesturePaths'
import { DEFAULT_GESTURE_DEMOS } from '../defaultGestureDemos'
import { generalUiCopy, gestureName, gestureUi, useSiteLocale } from '../i18n'

defineProps<{
  heading: string
  lead?: string
}>()

const locale = useSiteLocale()
const generalCopy = computed(() => generalUiCopy(locale.value))

const tiles = computed(() =>
  DEFAULT_GESTURE_DEMOS.map((d) => ({
    path: d.path,
    action: gestureName(d.path, locale.value),
    trigger: gestureUi(locale.value).trigger,
    points: GESTURE_PATHS[d.path] ?? [],
  })),
)
</script>

<template>
  <section class="hd-presets">
    <div class="hd-presets-header">
      <h2 class="hd-presets-title">{{ heading }}</h2>
      <p v-if="lead" class="hd-presets-lead">{{ lead }}</p>
    </div>

    <div class="hd-presets-grid">
      <article v-for="(tile, i) in tiles" :key="tile.path" class="hd-tile">
        <div class="hd-tile-canvas">
          <GestureStrokeCanvas
            :points="tile.points"
            :width="140"
            :height="95"
            :delay-ms="i * 120"
            :line-width="2.6"
            :start-radius="4"
          />
        </div>
        <div class="hd-tile-info">
          <span class="hd-tile-idx">#0{{ i + 1 }}</span>
          <h3 class="hd-tile-action">{{ tile.action }}</h3>
          <span class="hd-tile-trigger">{{ tile.trigger }}</span>
        </div>
      </article>
    </div>
  </section>
</template>

<style scoped>
.hd-presets {
  padding: 48px var(--gut);
  border-bottom: 1px solid var(--line2);
  background: var(--bg);
}

.hd-presets-header {
  margin-bottom: 28px;
}

.hd-eyebrow {
  display: inline-flex;
  align-items: center;
  color: var(--spot);
  font-family: var(--mono);
  font-size: 11px;
  letter-spacing: 0.14em;
  text-transform: uppercase;
  margin-bottom: 10px;
}

.hd-presets-title {
  font-family: var(--disp);
  font-weight: 900;
  font-size: clamp(26px, 3.5vw, 44px);
  letter-spacing: -0.04em;
  color: var(--ink);
  line-height: 1.05;
  margin: 0;
}

.hd-presets-lead {
  color: var(--dim);
  font-size: 15px;
  line-height: 1.7;
  max-width: 60ch;
  margin: 12px 0 0;
}

.hd-presets-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  border: 1px solid var(--line2);
  background: var(--bg);
}

.hd-tile {
  padding: 18px 16px;
  border-right: 1px solid var(--line);
  border-bottom: 1px solid var(--line);
  background: var(--panel);
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  gap: 12px;
  transition: background-color 0.12s ease;
  box-sizing: border-box;
}

.hd-tile:nth-child(4n) {
  border-right: 0;
}

.hd-tile:hover {
  background: color-mix(in srgb, var(--spot) 5%, var(--panel));
}

.hd-tile-canvas {
  display: flex;
  align-items: center;
  justify-content: center;
  background: var(--bg);
  border: 1px solid var(--line2);
  height: 105px;
  overflow: hidden;
}

.hd-tile-canvas :deep(canvas) {
  display: block;
}

.hd-tile-info {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.hd-tile-idx {
  font-family: var(--mono);
  font-size: 10px;
  letter-spacing: 0.08em;
  color: var(--faint);
  text-transform: uppercase;
}

.hd-tile-action {
  font-family: var(--disp);
  font-weight: 800;
  font-size: 14.5px;
  letter-spacing: -0.02em;
  color: var(--ink);
  margin: 0;
}

.hd-tile-trigger {
  font-family: var(--body);
  font-size: 11px;
  color: var(--spot);
  font-weight: 500;
}

@media (max-width: 960px) {
  .hd-presets-grid {
    grid-template-columns: repeat(2, 1fr);
  }
  .hd-tile:nth-child(4n) {
    border-right: 1px solid var(--line);
  }
  .hd-tile:nth-child(2n) {
    border-right: 0;
  }
}

@media (max-width: 540px) {
  .hd-presets-grid {
    grid-template-columns: 1fr;
  }
  .hd-tile {
    border-right: 0 !important;
  }
}
</style>
