<script setup lang="ts">
import GestureStrokeCanvas from './GestureStrokeCanvas.vue'
import { GESTURE_PATHS } from '../gesturePaths'

export interface GestureRow {
  path: string
  stroke?: string
  action: string
  note?: string
}

defineProps<{
  heading?: string
  subheading?: string
  columns: { stroke: string; action: string; note?: string }
  rows: GestureRow[]
}>()
</script>

<template>
  <section class="hd-gesture-table">
    <header v-if="heading || subheading" class="hd-table-header">
      <div v-if="subheading" class="hd-table-kicker">
        <span>{{ subheading }}</span>
      </div>
      <h2 v-if="heading" class="hd-table-heading">{{ heading }}</h2>
    </header>
    <div class="hd-table-wrap">
      <table>
        <thead>
          <tr>
            <th class="col-preview">{{ columns.stroke }}</th>
            <th>{{ columns.action }}</th>
            <th v-if="columns.note">{{ columns.note }}</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(row, i) in rows" :key="i">
            <td class="stroke-cell">
              <GestureStrokeCanvas
                v-if="GESTURE_PATHS[row.path]"
                :points="GESTURE_PATHS[row.path]"
                :delay-ms="i * 150"
                :width="64"
                :height="48"
                :line-width="2.2"
              />
            </td>
            <td class="action-cell">{{ row.action }}</td>
            <td v-if="columns.note" class="note">{{ row.note || '—' }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  </section>
</template>

<style scoped>
.hd-gesture-table {
  margin: 2.5rem 0 2rem;
}

.hd-table-header {
  margin-bottom: 1rem;
}

.hd-table-kicker {
  display: flex;
  align-items: center;
  color: var(--spot);
  font-family: var(--mono);
  font-size: 11px;
  letter-spacing: 0.12em;
  text-transform: uppercase;
  margin-bottom: 8px;
}

.hd-table-heading {
  margin: 0;
  font-family: var(--disp);
  font-size: 1.5rem;
  font-weight: 800;
  letter-spacing: -0.03em;
  color: var(--ink);
}

.hd-table-wrap {
  border: 1px solid var(--line2);
  background: var(--panel);
  overflow-x: auto;
}

table {
  width: 100%;
  margin: 0;
  border-collapse: collapse;
  font-size: 13.5px;
}

th,
td {
  padding: 10px 16px;
  border-bottom: 1px solid var(--line);
  vertical-align: middle;
  text-align: left;
}

th {
  font-family: var(--mono);
  font-size: 11px;
  letter-spacing: 0.1em;
  text-transform: uppercase;
  color: var(--ink);
  background: color-mix(in srgb, var(--panel) 90%, black);
  border-bottom: 1px solid var(--line2);
}

th.col-preview {
  width: 72px;
  text-align: center;
}

tr:last-child td {
  border-bottom: none;
}

tr:nth-child(2n) td {
  background: color-mix(in srgb, var(--bg) 40%, transparent);
}

.stroke-cell {
  width: 72px;
  text-align: center;
  padding: 8px !important;
}

.stroke-cell :deep(canvas) {
  margin: 0 auto;
  display: block;
}

.action-cell {
  color: var(--ink);
  font-weight: 500;
}

.note {
  color: var(--dim);
  font-family: var(--mono);
  font-size: 11.5px;
  white-space: nowrap;
}

@media (max-width: 640px) {
  th:nth-child(3),
  td:nth-child(3) {
    display: none;
  }
}
</style>
