import {
  preferredLocale,
  unprefixedRedirectPath,
  isLocaleRedirectBot,
  localeRedirectInlineScript,
} from '../docs/.vitepress/config/localeDetect.ts'

const cases = [
  [['zh-Hans'], 'root'],
  [['zh-Hans-CN'], 'root'],
  [['zh_CN'], 'root'],
  [['zh-TW'], 'zh-hant'],
  [['zh-HK'], 'zh-hant'],
  [['zh-MO'], 'zh-hant'],
  [['zh-Hant'], 'zh-hant'],
  [['zh-Hant-TW'], 'zh-hant'],
  [['zh_TW'], 'zh-hant'],
  [['ja'], 'ja'],
  [['ja-JP'], 'ja'],
  [['ko'], 'ko'],
  [['ko-KR'], 'ko'],
  [['ru'], 'ru'],
  [['ru-RU'], 'ru'],
  [['fr'], 'fr'],
  [['fr-FR'], 'fr'],
  [['en'], 'en'],
  [['en-US'], 'en'],
  [['de-DE'], 'en'],
  [['de-DE', 'fr-FR'], 'fr'],
  [['es-ES', 'en-US'], 'en'],
  [['zh'], 'root'],
]

let failed = 0
for (const [langs, expected] of cases) {
  const got = preferredLocale(langs)
  if (got !== expected) {
    failed += 1
    console.log('FAIL preferred', langs, 'got', got, 'expected', expected)
  }
}

const pathCases = [
  ['/', 'en', '/en/'],
  ['/', 'root', null],
  ['/', 'ja', '/ja/'],
  ['/guide/faq', 'fr', '/fr/guide/faq'],
  ['/download', 'ko', '/ko/download'],
  ['/en/', 'ja', null],
  ['/guide/not-a-page', 'en', null],
  ['/404', 'en', null],
]
for (const [path, pref, expected] of pathCases) {
  const got = unprefixedRedirectPath(path, pref)
  if (got !== expected) {
    failed += 1
    console.log('FAIL path', path, pref, 'got', got, 'expected', expected)
  }
}

if (!isLocaleRedirectBot('Mozilla/5.0 (compatible; Googlebot/2.1)')) {
  failed += 1
  console.log('FAIL googlebot')
}
if (isLocaleRedirectBot('Mozilla/5.0 (Macintosh; Intel Mac OS X) Chrome/120')) {
  failed += 1
  console.log('FAIL chrome treated as bot')
}

const script = localeRedirectInlineScript()
try {
  // eslint-disable-next-line no-new-func
  new Function(script)
} catch (error) {
  failed += 1
  console.log('FAIL script parse', error)
}

if (failed !== 0) {
  process.exitCode = 1
  console.log(`FAILED ${failed}`)
} else {
  console.log('OK')
}
