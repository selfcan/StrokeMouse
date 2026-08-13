/**
 * Site locales — keep in sync with README language set:
 * English, zh-Hans, zh-Hant, Korean, Japanese, Russian, French.
 *
 * Root stays Simplified Chinese so existing `/` and `/guide/` URLs remain valid.
 */

export const GITHUB_URL = 'https://github.com/Licoy/StrokeMouse'

export const LOCALE_KEYS = [
  'root',
  'en',
  'zh-hant',
  'ko',
  'ja',
  'ru',
  'fr',
] as const

export type LocaleKey = (typeof LOCALE_KEYS)[number]

export interface LocaleDef {
  key: LocaleKey
  /** Directory under docs/; empty for root. */
  dir: string
  /** URL prefix beginning with `/`, or empty for root. */
  prefix: string
  /** Native language name in the locale picker. */
  label: string
  htmlLang: string
  ogLocale: string
  hreflang: string
  titleTemplate: string
}

export const LOCALES: Record<LocaleKey, LocaleDef> = {
  root: {
    key: 'root',
    dir: '',
    prefix: '',
    label: '简体中文',
    htmlLang: 'zh-CN',
    ogLocale: 'zh_CN',
    hreflang: 'zh-CN',
    titleTemplate: 'macOS 鼠标与触控板手势',
  },
  en: {
    key: 'en',
    dir: 'en',
    prefix: '/en',
    label: 'English',
    htmlLang: 'en-US',
    ogLocale: 'en_US',
    hreflang: 'en-US',
    titleTemplate: 'Mouse & trackpad gestures for macOS',
  },
  'zh-hant': {
    key: 'zh-hant',
    dir: 'zh-hant',
    prefix: '/zh-hant',
    label: '繁體中文',
    htmlLang: 'zh-Hant',
    ogLocale: 'zh_TW',
    hreflang: 'zh-Hant',
    titleTemplate: 'macOS 滑鼠與觸控式軌跡板手勢',
  },
  ko: {
    key: 'ko',
    dir: 'ko',
    prefix: '/ko',
    label: '한국어',
    htmlLang: 'ko',
    ogLocale: 'ko_KR',
    hreflang: 'ko',
    titleTemplate: 'macOS 마우스와 트랙패드 제스처',
  },
  ja: {
    key: 'ja',
    dir: 'ja',
    prefix: '/ja',
    label: '日本語',
    htmlLang: 'ja',
    ogLocale: 'ja_JP',
    hreflang: 'ja',
    titleTemplate: 'macOS のマウス／トラックパッドジェスチャ',
  },
  ru: {
    key: 'ru',
    dir: 'ru',
    prefix: '/ru',
    label: 'Русский',
    htmlLang: 'ru',
    ogLocale: 'ru_RU',
    hreflang: 'ru',
    titleTemplate: 'Жесты мыши и трекпада для macOS',
  },
  fr: {
    key: 'fr',
    dir: 'fr',
    prefix: '/fr',
    label: 'Français',
    htmlLang: 'fr',
    ogLocale: 'fr_FR',
    hreflang: 'fr',
    titleTemplate: 'Gestes souris et trackpad pour macOS',
  },
}

/** Unmatched Accept-Language falls back to English. */
export const X_DEFAULT_LOCALE: LocaleKey = 'en'

export function localePath(locale: LocaleKey, path: string): string {
  const clean = !path || path === '/' ? '/' : path.startsWith('/') ? path : `/${path}`
  const prefix = LOCALES[locale].prefix
  if (!prefix) return clean
  if (clean === '/') return `${prefix}/`
  return `${prefix}${clean}`
}

export function parseRelativePath(relativePath: string): { locale: LocaleKey; pageId: string } {
  const key = relativePath.replace(/\\/g, '/').replace(/\.md$/i, '')
  const prefixed = LOCALE_KEYS.filter((k) => LOCALES[k].dir).sort(
    (a, b) => LOCALES[b].dir.length - LOCALES[a].dir.length,
  )
  for (const locale of prefixed) {
    const dir = LOCALES[locale].dir
    if (key === dir || key === `${dir}/index`) return { locale, pageId: 'index' }
    if (key.startsWith(`${dir}/`)) {
      const rest = key.slice(dir.length + 1)
      return { locale, pageId: rest === 'index' || rest === '' ? 'index' : rest }
    }
  }
  if (key === 'index' || key === '') return { locale: 'root', pageId: 'index' }
  return { locale: 'root', pageId: key }
}

export function pathFromRelative(relativePath: string): string {
  const { locale, pageId } = parseRelativePath(relativePath)
  if (pageId === 'index') return localePath(locale, '/')
  return localePath(locale, `/${pageId}`)
}

export function localeFromPathname(pathname: string): LocaleKey {
  const clean = pathname.replace(/\/$/, '') || '/'
  const prefixed = LOCALE_KEYS.filter((k) => LOCALES[k].prefix).sort(
    (a, b) => LOCALES[b].prefix.length - LOCALES[a].prefix.length,
  )
  for (const locale of prefixed) {
    const prefix = LOCALES[locale].prefix
    if (clean === prefix || clean.startsWith(`${prefix}/`)) return locale
  }
  return 'root'
}

export function pageIdFromPathname(pathname: string): string {
  const clean = pathname.replace(/\/$/, '') || '/'
  const locale = localeFromPathname(clean)
  const prefix = LOCALES[locale].prefix
  if (!prefix) return clean === '/' ? 'index' : clean.replace(/^\//, '')
  if (clean === prefix) return 'index'
  return clean.slice(prefix.length + 1) || 'index'
}

export function alternatePaths(pathname: string): Record<LocaleKey, string> {
  const pageId = pageIdFromPathname(pathname)
  const result = {} as Record<LocaleKey, string>
  for (const locale of LOCALE_KEYS) {
    result[locale] = pageId === 'index' ? localePath(locale, '/') : localePath(locale, `/${pageId}`)
  }
  return result
}

export function isHomePath(pathname: string): boolean {
  const clean = pathname.replace(/\/$/, '') || '/'
  return LOCALE_KEYS.some((key) => {
    const home = localePath(key, '/').replace(/\/$/, '') || '/'
    return clean === home
  })
}

export function isDownloadPath(pathname: string): boolean {
  const clean = pathname.replace(/\/$/, '')
  return clean === '/download' || clean.endsWith('/download')
}
