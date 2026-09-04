<script setup lang="ts">
import { computed, ref } from 'vue'
import { useData, useRouter, withBase } from 'vitepress'
import {
  LOCALES,
  LOCALE_KEYS,
  localePath,
  parseRelativePath,
  type LocaleKey,
} from '../../config/locales'
import { rememberLocaleFromHref } from '../localePreference'

const props = withDefaults(
  defineProps<{
    variant?: 'nav' | 'screen'
  }>(),
  { variant: 'nav' },
)

const { page, hash, theme } = useData()
const router = useRouter()
const open = ref(false)

const currentLocale = computed(() => {
  const { locale } = parseRelativePath(page.value.relativePath)
  return locale
})

const currentLabel = computed(() => {
  return LOCALES[currentLocale.value]?.label || '简体中文'
})

const items = computed(() => {
  const { pageId } = parseRelativePath(page.value.relativePath)
  const suffix = hash.value || ''
  return LOCALE_KEYS.map((key: LocaleKey) => {
    const path = pageId === 'index' ? localePath(key, '/') : localePath(key, `/${pageId}`)
    return {
      key,
      label: LOCALES[key].label,
      href: `${path}${suffix}`,
      active: key === currentLocale.value,
    }
  })
})

const ariaLabel = computed(() => theme.value.langMenuLabel || 'Change language')

function go(href: string) {
  open.value = false
  rememberLocaleFromHref(href)
  router.go(href)
}
</script>

<template>
  <div
    v-if="props.variant === 'nav'"
    class="hd-lang"
    @mouseenter="open = true"
    @mouseleave="open = false"
  >
    <button
      type="button"
      class="hd-lang-btn"
      :aria-expanded="open"
      :aria-label="ariaLabel"
      @click="open = !open"
    >
      <svg class="hd-lang-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" aria-hidden="true">
        <circle cx="12" cy="12" r="10" />
        <path d="M12 2a14.5 14.5 0 0 0 0 20M12 2a14.5 14.5 0 0 1 0 20M2 12h20" />
      </svg>
      <span class="hd-lang-label">{{ currentLabel }}</span>
      <span class="vpi-chevron-down hd-lang-chevron" />
    </button>
    <div class="hd-lang-flyout" :class="{ 'is-open': open }">
      <ul class="hd-lang-list" role="list">
        <li v-for="item in items" :key="item.key">
          <span v-if="item.active" class="hd-lang-item is-active" aria-current="page">
            <span>{{ item.label }}</span>
            <span class="hd-lang-check" aria-hidden="true">✓</span>
          </span>
          <a
            v-else
            class="hd-lang-item"
            :href="withBase(item.href)"
            @click.prevent="go(item.href)"
          >
            <span>{{ item.label }}</span>
          </a>
        </li>
      </ul>
    </div>
  </div>

  <div v-else class="hd-lang-screen">
    <div class="hd-lang-screen-title">Language</div>
    <ul class="hd-lang-screen-list" role="list">
      <li v-for="item in items" :key="item.key">
        <span v-if="item.active" class="hd-lang-screen-item is-active" aria-current="page">
          <span>{{ item.label }}</span>
          <span class="hd-lang-check" aria-hidden="true">✓</span>
        </span>
        <a
          v-else
          class="hd-lang-screen-item"
          :href="withBase(item.href)"
          @click.prevent="go(item.href)"
        >
          <span>{{ item.label }}</span>
        </a>
      </li>
    </ul>
  </div>
</template>

<style scoped>
.hd-lang {
  position: relative;
  display: inline-flex;
  align-items: center;
}

.hd-lang-btn {
  display: inline-flex;
  align-items: center;
  gap: 7px;
  height: 32px;
  padding: 0 10px;
  border: 1px solid var(--line2);
  background: var(--bg);
  color: var(--ink);
  font-family: var(--body);
  font-size: 12px;
  cursor: pointer;
  transition: all 0.12s ease;
  box-sizing: border-box;
}

.hd-lang:hover .hd-lang-btn,
.hd-lang-btn[aria-expanded='true'] {
  color: var(--spot);
  border-color: var(--spot);
}

.hd-lang-icon {
  width: 14px;
  height: 14px;
  opacity: 0.8;
  flex-shrink: 0;
}

.hd-lang-label {
  font-weight: 500;
  white-space: nowrap;
}

.hd-lang-chevron {
  font-size: 10px;
  opacity: 0.6;
}

.hd-lang-flyout {
  position: absolute;
  top: calc(100% + 4px);
  right: 0;
  z-index: 50;
  min-width: 160px;
  padding: 4px 0;
  border: 1px solid var(--line2);
  background: var(--panel);
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.35);
  opacity: 0;
  visibility: hidden;
  transition: opacity 0.15s ease, visibility 0.15s ease;
}

.hd-lang:hover .hd-lang-flyout,
.hd-lang-flyout.is-open {
  opacity: 1;
  visibility: visible;
}

.hd-lang-list {
  display: flex;
  flex-direction: column;
  margin: 0;
  padding: 0;
  list-style: none;
}

.hd-lang-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 8px 14px;
  font-family: var(--body);
  font-size: 12.5px;
  color: var(--dim);
  text-decoration: none;
  cursor: pointer;
  transition: background-color 0.1s ease, color 0.1s ease;
}

.hd-lang-item:hover {
  background: color-mix(in srgb, var(--spot) 8%, transparent);
  color: var(--ink);
}

.hd-lang-item.is-active {
  color: var(--spot);
  background: color-mix(in srgb, var(--spot) 6%, transparent);
  font-weight: 600;
  cursor: default;
}

.hd-lang-check {
  font-size: 11px;
  color: var(--spot);
}

/* Mobile Screen */
.hd-lang-screen {
  padding: 16px var(--gut);
  border-bottom: 1px solid var(--line);
}

.hd-lang-screen-title {
  font-family: var(--body);
  font-size: 11px;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.08em;
  color: var(--faint);
  margin-bottom: 10px;
}

.hd-lang-screen-list {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 8px;
  margin: 0;
  padding: 0;
  list-style: none;
}

.hd-lang-screen-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 8px 10px;
  border: 1px solid var(--line);
  font-family: var(--body);
  font-size: 12px;
  color: var(--dim);
  text-decoration: none;
}

.hd-lang-screen-item.is-active {
  border-color: var(--spot);
  color: var(--spot);
  background: color-mix(in srgb, var(--spot) 8%, transparent);
  font-weight: 600;
}

@media (max-width: 768px) {
  .hd-lang-btn {
    width: 32px;
    height: 32px;
    padding: 0;
    justify-content: center;
    gap: 0;
  }
  .hd-lang-label,
  .hd-lang-chevron {
    display: none;
  }
}
</style>
