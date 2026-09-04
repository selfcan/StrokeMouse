<script setup lang="ts">
import { computed, onMounted, ref, watch } from 'vue'
import { useData } from 'vitepress'
import { themeModeCopy, useSiteLocale } from '../i18n'

const props = withDefaults(
  defineProps<{
    variant?: 'nav' | 'screen'
  }>(),
  { variant: 'nav' },
)

const { isDark } = useData()
const locale = useSiteLocale()
const open = ref(false)

const copy = computed(() => themeModeCopy(locale.value))

const currentLabel = computed(() => {
  return isDark.value ? copy.value.dark : copy.value.light
})

function syncDataMode(dark: boolean) {
  if (typeof document === 'undefined') return
  const mode = dark ? 'ink' : 'paper'
  document.documentElement.setAttribute('data-mode', mode)
}

function setMode(mode: 'light' | 'dark') {
  const willBeDark = mode === 'dark'
  isDark.value = willBeDark
  syncDataMode(willBeDark)
  open.value = false
}

onMounted(() => {
  try {
    const s = localStorage.getItem('vitepress-theme-appearance')
    if (s === 'light') {
      isDark.value = false
      syncDataMode(false)
    } else {
      isDark.value = true
      syncDataMode(true)
    }
  } catch {
    isDark.value = true
    syncDataMode(true)
  }
})

watch(isDark, (val) => {
  syncDataMode(val)
})
</script>

<template>
  <div
    v-if="props.variant === 'nav'"
    class="hd-theme"
    @mouseenter="open = true"
    @mouseleave="open = false"
  >
    <button
      type="button"
      class="hd-theme-btn"
      :aria-expanded="open"
      :aria-label="currentLabel"
      @click="open = !open"
    >
      <!-- Moon Icon (Dark) -->
      <svg
        v-if="isDark"
        class="hd-theme-icon"
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        stroke-width="1.8"
        stroke-linecap="round"
        stroke-linejoin="round"
        aria-hidden="true"
      >
        <path d="M12 3a6 6 0 0 0 9 9 9 9 0 1 1-9-9Z" />
      </svg>
      <!-- Sun Icon (Light) -->
      <svg
        v-else
        class="hd-theme-icon"
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        stroke-width="1.8"
        stroke-linecap="round"
        stroke-linejoin="round"
        aria-hidden="true"
      >
        <circle cx="12" cy="12" r="4" />
        <path d="M12 2v2M12 20v2M4.93 4.93l1.41 1.41M17.66 17.66l1.41 1.41M2 12h2M20 12h2M6.34 17.66l-1.41 1.41M19.07 4.93l-1.41 1.41" />
      </svg>

      <span class="hd-theme-label">{{ currentLabel }}</span>
      <span class="vpi-chevron-down hd-theme-chevron" />
    </button>

    <div class="hd-theme-flyout" :class="{ 'is-open': open }">
      <ul class="hd-theme-list" role="list">
        <li>
          <button
            type="button"
            class="hd-theme-item"
            :class="{ 'is-active': !isDark }"
            @click="setMode('light')"
          >
            <span class="hd-theme-item-left">
              <svg class="hd-theme-menu-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" aria-hidden="true">
                <circle cx="12" cy="12" r="4" />
                <path d="M12 2v2M12 20v2M4.93 4.93l1.41 1.41M17.66 17.66l1.41 1.41M2 12h2M20 12h2M6.34 17.66l-1.41 1.41M19.07 4.93l-1.41 1.41" />
              </svg>
              <span>{{ copy.light }}</span>
            </span>
            <span v-if="!isDark" class="hd-theme-check" aria-hidden="true">✓</span>
          </button>
        </li>
        <li>
          <button
            type="button"
            class="hd-theme-item"
            :class="{ 'is-active': isDark }"
            @click="setMode('dark')"
          >
            <span class="hd-theme-item-left">
              <svg class="hd-theme-menu-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" aria-hidden="true">
                <path d="M12 3a6 6 0 0 0 9 9 9 9 0 1 1-9-9Z" />
              </svg>
              <span>{{ copy.dark }}</span>
            </span>
            <span v-if="isDark" class="hd-theme-check" aria-hidden="true">✓</span>
          </button>
        </li>
      </ul>
    </div>
  </div>

  <div v-else class="hd-theme-screen">
    <div class="hd-theme-screen-title">{{ copy.dark }} / {{ copy.light }}</div>
    <div class="hd-theme-screen-grid">
      <button
        type="button"
        class="hd-theme-screen-btn"
        :class="{ 'is-active': !isDark }"
        @click="setMode('light')"
      >
        <span>{{ copy.light }}</span>
        <span v-if="!isDark" class="hd-theme-check">✓</span>
      </button>
      <button
        type="button"
        class="hd-theme-screen-btn"
        :class="{ 'is-active': isDark }"
        @click="setMode('dark')"
      >
        <span>{{ copy.dark }}</span>
        <span v-if="isDark" class="hd-theme-check">✓</span>
      </button>
    </div>
  </div>
