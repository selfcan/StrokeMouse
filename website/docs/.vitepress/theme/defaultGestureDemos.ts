/** Shared demo set for homepage HUD + default gesture table */

export interface GestureDemo {
  path: string
  /** Simulated match score 0–1 */
  score: number
}

export const DEFAULT_GESTURE_DEMOS: GestureDemo[] = [
  { path: 'up', score: 0.96 },
  { path: 'down', score: 0.94 },
  { path: 'downLeft', score: 0.93 },
  { path: 'downRight', score: 0.95 },
  { path: 'upRight', score: 0.92 },
  { path: 'rightLeft', score: 0.91 },
  { path: 'upLeft', score: 0.94 },
]
