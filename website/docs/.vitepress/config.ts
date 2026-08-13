import { defineConfig } from 'vitepress'
import { makeLocaleConfig } from './config/chrome'
import { LOCALES, LOCALE_KEYS } from './config/locales'
import { sharedConfig } from './config/shared'

export default defineConfig({
  ...sharedConfig,
  locales: Object.fromEntries(
    LOCALE_KEYS.map((key) => [
      key,
      {
        label: LOCALES[key].label,
        lang: LOCALES[key].htmlLang,
        ...makeLocaleConfig(key),
      },
    ]),
  ),
  vite: {
    server: {
      port: 9243,
      strictPort: true,
    },
    preview: {
      port: 9243,
      strictPort: true,
    },
  },
})
