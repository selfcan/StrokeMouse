<script setup lang="ts">
import type { Component } from 'vue'
import {
  Menu,
  Sparkles,
  MousePointer2,
  AppWindow,
  Zap,
  Languages,
  FolderInput,
  type LucideIcon,
} from 'lucide-vue-next'

export interface FeatureItem {
  icon: string
  title: string
  desc: string
}

const iconMap: Record<string, LucideIcon> = {
  menu: Menu,
  sparkles: Sparkles,
  mouse: MousePointer2,
  window: AppWindow,
  zap: Zap,
  languages: Languages,
  import: FolderInput,
}

defineProps<{
  heading?: string
  subheading?: string
  items: FeatureItem[]
}>()

function resolveIcon(name: string): Component {
  return iconMap[name] ?? Sparkles
}
</script>

<template>
  <section class="hd-feature-grid">
    <header v-if="heading || subheading" class="hd-fg-header">
      <div v-if="subheading" class="hd-fg-kicker">
        <span>{{ subheading }}</span>
      </div>
      <h2 v-if="heading" class="hd-fg-heading">{{ heading }}</h2>
    </header>
    <div class="hd-fg-list">
      <article v-for="(item, i) in items" :key="i" class="hd-fg-card">
        <div class="hd-fg-top">
          <div class="hd-fg-icon-wrap" aria-hidden="true">
            <component :is="resolveIcon(item.icon)" class="hd-fg-icon" :size="18" :stroke-width="1.75" />
          </div>
          <span class="hd-fg-idx">#0{{ i + 1 }}</span>
        </div>
        <h3 class="hd-fg-title">{{ item.title }}</h3>
        <p class="hd-fg-desc">{{ item.desc }}</p>
      </article>
    </div>
  </section>
</template>

<style scoped>
.hd-feature-grid {
  margin: 2.5rem 0 2rem;
}

.hd-fg-header {
  margin-bottom: 1.25rem;
}

.hd-fg-kicker {
  display: flex;
  align-items: center;
  color: var(--spot);
  font-family: var(--mono);
  font-size: 11px;
  letter-spacing: 0.12em;
  text-transform: uppercase;
  margin-bottom: 8px;
}

.hd-fg-heading {
  margin: 0;
  font-family: var(--disp);
  font-size: 1.5rem;
  font-weight: 800;
  letter-spacing: -0.03em;
  color: var(--ink);
}

.hd-fg-list {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  border: 1px solid var(--line2);
  background: var(--bg);
}

.hd-fg-card {
  padding: 24px 20px;
  border-right: 1px solid var(--line);
  border-bottom: 1px solid var(--line);
  background: var(--panel);
  display: flex;
  flex-direction: column;
  gap: 8px;
  transition: background-color 0.12s ease;
  box-sizing: border-box;
}

.hd-fg-card:nth-child(3n) {
  border-right: 0;
}

.hd-fg-card:hover {
  background: color-mix(in srgb, var(--spot) 5%, var(--panel));
}

.hd-fg-top {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 4px;
}

.hd-fg-icon-wrap {
  color: var(--spot);
}

.hd-fg-idx {
  font-family: var(--mono);
  font-size: 10.5px;
  letter-spacing: 0.1em;
  color: var(--faint);
}

.hd-fg-title {
  margin: 0;
  font-family: var(--disp);
  font-size: 16px;
  font-weight: 800;
  letter-spacing: -0.02em;
  color: var(--ink);
}

.hd-fg-desc {
  margin: 0;
  font-family: var(--body);
  font-size: 13.5px;
  line-height: 1.6;
  color: var(--dim);
}

@media (max-width: 860px) {
  .hd-fg-list {
    grid-template-columns: 1fr 1fr;
  }
  .hd-fg-card:nth-child(3n) {
    border-right: 1px solid var(--line);
  }
  .hd-fg-card:nth-child(2n) {
    border-right: 0;
  }
}

@media (max-width: 560px) {
  .hd-fg-list {
    grid-template-columns: 1fr;
  }
  .hd-fg-card {
    border-right: 0 !important;
  }
}
</style>
