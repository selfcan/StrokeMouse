<script setup lang="ts">
defineProps<{
  title?: string
  lines: string[]
  prompt?: string
}>()
</script>

<template>
  <section class="hd-term">
    <div class="hd-term-bar">
      <div class="hd-term-dots">
        <span class="dot red" />
        <span class="dot yellow" />
        <span class="dot green" />
      </div>
      <span class="hd-term-title">{{ title || 'terminal' }}</span>
    </div>
    <div class="hd-term-body">
      <p v-for="(line, i) in lines" :key="i" class="hd-term-line">
        <span v-if="prompt !== ''" class="hd-term-prompt">{{ prompt ?? '$' }}</span>
        <span class="hd-term-text">{{ line }}</span>
      </p>
    </div>
  </section>
</template>

<style scoped>
.hd-term {
  margin: 1.5rem 0;
  border: 1px solid var(--line2);
  background: var(--panel);
  box-sizing: border-box;
}

.hd-term-bar {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 14px;
  border-bottom: 1px solid var(--line);
  background: color-mix(in srgb, var(--panel) 94%, black);
}

.hd-term-dots {
  display: flex;
  align-items: center;
  gap: 6px;
}

.dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  flex-shrink: 0;
}

.dot.red {
  background: #f38ba8;
}

.dot.yellow {
  background: #f9e2af;
}

.dot.green {
  background: #a6e3a1;
}

.hd-term-title {
  margin-left: 6px;
  font-family: var(--mono);
  font-size: 11px;
  color: var(--faint);
  letter-spacing: 0.06em;
  text-transform: uppercase;
}

.hd-term-body {
  margin: 0;
  padding: 14px 16px;
  font-family: var(--mono);
  font-size: 12.5px;
  line-height: 1.7;
  color: var(--ink);
  overflow-x: auto;
  background: var(--bg);
}

.hd-term-line {
  margin: 0;
  display: flex;
  gap: 10px;
  align-items: baseline;
}

.hd-term-prompt {
  color: var(--spot);
  user-select: none;
  flex-shrink: 0;
  font-weight: 500;
}

.hd-term-text {
  color: var(--dim);
  word-break: break-word;
}
</style>
