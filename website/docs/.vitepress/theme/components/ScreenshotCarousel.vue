<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { Swiper, SwiperSlide } from 'swiper/vue'
import { Autoplay, Navigation, Pagination } from 'swiper/modules'
import type { Swiper as SwiperType } from 'swiper'
import { generalUiCopy, useSiteLocale } from '../i18n'

import 'swiper/css'
import 'swiper/css/navigation'
import 'swiper/css/pagination'

export interface Shot {
  src: string
  alt: string
}

const props = withDefaults(
  defineProps<{
    heading?: string
    description?: string
    shots?: Shot[]
  }>(),
  {
    shots: () => [
      { src: '/screenshots/1.png', alt: 'Gesture library' },
      { src: '/screenshots/2.png', alt: 'Gesture test' },
      { src: '/screenshots/3.png', alt: 'General settings' },
      { src: '/screenshots/4.png', alt: 'Permissions' },
      { src: '/screenshots/5.png', alt: 'Record stroke' },
      { src: '/screenshots/6.png', alt: 'App scope' },
    ],
  },
)

const locale = useSiteLocale()
const generalCopy = computed(() => generalUiCopy(locale.value))

const modules = [Autoplay, Navigation, Pagination]
const active = ref(0)
const swiperRef = ref<SwiperType | null>(null)
const reducedMotion = ref(false)

onMounted(() => {
  reducedMotion.value = window.matchMedia('(prefers-reduced-motion: reduce)').matches
})

const autoplay = computed(() =>
  reducedMotion.value
    ? false
    : {
        delay: 4500,
        disableOnInteraction: false,
        pauseOnMouseEnter: true,
      },
)

function onSwiper(swiper: SwiperType) {
  swiperRef.value = swiper
}

function goTo(i: number) {
  swiperRef.value?.slideToLoop(i)
}

function onSlideChange(swiper: SwiperType) {
  active.value = swiper.realIndex
}
</script>

<template>
  <section class="hd-shots">
    <div v-if="heading || description" class="hd-shots-header">
      <h2 v-if="heading" class="hd-shots-title">{{ heading }}</h2>
      <p v-if="description" class="hd-shots-lead">{{ description }}</p>
    </div>

    <div class="hd-shots-frame">
      <!-- Top Chrome Bar -->
      <div class="hd-shots-bar">
        <div class="hd-shots-bar-left">
          <span class="hd-shots-dot" />
          <span class="hd-shots-dot" />
          <span class="hd-shots-dot" />
          <span class="hd-shots-title-text">
            {{ shots[active]?.alt || 'StrokeMouse UI' }}
          </span>
        </div>

        <div class="hd-shots-controls">
          <button type="button" class="hd-shot-nav hd-shot-prev" aria-label="Previous">
            ←
          </button>
          <span class="hd-shot-counter">0{{ active + 1 }} / 0{{ shots.length }}</span>
          <button type="button" class="hd-shot-nav hd-shot-next" aria-label="Next">
            →
          </button>
        </div>
      </div>

      <!-- Swiper Stage -->
      <div class="hd-shots-stage">
        <Swiper
          :modules="modules"
          :slides-per-view="1"
          :loop="true"
          :speed="400"
          :autoplay="autoplay"
          :navigation="{
            nextEl: '.hd-shot-next',
            prevEl: '.hd-shot-prev',
          }"
          class="hd-shots-swiper"
          @swiper="onSwiper"
          @slide-change="onSlideChange"
        >
          <SwiperSlide v-for="shot in props.shots" :key="shot.src">
            <div class="hd-shot-slide">
              <img
                :src="shot.src"
                :alt="shot.alt"
                loading="lazy"
                decoding="async"
              />
            </div>
          </SwiperSlide>
        </Swiper>
      </div>

      <!-- Thumbnails / Index Row -->
      <div class="hd-shots-thumbs">
        <button
          v-for="(shot, i) in props.shots"
          :key="shot.src"
          type="button"
          class="hd-thumb-btn"
          :class="{ active: active === i }"
          @click="goTo(i)"
        >
          <span class="hd-thumb-n">0{{ i + 1 }}</span>
          <span class="hd-thumb-name">{{ shot.alt }}</span>
        </button>
      </div>
    </div>
  </section>
</template>

