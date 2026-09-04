<script setup lang="ts">
import { computed, ref } from 'vue'
import {
  APP_VERSION,
  GITHUB_RELEASES,
  MAC_ASSETS,
  releaseAssetUrl,
} from '../constants'
import { downloadCopy, generalUiCopy, localeHref, useSiteLocale } from '../i18n'

const locale = useSiteLocale()
const generalCopy = computed(() => generalUiCopy(locale.value))

const HOMEBREW_LINES = [
  'brew install --cask licoy/tap/strokemouse',
  'brew upgrade --cask --greedy strokemouse',
  'brew uninstall --cask strokemouse',
]

const copy = computed(() => {
  const text = downloadCopy(locale.value)
  return {
    ...text,
    version: `v${APP_VERSION}`,
    homebrewLines: HOMEBREW_LINES,
    sourceLink: localeHref(locale.value, '/guide/installation'),
  }
})

const cards = computed(() => [
  {
    id: 'arm64' as const,
    title: copy.value.armTitle,
    desc: copy.value.armDesc,
    file: MAC_ASSETS.arm64.file,
    href: releaseAssetUrl(MAC_ASSETS.arm64.file),
    badge: 'Apple Silicon',
    arch: 'arm64',
  },
  {
    id: 'x64' as const,
    title: copy.value.intelTitle,
    desc: copy.value.intelDesc,
    file: MAC_ASSETS.x64.file,
    href: releaseAssetUrl(MAC_ASSETS.x64.file),
    badge: 'Intel Mac',
    arch: 'x86_64',
  },
])

const copiedIndex = ref<number | null>(null)

function copyCmd(cmd: string, idx: number) {
  if (typeof navigator !== 'undefined' && navigator.clipboard) {
    navigator.clipboard.writeText(cmd)
    copiedIndex.value = idx
    setTimeout(() => {
      copiedIndex.value = null
    }, 2000)
  }
}
</script>

<template>
  <div class="hd-download-page">
    <div class="hd-download-frame">
      <!-- ── Page Header ── -->
      <header class="hd-dl-hero">
        <h1 class="hd-dl-title">{{ copy.title }}</h1>
        <p class="hd-dl-lead">{{ copy.lead }}</p>

        <div class="hd-dl-meta-strip">
          <a
            class="hd-dl-tag"
            :href="GITHUB_RELEASES"
            target="_blank"
            rel="noopener"
          >
            {{ copy.version }}
          </a>
          <span class="hd-dl-tag">macOS 14+ Sonoma &amp; Sequoia</span>
          <span class="hd-dl-tag">AGPL-3.0</span>
        </div>
      </header>

      <!-- ── Section 1: Homebrew Cask ── -->
      <section class="hd-dl-section">
        <div class="hd-dl-sec-hd">
          <h2 class="hd-dl-h2">{{ copy.homebrewTitle }}</h2>
          <p class="hd-dl-desc">{{ copy.homebrewDesc }}</p>
        </div>

        <div class="hd-dl-term">
          <div class="hd-dl-term-bar">
            <span>Terminal</span>
            <span class="dim">zsh / bash</span>
          </div>

          <div class="hd-dl-term-body">
            <div
              v-for="(line, idx) in copy.homebrewLines"
              :key="line"
              class="hd-term-line"
            >
              <div class="hd-term-cmd">
                <span class="prompt">$</span>
                <span class="hd-term-text">{{ line }}</span>
              </div>
              <button
                type="button"
                class="hd-copy-btn"
                :aria-label="copiedIndex === idx ? generalCopy.copied : generalCopy.copy"
                @click="copyCmd(line, idx)"
              >
                {{ copiedIndex === idx ? generalCopy.copied : generalCopy.copy }}
              </button>
            </div>
          </div>
        </div>

        <p class="hd-dl-note">{{ copy.homebrewNote }}</p>
      </section>

      <!-- ── Section 2: Direct DMG Download ── -->
      <section class="hd-dl-section">
        <div class="hd-dl-sec-hd">
          <h2 class="hd-dl-h2">{{ copy.manual }}</h2>
        </div>

        <div class="hd-arch-grid">
          <div
            v-for="card in cards"
            :key="card.id"
            class="hd-arch-card"
          >
            <div class="hd-arch-header">
              <span class="hd-arch-chip">{{ card.badge }}</span>
              <span class="hd-arch-code">{{ card.arch }}</span>
            </div>

            <div class="hd-arch-body">
              <h3 class="hd-arch-title">{{ card.title }}</h3>
              <p class="hd-arch-desc">{{ card.desc }}</p>
              <span class="hd-arch-file">{{ card.file }}</span>
            </div>

            <div class="hd-arch-footer">
              <a
                class="hd-btn hd-btn-primary hd-arch-btn"
                :href="card.href"
                target="_blank"
                rel="noopener"
              >
                <span>{{ copy.get }}</span>
                <span class="arw">↓</span>
              </a>
            </div>
          </div>
        </div>
      </section>

      <!-- ── Section 3: Requirements & Spec ── -->
      <section class="hd-dl-section hd-dl-info-sec">
        <div class="hd-req-box">
          <div class="hd-req-row">
            <span class="hd-req-label">{{ copy.reqLabel }}</span>
            <span class="hd-req-val">{{ copy.reqValue }}</span>
          </div>
          <div class="hd-req-links">
            <a :href="GITHUB_RELEASES" target="_blank" rel="noopener">
              {{ copy.releases }} →
            </a>
            <a :href="copy.sourceLink">
              {{ copy.source }} →
            </a>
          </div>
        </div>
        <p class="hd-req-note">{{ copy.note }}</p>
      </section>

      <!-- ── Section 4: Step-by-Step Installation ── -->
      <section class="hd-dl-section hd-dl-steps-sec">
        <div class="hd-dl-sec-hd">
          <h2 class="hd-dl-h2">{{ copy.installTitle }}</h2>
        </div>

        <div class="hd-steps-list">
          <div
            v-for="(step, i) in copy.steps"
            :key="i"
            class="hd-step-item"
          >
            <span class="hd-step-n">0{{ i + 1 }}</span>
            <span class="hd-step-text">{{ step }}</span>
          </div>
        </div>
      </section>
    </div>
  </div>
