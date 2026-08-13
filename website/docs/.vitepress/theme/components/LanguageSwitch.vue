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

const props = withDefaults(
  defineProps<{
    variant?: 'nav' | 'screen'
  }>(),
  { variant: 'nav' },
)

const { page, hash, theme } = useData()
const router = useRouter()
const open = ref(false)

const items = computed(() => {
  const { locale, pageId } = parseRelativePath(page.value.relativePath)
  const suffix = hash.value || ''
  return LOCALE_KEYS.map((key: LocaleKey) => {
    const path = pageId === 'index' ? localePath(key, '/') : localePath(key, `/${pageId}`)
    return {
      key,
      label: LOCALES[key].label,
      href: `${path}${suffix}`,
      active: key === locale,
    }
  })
})

const ariaLabel = computed(() => theme.value.langMenuLabel || 'Change language')

function go(href: string) {
  open.value = false
  router.go(href)
}
</script>

<template>
  <div
    v-if="props.variant === 'nav'"
    class="sm-lang"
    @mouseenter="open = true"
    @mouseleave="open = false"
  >
    <button
      type="button"
      class="sm-lang__btn"
      :aria-expanded="open"
      :aria-label="ariaLabel"
      @click="open = !open"
    >
      <span class="vpi-languages sm-lang__icon" />
      <span class="vpi-chevron-down sm-lang__chevron" />
    </button>
    <div class="sm-lang__flyout" :class="{ 'is-open': open }">
      <ul class="sm-lang__list" role="list">
        <li v-for="item in items" :key="item.key">
          <span v-if="item.active" class="sm-lang__item is-active" aria-current="page">
            {{ item.label }}
            <span class="sm-lang__check" aria-hidden="true">✓</span>
          </span>
          <a
            v-else
            class="sm-lang__item"
            :href="withBase(item.href)"
            @click.prevent="go(item.href)"
          >
            {{ item.label }}
          </a>
        </li>
      </ul>
    </div>
  </div>

  <div v-else class="sm-lang-screen">
    <ul class="sm-lang-screen__list" role="list">
      <li v-for="item in items" :key="item.key">
        <span v-if="item.active" class="sm-lang-screen__item is-active" aria-current="page">
          {{ item.label }}
          <span class="sm-lang__check" aria-hidden="true">✓</span>
        </span>
        <a
          v-else
          class="sm-lang-screen__item"
          :href="withBase(item.href)"
          @click.prevent="go(item.href)"
        >
          {{ item.label }}
        </a>
      </li>
    </ul>
  </div>
</template>

<style scoped>
.sm-lang {
  position: relative;
  display: none;
  align-items: center;
}

@media (min-width: 768px) {
  .sm-lang {
    display: flex;
  }
}

.sm-lang::before {
  margin-right: 8px;
  margin-left: 8px;
  width: 1px;
  height: 24px;
  background-color: var(--vp-c-divider);
  content: '';
}

.sm-lang__btn {
  display: flex;
  align-items: center;
  padding: 0 12px;
  height: var(--vp-nav-height);
  color: var(--vp-c-text-1);
  background: transparent;
  border: 0;
  cursor: pointer;
  transition: color 0.25s;
}

.sm-lang:hover .sm-lang__btn,
.sm-lang__btn[aria-expanded='true'] {
  color: var(--sm-accent);
}

.sm-lang__icon {
  font-size: 16px;
}

.sm-lang__chevron {
  margin-left: 4px;
  font-size: 14px;
}

.sm-lang__flyout {
  position: absolute;
  top: calc(var(--vp-nav-height) / 2 + 20px);
  right: 0;
  z-index: 20;
  min-width: 168px;
  padding: 6px;
  border: 1px solid var(--sm-border);
  border-radius: 12px;
  background-color: var(--vp-c-bg-elv);
  box-shadow: var(--sm-shadow);
  opacity: 0;
  visibility: hidden;
  transition:
    opacity 0.2s var(--sm-ease),
    visibility 0.2s var(--sm-ease);
}

.sm-lang:hover .sm-lang__flyout,
.sm-lang__flyout.is-open {
  opacity: 1;
  visibility: visible;
}

.sm-lang__list,
.sm-lang-screen__list {
  display: flex;
  flex-direction: column;
  gap: 1px;
  margin: 0;
  padding: 0;
  list-style: none;
}

.sm-lang__item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 20px;
  padding: 0 10px;
  line-height: 28px;
  font-family: var(--sm-font-sans);
  font-size: 13px;
  font-weight: 500;
  color: var(--sm-text);
  border-radius: 8px;
  white-space: nowrap;
  text-decoration: none;
  cursor: pointer;
  transition:
    background-color 0.2s var(--sm-ease),
    color 0.2s var(--sm-ease);
}

.sm-lang__item:hover {
  background-color: var(--vp-c-default-soft);
  color: var(--sm-accent);
}

.sm-lang__item.is-active {
  font-weight: 600;
  background-color: var(--vp-c-default-soft);
  color: var(--sm-accent);
  cursor: default;
}

html:not(.dark) .sm-lang__item:hover,
html:not(.dark) .sm-lang__item.is-active {
  background-color: rgba(29, 111, 212, 0.1);
  color: #1557a8;
}

.sm-lang__check {
  font-size: 12px;
  font-weight: 700;
  line-height: 1;
}

.sm-lang-screen {
  margin-top: 24px;
}

.sm-lang-screen__item {
  display: flex;
  align-items: center;
  justify-content: flex-start;
  gap: 10px;
  padding: 0;
  line-height: 32px;
  font-size: 14px;
  font-weight: 500;
  color: var(--vp-c-text-1);
  text-decoration: none;
}

.sm-lang-screen__item.is-active {
  font-weight: 600;
  color: var(--sm-accent);
}

html:not(.dark) .sm-lang-screen__item.is-active {
  color: #1557a8;
}
</style>
