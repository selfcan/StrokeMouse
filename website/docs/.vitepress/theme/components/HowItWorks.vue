<script setup lang="ts">
import { computed } from 'vue'
import { generalUiCopy, useSiteLocale } from '../i18n'

export interface HowStep {
  title: string
  desc: string
}

defineProps<{
  heading: string
  steps: HowStep[]
}>()

const locale = useSiteLocale()
const generalCopy = computed(() => generalUiCopy(locale.value))
</script>

<template>
  <section class="hd-how">
    <div class="hd-how-header">
      <h2 class="hd-how-title">{{ heading }}</h2>
    </div>

    <div class="hd-how-grid">
      <div v-for="(step, i) in steps" :key="i" class="hd-how-card">
        <div class="hd-how-n">
          <span>0{{ i + 1 }}</span>
        </div>
        <div class="hd-how-content">
          <h3 class="hd-how-card-title">{{ step.title }}</h3>
          <p class="hd-how-desc">{{ step.desc }}</p>
        </div>
      </div>
    </div>
  </section>
</template>

<style scoped>
.hd-how {
  padding: 48px var(--gut);
  border-bottom: 1px solid var(--line2);
  background: var(--bg);
}

.hd-how-header {
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

.hd-how-title {
  font-family: var(--disp);
  font-weight: 900;
  font-size: clamp(26px, 3.5vw, 44px);
  letter-spacing: -0.04em;
  color: var(--ink);
  line-height: 1.05;
  margin: 0;
}

.hd-how-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  border: 1px solid var(--line2);
  background: var(--bg);
}

.hd-how-card {
  padding: 24px 20px;
  border-right: 1px solid var(--line);
  background: var(--panel);
  display: flex;
  flex-direction: column;
  gap: 14px;
  transition: background-color 0.12s ease;
}

.hd-how-card:last-child {
  border-right: 0;
}

.hd-how-card:hover {
  background: color-mix(in srgb, var(--spot) 4%, var(--panel));
}

.hd-how-n span {
  font-family: var(--disp);
  font-weight: 900;
  font-size: 34px;
  letter-spacing: -0.05em;
  line-height: 1;
  color: var(--line2);
  transition: color 0.12s ease;
}

.hd-how-card:hover .hd-how-n span {
  color: var(--spot);
}

.hd-how-card-title {
  font-family: var(--disp);
  font-weight: 800;
  font-size: 17px;
  letter-spacing: -0.02em;
  color: var(--ink);
  margin: 0 0 6px;
}

.hd-how-desc {
  font-family: var(--body);
  font-size: 13.5px;
  line-height: 1.6;
  color: var(--dim);
  margin: 0;
}

@media (max-width: 860px) {
  .hd-how-grid {
    grid-template-columns: 1fr;
  }
  .hd-how-card {
    border-right: 0;
    border-bottom: 1px solid var(--line);
  }
  .hd-how-card:last-child {
    border-bottom: 0;
  }
}
</style>