</template>

<style scoped>
.hd-download-page {
  width: 100%;
  background: var(--bg);
}

.hd-download-frame {
  max-width: 1440px;
  margin: 0 auto;
  border-left: 1px solid var(--line2);
  border-right: 1px solid var(--line2);
  border-bottom: 1px solid var(--line2);
  background: var(--bg);
  box-sizing: border-box;
}

/* ── Hero ── */
.hd-dl-hero {
  padding: 56px var(--gut) 40px;
  border-bottom: 1px solid var(--line2);
}

.hd-dl-title {
  font-family: var(--disp);
  font-weight: 900;
  letter-spacing: -0.045em;
  line-height: 1.05;
  font-size: clamp(32px, 4.5vw, 64px);
  color: var(--ink);
  margin: 0;
}

.hd-dl-lead {
  color: var(--dim);
  font-size: 16px;
  line-height: 1.7;
  max-width: 64ch;
  margin: 16px 0 0;
}

.hd-dl-meta-strip {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  margin-top: 22px;
}

.hd-dl-tag {
  display: inline-flex;
  align-items: center;
  padding: 6px 12px;
  border: 1px solid var(--line2);
  background: var(--panel);
  color: var(--dim);
  font-size: 11.5px;
  text-decoration: none !important;
}

.hd-dl-tag:hover {
  border-color: var(--spot);
  color: var(--ink);
}

/* ── Section Base ── */
.hd-dl-section {
  padding: 42px var(--gut);
  border-bottom: 1px solid var(--line2);
}

.hd-dl-h2 {
  font-family: var(--disp);
  font-weight: 800;
  font-size: clamp(22px, 2.8vw, 32px);
  letter-spacing: -0.03em;
  color: var(--ink);
  margin: 0;
}

.hd-dl-desc {
  color: var(--dim);
  font-size: 14.5px;
  margin: 8px 0 0;
  max-width: 60ch;
}

/* ── Terminal Block ── */
.hd-dl-term {
  margin-top: 20px;
  border: 1px solid var(--line2);
  background: var(--panel);
}

.hd-dl-term-bar {
  display: flex;
  justify-content: space-between;
  padding: 8px 16px;
  border-bottom: 1px solid var(--line);
  background: color-mix(in srgb, var(--panel) 94%, black);
  font-size: 11px;
  color: var(--faint);
}

.hd-dl-term-body {
  padding: 6px 0;
}

.hd-term-line {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 8px 16px;
  border-bottom: 1px solid color-mix(in srgb, var(--line) 50%, transparent);
}

.hd-term-line:last-child {
  border-bottom: 0;
}

.hd-term-cmd {
  display: flex;
  align-items: center;
  gap: 12px;
  font-family: var(--mono);
  font-size: 12.5px;
  color: var(--ink);
  overflow-x: auto;
}

.hd-term-cmd .prompt {
  color: var(--spot);
  user-select: none;
  font-weight: 600;
}

.hd-term-text {
  color: var(--ink);
}

