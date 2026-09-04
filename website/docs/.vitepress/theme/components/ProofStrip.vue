<script setup lang="ts">
import { computed } from 'vue'
import { PRESET_ACTION_COUNT } from '../constants'
import { showcaseCopy, useSiteLocale } from '../i18n'

defineProps<{
  items?: string[]
}>()

const locale = useSiteLocale()
const sc = computed(() => showcaseCopy(locale.value))
</script>

<template>
  <div class="sm-strip-wrap">
    <!-- ── 4-Column Stats Strip ── -->
    <div class="strip">
      <div class="stat">
        <b>34+</b>
        <span>
          <svg class="ic" viewBox="0 0 24 24" aria-hidden="true">
            <path
              d="M3 3h8v8H3zM13 3h8v8h-8zM3 13h8v8H3zM13 13h8v8h-8z"
              fill="none"
              stroke="currentColor"
              stroke-width="2"
            />
          </svg>
          {{ sc.stripGestures }}
        </span>
      </div>

      <div class="stat">
        <b>{{ PRESET_ACTION_COUNT }}</b>
        <span>
          <svg class="ic" viewBox="0 0 24 24" aria-hidden="true">
            <path
              d="M4 6h16M4 12h16M4 18h10"
              fill="none"
              stroke="currentColor"
              stroke-width="2"
              stroke-linecap="square"
            />
          </svg>
          {{ sc.stripPresets }}
        </span>
      </div>

      <div class="stat">
        <b>0.8ms</b>
        <span>
          <svg class="ic" viewBox="0 0 24 24" aria-hidden="true">
            <path
              d="M12 3v10m0 0l-4-4m4 4l4-4M4 17v3h16v-3"
              fill="none"
              stroke="currentColor"
              stroke-width="2"
              stroke-linecap="square"
            />
          </svg>
          {{ sc.stripLatency }}
        </span>
      </div>

      <div class="stat">
        <b>macOS 14+</b>
        <span>
          <svg class="ic" viewBox="0 0 24 24" aria-hidden="true">
            <path
              d="M4 6l6 6-6 6M13 18h7"
              fill="none"
              stroke="currentColor"
              stroke-width="2"
              stroke-linecap="square"
            />
          </svg>
          {{ sc.stripChips }}
        </span>
      </div>
    </div>
  </div>
</template>

<style scoped>
.sm-strip-wrap {
  width: 100%;
}

/* ── Strip (4 columns) ── */
.strip {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  border-top: 1px solid var(--line2);
  border-bottom: 1px solid var(--line2);
  background: var(--bg);
}

.stat {
  position: relative;
  display: block;
  overflow: hidden;
  text-decoration: none;
  padding: 22px var(--gut) 24px;
  border-right: 1px solid var(--line);
  box-sizing: border-box;
  transition: background-color 0.12s ease;
}

.stat:last-child {
  border-right: 0;
}

.stat:hover {
  background: color-mix(in srgb, var(--spot) 5%, transparent);
}

.stat b {
  display: block;
  font-family: var(--disp);
  font-weight: 900;
  font-size: clamp(24px, 2.8vw, 36px);
  letter-spacing: -0.04em;
  line-height: 1;
  color: var(--ink);
  font-variant-numeric: tabular-nums;
}

.stat span {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-top: 10px;
  color: var(--dim);
  font-family: var(--body);
  font-size: 11.5px;
}

.stat:hover span {
  color: var(--ink);
}

.stat .ic {
  width: 14px;
  height: 14px;
  flex: 0 0 14px;
  fill: currentColor;
  stroke: currentColor;
  color: var(--spot);
  opacity: 0.9;
}

.stat .ic [fill="none"] {
  fill: none;
}

/* Responsive */
@media (max-width: 900px) {
  .strip {
    grid-template-columns: 1fr 1fr;
  }
  .strip .stat:nth-child(2n) {
    border-right: 0;
  }
  .strip .stat:nth-child(-n + 2) {
    border-bottom: 1px solid var(--line);
  }
}

@media (max-width: 560px) {
  .strip {
    grid-template-columns: 1fr;
  }
  .strip .stat {
    border-right: 0;
    border-bottom: 1px solid var(--line);
  }
  .strip .stat:last-child {
    border-bottom: 0;
  }
}
</style>