</template>

<style scoped>
.hd-theme {
  position: relative;
  display: inline-flex;
  align-items: center;
}

.hd-theme-btn {
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

.hd-theme:hover .hd-theme-btn,
.hd-theme-btn[aria-expanded='true'] {
  color: var(--spot);
  border-color: var(--spot);
}

.hd-theme-icon {
  width: 14px;
  height: 14px;
  opacity: 0.85;
  flex-shrink: 0;
}

.hd-theme-label {
  font-weight: 500;
  white-space: nowrap;
}

.hd-theme-chevron {
  font-size: 10px;
  opacity: 0.6;
}

.hd-theme-flyout {
  position: absolute;
  top: calc(100% + 4px);
  right: 0;
  z-index: 50;
  min-width: 140px;
  padding: 4px 0;
  border: 1px solid var(--line2);
  background: var(--panel);
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.35);
  opacity: 0;
  visibility: hidden;
  transition: opacity 0.15s ease, visibility 0.15s ease;
}

.hd-theme:hover .hd-theme-flyout,
.hd-theme-flyout.is-open {
  opacity: 1;
  visibility: visible;
}

.hd-theme-list {
  display: flex;
  flex-direction: column;
  margin: 0;
  padding: 0;
  list-style: none;
}

.hd-theme-item {
  width: 100%;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 8px 14px;
  border: 0;
  background: none;
  font-family: var(--body);
  font-size: 12.5px;
  color: var(--dim);
  cursor: pointer;
  transition: background-color 0.1s ease, color 0.1s ease;
  text-align: left;
}

.hd-theme-item-left {
  display: inline-flex;
  align-items: center;
  gap: 8px;
}

.hd-theme-menu-icon {
  width: 14px;
  height: 14px;
  opacity: 0.75;
}

.hd-theme-item:hover {
  background: color-mix(in srgb, var(--spot) 8%, transparent);
  color: var(--ink);
}

.hd-theme-item.is-active {
  color: var(--spot);
  background: color-mix(in srgb, var(--spot) 6%, transparent);
  font-weight: 600;
}

.hd-theme-check {
  font-size: 11px;
  color: var(--spot);
}

/* Mobile Screen */
.hd-theme-screen {
  padding: 16px var(--gut);
  border-bottom: 1px solid var(--line);
}

.hd-theme-screen-title {
  font-family: var(--body);
  font-size: 11px;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.08em;
  color: var(--faint);
  margin-bottom: 10px;
}

.hd-theme-screen-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 8px;
}

.hd-theme-screen-btn {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 8px 12px;
  border: 1px solid var(--line);
  background: var(--panel);
  font-family: var(--body);
  font-size: 12px;
  color: var(--dim);
  cursor: pointer;
}

.hd-theme-screen-btn.is-active {
  border-color: var(--spot);
  color: var(--spot);
  background: color-mix(in srgb, var(--spot) 8%, transparent);
  font-weight: 600;
}
@media (max-width: 768px) {
  .hd-theme-btn {
    width: 32px;
    height: 32px;
    padding: 0;
    justify-content: center;
    gap: 0;
  }
  .hd-theme-label,
  .hd-theme-chevron {
    display: none;
  }
}
</style>
