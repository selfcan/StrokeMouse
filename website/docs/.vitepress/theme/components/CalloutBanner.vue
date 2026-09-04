<script setup lang="ts">
withDefaults(
  defineProps<{
    title: string
    body: string
    variant?: 'info' | 'warn'
  }>(),
  { variant: 'info' },
)
</script>

<template>
  <aside class="hd-callout" :class="`hd-callout--${variant}`">
    <div class="hd-callout-label">
      <span class="hd-callout-mark">{{ variant === 'warn' ? '!' : '>' }}</span>
      <span>{{ title }}</span>
    </div>
    <p class="hd-callout-body">{{ body }}</p>
  </aside>
</template>

<style scoped>
.hd-callout {
  margin: 2rem 0;
  padding: 14px 18px;
  border: 1px solid var(--line2);
  border-left: 3px solid var(--spot);
  background: var(--panel);
}

.hd-callout--warn {
  border-left-color: var(--yellow);
}

.hd-callout-label {
  display: flex;
  align-items: center;
  gap: 8px;
  font-family: var(--mono);
  font-size: 11px;
  letter-spacing: 0.1em;
  text-transform: uppercase;
  color: var(--spot);
  margin-bottom: 6px;
  font-weight: 600;
}

.hd-callout--warn .hd-callout-label {
  color: var(--yellow);
}

.hd-callout-mark {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 16px;
  height: 16px;
  background: color-mix(in srgb, var(--spot) 15%, transparent);
  font-size: 11px;
}

.hd-callout--warn .hd-callout-mark {
  background: color-mix(in srgb, var(--yellow) 15%, transparent);
}

.hd-callout-body {
  margin: 0;
  font-size: 13.5px;
  line-height: 1.65;
  color: var(--dim);
}
</style>