<style scoped>
.hd-shots {
  padding: 48px var(--gut);
  border-bottom: 1px solid var(--line2);
  background: var(--bg);
}

.hd-shots-header {
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

.hd-shots-title {
  font-family: var(--disp);
  font-weight: 900;
  font-size: clamp(26px, 3.5vw, 44px);
  letter-spacing: -0.04em;
  color: var(--ink);
  line-height: 1.05;
  margin: 0;
}

.hd-shots-lead {
  color: var(--dim);
  font-size: 15px;
  line-height: 1.7;
  max-width: 60ch;
  margin: 12px 0 0;
}

.hd-shots-frame {
  border: 1px solid var(--line2);
  background: var(--panel);
  box-sizing: border-box;
}

.hd-shots-bar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 10px 16px;
  border-bottom: 1px solid var(--line2);
  background: color-mix(in srgb, var(--panel) 94%, black);
  font-size: 11.5px;
}

.hd-shots-bar-left {
  display: flex;
  align-items: center;
  gap: 8px;
}

.hd-shots-dot {
  width: 7px;
  height: 7px;
  border-radius: 50%;
  background: var(--line2);
}

.hd-shots-title-text {
  margin-left: 8px;
  color: var(--ink);
  font-weight: 500;
}

.hd-shots-controls {
  display: flex;
  align-items: center;
  gap: 10px;
}

.hd-shot-nav {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 26px;
  height: 24px;
  border: 1px solid var(--line2);
  background: var(--bg);
  color: var(--dim);
  font-size: 12px;
  cursor: pointer;
  transition: all 0.12s ease;
}

.hd-shot-nav:hover {
  color: var(--spot);
  border-color: var(--spot);
}

.hd-shot-counter {
  font-family: var(--mono);
  font-size: 10.5px;
  color: var(--faint);
  font-variant-numeric: tabular-nums;
  letter-spacing: 0.08em;
}

.hd-shots-stage {
  background: var(--bg);
  padding: 14px;
  line-height: 0;
}

.hd-shots-swiper {
  width: 100%;
}

.hd-shot-slide {
  display: flex;
  justify-content: center;
  align-items: center;
  background: var(--bg);
}

.hd-shot-slide img {
  max-width: 100%;
  height: auto;
  max-height: 500px;
  object-fit: contain;
  display: block;
  border: 1px solid var(--line2);
}

.hd-shots-thumbs {
  display: grid;
  grid-template-columns: repeat(6, 1fr);
  border-top: 1px solid var(--line2);
  background: var(--panel);
}

.hd-thumb-btn {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  gap: 3px;
  padding: 10px 12px;
  border: 0;
  border-right: 1px solid var(--line);
  background: none;
  cursor: pointer;
  text-align: left;
  transition: background-color 0.12s ease;
}

.hd-thumb-btn:last-child {
  border-right: 0;
}

.hd-thumb-btn:hover {
  background: color-mix(in srgb, var(--spot) 6%, transparent);
}

.hd-thumb-btn.active {
  background: color-mix(in srgb, var(--spot) 12%, transparent);
  box-shadow: inset 0 -2px 0 var(--spot);
}

.hd-thumb-n {
  font-family: var(--mono);
  font-size: 10px;
  color: var(--faint);
}

.hd-thumb-btn.active .hd-thumb-n {
  color: var(--spot);
}

.hd-thumb-name {
  font-family: var(--body);
  font-size: 11.5px;
  color: var(--dim);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  width: 100%;
}

.hd-thumb-btn.active .hd-thumb-name {
  color: var(--ink);
  font-weight: 500;
}

@media (max-width: 800px) {
  .hd-shots-thumbs {
    grid-template-columns: repeat(3, 1fr);
  }
  .hd-thumb-btn:nth-child(3n) {
    border-right: 0;
  }
  .hd-thumb-btn:nth-child(-n + 3) {
    border-bottom: 1px solid var(--line);
  }
}

@media (max-width: 500px) {
  .hd-shots-thumbs {
    grid-template-columns: 1fr 1fr;
  }
  .hd-thumb-btn:nth-child(3n) {
    border-right: 1px solid var(--line);
  }
  .hd-thumb-btn:nth-child(2n) {
    border-right: 0;
  }
  .hd-thumb-btn {
    border-bottom: 1px solid var(--line);
  }
}
</style>
