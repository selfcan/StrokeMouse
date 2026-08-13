/**
 * First-visit locale detection — same matching rules as the macOS app
 * (`LanguageOverride.catalogLocale`): walk navigator.languages, map zh-Hant
 * regions to Traditional Chinese, and fall unmatched lists back to English.
 *
 * Unprefixed paths (`/`, `/guide/...`) are the unspecified-language URLs and
 * may be rewritten. Prefixed URLs are explicit and only update the memory.
 */

import {
  LOCALES,
  LOCALE_KEYS,
  X_DEFAULT_LOCALE,
  isLocaleKey,
  localeFromPathname,
  localePath,
  pageIdFromPathname,
  type LocaleKey,
} from './locales'

export const LOCALE_PREF_KEY = 'sm-locale'

const REDIRECTABLE_PAGES = new Set([
  'index',
  'download',
  'guide/getting-started',
  'guide/installation',
  'guide/permissions',
  'guide/gestures',
  'guide/actions',
  'guide/settings',
  'guide/config-file',
  'guide/faq',
])

const PREFIXED_LOCALES = LOCALE_KEYS.filter((key) => LOCALES[key].prefix).sort(
  (a, b) => LOCALES[b].prefix.length - LOCALES[a].prefix.length,
)

export function matchPreferredLanguage(identifier: string): LocaleKey | undefined {
  const normalized = String(identifier || '').replace(/_/g, '-')
  const parts = normalized.split('-').filter(Boolean)
  const language = parts[0]?.toLowerCase()
  if (!language) return undefined
  if (language === 'en') return 'en'
  if (language === 'ko') return 'ko'
  if (language === 'ja') return 'ja'
  if (language === 'ru') return 'ru'
  if (language === 'fr') return 'fr'
  if (language !== 'zh') return undefined
  const tokens = new Set(parts.map((part) => part.toLowerCase()))
  if (tokens.has('hant') || tokens.has('tw') || tokens.has('hk') || tokens.has('mo')) {
    return 'zh-hant'
  }
  return 'root'
}

export function preferredLocale(languages: readonly string[]): LocaleKey {
  for (const identifier of languages) {
    const matched = matchPreferredLanguage(identifier)
    if (matched) return matched
  }
  return X_DEFAULT_LOCALE
}

export function isLocaleRedirectBot(userAgent: string): boolean {
  return /bot|crawl|spider|slurp|bingpreview|facebookexternalhit|linkedinbot|embedly|quora|pinterest|redditbot|whatsapp|telegram|skypeuri|vkshare|w3c_validator|lighthouse/i.test(
    userAgent,
  )
}

export function normalizeLocalePathname(pathname: string): string {
  if (pathname === '/index.html') return '/'
  return pathname.replace(/\/index\.html$/, '/')
}

export function parseStoredLocale(value: string | null | undefined): LocaleKey | null {
  if (!value || !isLocaleKey(value)) return null
  return value
}

export function unprefixedRedirectPath(
  pathname: string,
  preferred: LocaleKey,
): string | null {
  const clean = normalizeLocalePathname(pathname)
  if (preferred === 'root') return null
  if (localeFromPathname(clean) !== 'root') return null
  const pageId = pageIdFromPathname(clean)
  if (!REDIRECTABLE_PAGES.has(pageId)) return null
  return pageId === 'index' ? localePath(preferred, '/') : localePath(preferred, `/${pageId}`)
}

/** Build the blocking head script so the first paint is already the right locale. */
export function localeRedirectInlineScript(): string {
  const prefixes = Object.fromEntries(
    PREFIXED_LOCALES.map((key) => [key, LOCALES[key].prefix]),
  )
  return `(function(){try{
var KEY=${JSON.stringify(LOCALE_PREF_KEY)};
var FALLBACK=${JSON.stringify(X_DEFAULT_LOCALE)};
var PREFIX=${JSON.stringify(prefixes)};
var PAGES=${JSON.stringify([...REDIRECTABLE_PAGES])};
var PREFIXED=${JSON.stringify(PREFIXED_LOCALES)};
var matchPreferredLanguage=${matchPreferredLanguage.toString()};
var isLocaleRedirectBot=${isLocaleRedirectBot.toString()};
function persist(value){try{localStorage.setItem(KEY,value)}catch(e){}}
function readStored(){try{return localStorage.getItem(KEY)}catch(e){return null}}
function currentLocale(path){
  for(var i=0;i<PREFIXED.length;i++){
    var pre=PREFIX[PREFIXED[i]];
    if(path===pre||path.indexOf(pre+'/')===0) return PREFIXED[i];
  }
  return 'root';
}
function normalize(path){
  if(path==='/index.html') return '/';
  path=path.replace(/\\/index\\.html$/,'/');
  return path.replace(/\\/$/,'')||'/';
}
function pageIdOfRoot(path){
  return path==='/'?'index':path.replace(/^\\//,'');
}
var path=normalize(location.pathname);
var locale=currentLocale(path);
if(locale!=='root'){persist(locale);return}
if(isLocaleRedirectBot(navigator.userAgent||'')) return;
var stored=readStored();
if(stored&&stored!=='root'&&!PREFIX[stored]) stored=null;
var target=stored;
if(!target){
  var list=(navigator.languages&&navigator.languages.length)?navigator.languages:[navigator.language];
  for(var i=0;i<list.length;i++){
    var hit=matchPreferredLanguage(list[i]||'');
    if(hit){target=hit;break}
  }
  if(!target) target=FALLBACK;
  persist(target);
}
if(target==='root') return;
var id=pageIdOfRoot(path);
if(PAGES.indexOf(id)<0) return;
var dest=id==='index'?PREFIX[target]+'/':PREFIX[target]+'/'+id;
if(dest===location.pathname) return;
location.replace(dest+location.search+location.hash);
}catch(e){}})();`
}