.hd-copy-btn {
  padding: 6px 12px;
  border: 1px solid var(--line2);
  background: var(--bg);
  color: var(--dim);
  font-family: var(--mono);
  font-size: 10.5px;
  letter-spacing: 0.08em;
  text-transform: uppercase;
  cursor: pointer;
  transition: all 0.12s ease;
  flex-shrink: 0;
  margin-left: 16px;
}

.hd-copy-btn:hover {
  color: var(--ink);
  border-color: var(--spot);
}

.hd-dl-note {
  margin: 12px 0 0;
  color: var(--faint);
  font-size: 12.5px;
}

/* ── Architecture Cards ── */
.hd-arch-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px;
  margin-top: 24px;
}

.hd-arch-card {
  border: 1px solid var(--line2);
  background: var(--panel);
  padding: 24px 20px;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  gap: 18px;
  transition: background-color 0.12s ease;
}

.hd-arch-card:hover {
  background: color-mix(in srgb, var(--spot) 4%, var(--panel));
}

.hd-arch-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.hd-arch-chip {
  font-family: var(--body);
  font-size: 11px;
  font-weight: 600;
  color: var(--spot);
  padding: 3px 8px;
  border: 1px solid color-mix(in srgb, var(--spot) 30%, transparent);
  background: color-mix(in srgb, var(--spot) 8%, transparent);
}

.hd-arch-code {
  font-family: var(--mono);
  font-size: 11px;
  color: var(--faint);
}

.hd-arch-title {
  font-family: var(--disp);
  font-weight: 800;
  font-size: 18px;
  letter-spacing: -0.02em;
  color: var(--ink);
  margin: 0 0 6px;
}

.hd-arch-desc {
  font-size: 13.5px;
  color: var(--dim);
  margin: 0 0 12px;
}

.hd-arch-file {
  display: block;
  font-family: var(--mono);
  font-size: 11.5px;
  color: var(--faint);
  padding: 6px 10px;
  background: var(--bg);
  border: 1px solid var(--line);
}

.hd-arch-btn {
  width: 100%;
  height: 42px;
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 8px;
  font-family: var(--body);
  font-size: 13px;
  font-weight: 600;
  text-decoration: none !important;
}

.hd-btn-primary {
  background-color: #0284c7 !important;
  color: #ffffff !important;
  border: 1px solid #0284c7 !important;
}

:root.dark .hd-btn-primary,
html.dark .hd-btn-primary {
  background-color: #38bdf8 !important;
  color: #0b1120 !important;
  border-color: #38bdf8 !important;
}

.hd-btn-primary:hover {
  filter: brightness(1.08);
}

/* ── Requirements Box ── */
.hd-req-box {
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 16px;
  padding: 16px 20px;
  border: 1px solid var(--line2);
  background: var(--panel);
}

.hd-req-row {
  display: flex;
  align-items: center;
  gap: 12px;
  font-size: 12.5px;
}

.hd-req-label {
  color: var(--faint);
  font-weight: 600;
}

.hd-req-val {
  color: var(--ink);
  font-weight: 500;
}

.hd-req-links {
  display: flex;
  gap: 18px;
}

.hd-req-links a {
  font-family: var(--body);
  font-size: 12px;
  font-weight: 500;
  color: var(--spot);
  text-decoration: none;
}

.hd-req-links a:hover {
  text-decoration: underline;
}

.hd-req-note {
  margin: 12px 0 0;
  color: var(--faint);
  font-size: 12px;
}

/* ── Step-by-Step ── */
.hd-steps-list {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  border: 1px solid var(--line2);
  margin-top: 20px;
}

.hd-step-item {
  padding: 20px 18px;
  border-right: 1px solid var(--line);
  background: var(--panel);
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.hd-step-item:last-child {
  border-right: 0;
}

.hd-step-n {
  font-family: var(--disp);
  font-weight: 900;
  font-size: 28px;
  line-height: 1;
  color: var(--line2);
}

.hd-step-text {
  font-size: 13px;
  line-height: 1.55;
  color: var(--dim);
}

/* Responsive */
@media (max-width: 900px) {
  .hd-download-frame {
    border-left: 0;
    border-right: 0;
  }
  .hd-arch-grid {
    grid-template-columns: 1fr;
  }
  .hd-steps-list {
    grid-template-columns: 1fr 1fr;
  }
  .hd-step-item:nth-child(2n) {
    border-right: 0;
  }
  .hd-step-item:nth-child(-n + 2) {
    border-bottom: 1px solid var(--line);
  }
}

@media (max-width: 560px) {
  .hd-steps-list {
    grid-template-columns: 1fr;
  }
  .hd-step-item {
    border-right: 0 !important;
    border-bottom: 1px solid var(--line);
  }
  .hd-step-item:last-child {
    border-bottom: 0;
  }
}
</style>
