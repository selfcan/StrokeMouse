import { inBrowser, type Router } from 'vitepress'
import {
  LOCALE_PREF_KEY,
  isLocaleRedirectBot,
  parseStoredLocale,
  preferredLocale,
  unprefixedRedirectPath,
} from '../config/localeDetect'
import { localeFromPathname, type LocaleKey } from '../config/locales'

export function readStoredLocale(): LocaleKey | null {
  if (!inBrowser) return null
  try {
    return parseStoredLocale(localStorage.getItem(LOCALE_PREF_KEY))
  } catch {
    return null
  }
}

export function rememberLocale(locale: LocaleKey): void {
  if (!inBrowser) return
  try {
    localStorage.setItem(LOCALE_PREF_KEY, locale)
  } catch {
    /* private mode */
  }
}

export function rememberLocaleFromHref(href: string): void {
  const path = href.split(/[?#]/, 1)[0] || href
  rememberLocale(localeFromPathname(path))
}

function browserLanguages(): string[] {
  if (navigator.languages?.length) return [...navigator.languages]
  return navigator.language ? [navigator.language] : []
}

export function resolveRedirectPath(pathname: string): string | null {
  if (!inBrowser) return null
  if (isLocaleRedirectBot(navigator.userAgent)) return null

  const current = localeFromPathname(pathname)
  if (current !== 'root') {
    rememberLocale(current)
    return null
  }

  const stored = readStoredLocale()
  const preferred = stored ?? preferredLocale(browserLanguages())
  if (!stored) rememberLocale(preferred)
  return unprefixedRedirectPath(pathname, preferred)
}

function splitHref(to: string): { pathname: string; rest: string } {
  const url = to.includes('://') ? new URL(to) : new URL(to, 'http://vitepress.local')
  return { pathname: url.pathname, rest: `${url.search}${url.hash}` }
}

export function installLocaleRedirect(router: Router): void {
  if (!inBrowser) return

  const initial = resolveRedirectPath(location.pathname)
  if (initial) {
    location.replace(`${initial}${location.search}${location.hash}`)
    return
  }

  const previous = router.onBeforeRouteChange
  router.onBeforeRouteChange = async (to) => {
    const { pathname, rest } = splitHref(to)
    const dest = resolveRedirectPath(pathname)
    if (dest) {
      const next = `${dest}${rest}`
      if (next !== to && next !== `${location.pathname}${location.search}${location.hash}`) {
        await router.go(next)
        return false
      }
    }
    if (previous) return previous(to)
  }
}