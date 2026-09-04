<script setup lang="ts">
import { computed, ref } from 'vue'
import { generalUiCopy, useSiteLocale } from '../i18n'

const props = defineProps<{
  title: string
  tagline: string
  primaryText: string
  primaryLink: string
  secondaryText: string
  secondaryLink: string
  imageSrc?: string
  imageAlt?: string
  hudLabel?: string
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

const eyebrow = computed(() => {
  switch (locale.value) {
    case 'zh-hant':
      return 'macOS 原生手勢引擎'
    case 'ja':
      return 'macOS ネイティブ ジェスチャー'
    case 'ru':
      return 'Нативный движок жестов macOS'
    case 'ko':
      return 'macOS 네이티브 제스처 엔진'
    case 'fr':
      return 'Moteur de gestes natif pour macOS'
    case 'en':
      return 'native macos gesture runtime'
    default:
      return 'macOS 原生手势运行时'
  }
})
</script>

<template>
  <header class="hd-hero">
    <!-- Faint background ghost logo watermark -->
    <div class="ghost-logo" aria-hidden="true">
      <svg viewBox="0 0 1024 1024" fill="currentColor">
        <path
          d="M 642 730 C 575 770 495 811 420 810 C 315 810 240 746 218 655 C 190 540 234 410 288 315 C 342 219 414 141 500 122 C 568 107 629 135 659 184 C 706 260 681 354 637 442 C 602 510 572 580 576 620 C 579 656 597 674 624 676 C 650 678 680 654 706 649 C 750 642 786 647 813 678 C 850 721 846 778 816 824 C 788 850 710 887 565 920 C 665 885 730 850 764 815 C 793 785 803 749 787 722 C 769 691 740 688 703 697 C 675 706 635 728 590 713 C 542 696 518 659 522 611 C 527 555 560 485 593 419 C 631 341 647 273 617 213 C 591 161 542 144 495 156 C 423 174 359 247 311 337 C 260 432 224 547 242 638 C 260 730 329 775 419 776 C 497 777 568 750 642 730 Z"
        />
      </svg>
    </div>

    <div class="hd-hero-in">
      <div class="hd-eyebrow">
        <span>{{ eyebrow }}</span>
      </div>

      <h1 class="hd-hero-title">
        {{ title }}
      </h1>

      <p class="hd-hero-lede">{{ tagline }}</p>

      <div class="hd-hero-go">
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

      <div class="hd-hero-meta">
        <span>macOS 14+ Sonoma · Sequoia · Apple Silicon &amp; Intel · AGPL-3.0</span>
        <span class="meta-sep">—</span>
        <a :href="primaryLink">{{ generalCopy.allDownloads }}</a>
      </div>
    </div>
  </header>
</template>

<style scoped>
.hd-hero {
  position: relative;
  overflow: hidden;
  padding: 60px var(--gut) 48px;
  background: var(--bg);
}

.ghost-logo {
  position: absolute;
  right: -8%;
  top: 50%;
  transform: translateY(-50%);
  width: min(720px, 54vw);
  height: min(720px, 54vw);
  color: var(--mass);
  opacity: 0.6;
  z-index: 0;
  pointer-events: none;
}

.ghost-logo svg {
  width: 100%;
  height: 100%;
}

.hd-hero-in {
  position: relative;
  z-index: 1;
  max-width: 960px;
}

.hd-eyebrow {
  display: inline-flex;
  align-items: center;
  color: var(--spot);
  font-family: var(--mono);
  font-size: 11.5px;
  letter-spacing: 0.14em;
  text-transform: uppercase;
  margin-bottom: 14px;
}

.hd-hero-title {
  font-family: var(--disp);
  font-weight: 900;
  letter-spacing: -0.045em;
  line-height: 1.05;
  font-size: clamp(34px, 5.5vw, 76px);
  margin: 0;
  color: var(--ink);
  max-width: 20ch;
}

.hd-hero-lede {
  color: var(--dim);
  font-size: 16px;
  line-height: 1.7;
  max-width: 58ch;
  margin: 22px 0 0;
}

.hd-hero-go {
  display: flex;
  align-items: center;
  gap: 14px;
  margin-top: 32px;
  flex-wrap: wrap;
}

/* ── Command Box (Single clean 1px border, no nested code borders) ── */
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

/* ── Action Buttons ── */
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

/* Primary Button: high contrast, white/black text */
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

.hd-hero-meta {
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

.hd-hero-meta a {
  color: var(--spot);
  text-decoration: none;
}

.hd-hero-meta a:hover {
  text-decoration: underline;
}

@media (max-width: 900px) {
  .hd-hero {
    padding: 44px var(--gut) 36px;
  }
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
  .hd-hero-go {
    gap: 10px;
  }
  .hd-btn {
    width: 100%;
  }
}
</style>
