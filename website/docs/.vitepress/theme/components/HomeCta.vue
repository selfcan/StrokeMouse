<script setup lang="ts">
import { computed, ref } from 'vue'
import { generalUiCopy, useSiteLocale } from '../i18n'

defineProps<{
  heading: string
  lead?: string
  steps?: string[]
  primaryText: string
  primaryLink: string
  secondaryText: string
  secondaryLink: string
}>()

const locale = useSiteLocale()
const generalCopy = computed(() => generalUiCopy(locale.value))

const copied = ref(false)
const installCmd = 'brew install --cask licoy/tap/strokemouse'

function copyInstall() {
  if (typeof navigator !== 'undefined' && navigator.clipboard) {
    navigator.clipboard.writeText(installCmd)
    copied.value = true
    setTimeout(() => {
      copied.value = false
    }, 2000)
  }
}
</script>

<template>
  <section id="install" class="hd-end">
    <div class="hd-end-in">
      <h2 class="hd-end-title">{{ heading }}</h2>
      <p v-if="lead" class="hd-end-lead">{{ lead }}</p>

      <!-- Steps Checkpoints (if provided) -->
      <div v-if="steps?.length" class="hd-end-steps">
        <div v-for="(step, i) in steps" :key="i" class="hd-end-step">
          <span class="hd-end-step-n">0{{ i + 1 }}</span>
          <span class="hd-end-step-text">{{ step }}</span>
        </div>
      </div>

      <!-- Quick Command Bar -->
      <div class="hd-end-go">
        <div class="hd-cmd">
          <div class="hd-cmd-inner">
            <span class="hd-cmd-prompt">$</span>
            <span class="hd-cmd-code">{{ installCmd }}</span>
          </div>
          <button
            type="button"
            class="hd-cmd-copy"
            :aria-label="copied ? generalCopy.copied : generalCopy.copy"
            @click="copyInstall"
          >
            {{ copied ? generalCopy.copied : generalCopy.copy }}
          </button>
        </div>

        <a class="hd-btn hd-btn-primary" :href="primaryLink">
          {{ primaryText }}
        </a>
        <a class="hd-btn hd-btn-ghost" :href="secondaryLink">
          {{ secondaryText }} →
        </a>
      </div>

      <div class="hd-end-meta">
        <span>macOS 14+ Sonoma · Sequoia · Apple Silicon &amp; Intel · AGPL-3.0</span>
        <span class="meta-sep">—</span>
        <a :href="primaryLink">{{ generalCopy.allDownloads }}</a>
      </div>
    </div>
  </section>
</template>

<style scoped>
.hd-end {
  padding: 56px var(--gut) 48px;
  position: relative;
  overflow: hidden;
  background: var(--bg);
}

.hd-end-in {
  max-width: 900px;
}

.hd-eyebrow {
  display: inline-flex;
  align-items: center;
  color: var(--spot);
  font-family: var(--mono);
  font-size: 11px;
  letter-spacing: 0.14em;
  text-transform: uppercase;
  margin-bottom: 14px;
}

.hd-end-title {
  font-family: var(--disp);
  font-weight: 900;
  font-size: clamp(28px, 4vw, 56px);
  letter-spacing: -0.045em;
  line-height: 1.05;
  margin: 0;
  color: var(--ink);
}

.hd-end-lead {
  color: var(--dim);
  font-size: 15.5px;
  line-height: 1.7;
  max-width: 58ch;
  margin: 16px 0 0;
}

.hd-end-steps {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  margin-top: 24px;
}

.hd-end-step {
  display: inline-flex;
  align-items: center;
  gap: 10px;
  padding: 8px 14px;
  border: 1px solid var(--line2);
  background: var(--panel);
  font-size: 12px;
}

.hd-end-step-n {
  font-family: var(--mono);
  color: var(--spot);
  font-weight: 600;
}

.hd-end-step-text {
  color: var(--dim);
}

.hd-end-go {
  display: flex;
  align-items: center;
  gap: 14px;
  margin-top: 32px;
  flex-wrap: wrap;
}

/* ── Command Box ── */
.hd-cmd {
  display: inline-flex;
  align-items: center;
  border: 1px solid var(--line2);
  background: var(--panel);
  height: 42px;
  box-sizing: border-box;
}

.hd-cmd-inner {
  display: inline-flex;
  align-items: center;
  gap: 10px;
  padding: 0 16px;
  font-family: var(--mono);
  font-size: 13px;
  color: var(--ink);
}

.hd-cmd-prompt {
  color: var(--spot);
  user-select: none;
  font-weight: 600;
}

.hd-cmd-code {
  color: var(--ink);
  white-space: nowrap;
}

.hd-cmd-copy {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  height: 100%;
  padding: 0 16px;
  border: 0;
  border-left: 1px solid var(--line2);
  background: transparent;
  cursor: pointer;
  color: var(--faint);
  font-family: var(--mono);
  font-size: 11px;
  letter-spacing: 0.08em;
  text-transform: uppercase;
  transition: all 0.12s ease;
}

.hd-cmd-copy:hover {
  color: var(--ink);
  background: color-mix(in srgb, var(--spot) 8%, transparent);
}

/* ── Buttons ── */
.hd-btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  height: 42px;
  padding: 0 20px;
  font-family: var(--body);
  font-size: 13px;
  font-weight: 600;
  text-decoration: none !important;
  box-sizing: border-box;
  transition: all 0.12s ease;
}

.hd-btn-primary {
  background: #0284c7 !important;
  color: #ffffff !important;
  border: 1px solid #0284c7 !important;
}

:root.dark .hd-btn-primary,
html.dark .hd-btn-primary {
  background: #38bdf8 !important;
  color: #0b1120 !important;
  border-color: #38bdf8 !important;
}

.hd-btn-primary:hover {
  filter: brightness(1.08);
}

.hd-btn-ghost {
  border: 1px solid var(--line2);
  background: transparent;
  color: var(--ink) !important;
}

.hd-btn-ghost:hover {
  border-color: var(--spot);
  color: var(--spot) !important;
}

.hd-end-meta {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 8px;
  margin-top: 24px;
  color: var(--faint);
  font-size: 12px;
}

.meta-sep {
  opacity: 0.5;
}

.hd-end-meta a {
  color: var(--spot);
  text-decoration: none;
}

.hd-end-meta a:hover {
  text-decoration: underline;
}

@media (max-width: 640px) {
  .hd-cmd {
    width: 100%;
    justify-content: space-between;
  }
  .hd-cmd-inner {
    padding: 0 12px;
    font-size: 12px;
    overflow-x: auto;
  }
  .hd-end-go {
    gap: 10px;
  }
  .hd-btn {
    width: 100%;
  }
}
</style>
