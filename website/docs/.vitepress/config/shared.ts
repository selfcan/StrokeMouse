import type { DefaultTheme, HeadConfig, UserConfig } from 'vitepress'
import { CHROME } from './chrome'
import { localeRedirectInlineScript } from './localeDetect'
import {
  GITHUB_URL,
  LOCALES,
  LOCALE_KEYS,
  isDownloadPath,
  isHomePath,
  type LocaleKey,
} from './locales'
import {
  DEFAULT_OG_IMAGE,
  FAQ_LD,
  SITE_NAME,
  SITE_TITLE,
  SITE_URL,
  absoluteUrl,
  canonicalUrl,
  hreflangTags,
  localeDownloadUrl,
  localeHomeUrl,
  pathFromRelative,
  resolveLocale,
  resolvePageSeo,
} from './seo'

export { GITHUB_URL, SITE_TITLE, SITE_URL }

export const sharedHead: HeadConfig[] = [
  [
    'script',
    {},
    `(()=>{try{var s=localStorage.getItem("vitepress-theme-appearance");if(s==="light"){document.documentElement.classList.remove("dark");document.documentElement.setAttribute("data-mode","paper");}else{document.documentElement.classList.add("dark");document.documentElement.setAttribute("data-mode","ink");}}catch(e){}})();`,
  ],
  ['script', {}, localeRedirectInlineScript()],
  ['link', { rel: 'icon', type: 'image/png', href: '/favicon.png' }],
  ['link', { rel: 'apple-touch-icon', href: '/favicon.png' }],
  ['link', { rel: 'preconnect', href: 'https://fonts.googleapis.com' }],
  ['link', { rel: 'preconnect', href: 'https://fonts.gstatic.com', crossorigin: '' }],
  [
    'link',
    {
      rel: 'stylesheet',
      href: 'https://fonts.googleapis.com/css2?family=Archivo:ital,wght@0,600;0,700;0,800;0,900;1,800;1,900&family=Inter:wght@400;500;600;700&family=JetBrains+Mono:ital,wght@0,400;0,500;0,600;0,700;1,400&display=swap',
    },
  ],
  ['meta', { name: 'theme-color', content: '#17171a' }],
  ['meta', { name: 'author', content: 'StrokeMouse' }],
  ['meta', { name: 'robots', content: 'index, follow, max-image-preview:large' }],
  ['meta', { name: 'googlebot', content: 'index, follow' }],
  ['meta', { name: 'format-detection', content: 'telephone=no' }],
  [
    'meta',
    {
      name: 'viewport',
      content: 'width=device-width,initial-scale=1',
    },
  ],
  ['meta', { property: 'og:site_name', content: SITE_NAME }],
  ['meta', { property: 'og:type', content: 'website' }],
  ['meta', { property: 'og:image', content: DEFAULT_OG_IMAGE }],
  ['meta', { property: 'og:image:alt', content: 'StrokeMouse' }],
  ['meta', { name: 'twitter:card', content: 'summary' }],
  ['meta', { name: 'twitter:image', content: DEFAULT_OG_IMAGE }],
]

export const socialLinks: DefaultTheme.SocialLink[] = [
  { icon: 'github', link: GITHUB_URL },
]

function searchLocales(): Record<string, { translations: (typeof CHROME)[LocaleKey]['search'] }> {
  const locales: Record<string, { translations: (typeof CHROME)[LocaleKey]['search'] }> = {}
  for (const key of LOCALE_KEYS) {
    locales[key] = { translations: CHROME[key].search }
  }
  return locales
}

export const sharedConfig: UserConfig = {
  title: SITE_TITLE,
  cleanUrls: true,
  lastUpdated: true,
  ignoreDeadLinks: false,
  appearance: 'dark',
  head: sharedHead,

  transformPageData(pageData) {
    const seo = resolvePageSeo(pageData.relativePath)
    const locale = resolveLocale(pageData.relativePath)
    const isHome = pageData.relativePath.replace(/\\/g, '/').endsWith('index.md')

    pageData.description = seo.description
    if (isHome) {
      pageData.title = seo.title
      pageData.frontmatter = {
        ...pageData.frontmatter,
        title: seo.title,
        description: seo.description,
        titleTemplate: LOCALES[locale].titleTemplate,
      }
    } else {
      const full = `${seo.title} | ${SITE_TITLE}`
      pageData.title = full
      pageData.frontmatter = {
        ...pageData.frontmatter,
        title: full,
        description: seo.description,
        titleTemplate: false,
      }
    }
  },

  transformHead({ pageData }) {
    const seo = resolvePageSeo(pageData.relativePath)
    const locale = resolveLocale(pageData.relativePath)
    const pathname = pathFromRelative(pageData.relativePath)
    const canonical = canonicalUrl(pathname)
    const loc = LOCALES[locale]
    const fullTitle =
      seo.title === SITE_TITLE
        ? `${SITE_TITLE} - ${loc.titleTemplate}`
        : `${seo.title} | ${SITE_TITLE}`

    const tags: HeadConfig[] = [
      ['meta', { name: 'description', content: seo.description }],
      ['meta', { name: 'keywords', content: seo.keywords }],
      ['link', { rel: 'canonical', href: canonical }],
    ]

    for (const alt of hreflangTags(pathname)) {
      tags.push(['link', { rel: 'alternate', hreflang: alt.hreflang, href: alt.href }])
    }

    tags.push(
      ['meta', { property: 'og:title', content: fullTitle }],
      ['meta', { property: 'og:description', content: seo.description }],
      ['meta', { property: 'og:url', content: canonical }],
      ['meta', { property: 'og:type', content: seo.ogType ?? 'website' }],
      ['meta', { property: 'og:locale', content: loc.ogLocale }],
    )

    for (const key of LOCALE_KEYS) {
      if (key === locale) continue
      tags.push(['meta', { property: 'og:locale:alternate', content: LOCALES[key].ogLocale }])
    }

    tags.push(
      ['meta', { property: 'og:site_name', content: SITE_NAME }],
      ['meta', { property: 'og:image', content: DEFAULT_OG_IMAGE }],
      ['meta', { property: 'og:image:alt', content: fullTitle }],
      ['meta', { name: 'twitter:card', content: 'summary' }],
      ['meta', { name: 'twitter:title', content: fullTitle }],
      ['meta', { name: 'twitter:description', content: seo.description }],
      ['meta', { name: 'twitter:image', content: DEFAULT_OG_IMAGE }],
    )

    const webPageLd = {
      '@context': 'https://schema.org',
      '@type': isHomePath(pathname) ? 'WebSite' : 'WebPage',
      name: fullTitle,
      description: seo.description,
      url: canonical,
      inLanguage: loc.htmlLang,
      isPartOf: {
        '@type': 'WebSite',
        name: SITE_NAME,
        url: SITE_URL,
      },
    }
    tags.push(['script', { type: 'application/ld+json' }, JSON.stringify(webPageLd)])

    if (isHomePath(pathname) || isDownloadPath(pathname)) {
      const appLd = {
        '@context': 'https://schema.org',
        '@type': 'SoftwareApplication',
        name: 'StrokeMouse',
        applicationCategory: 'UtilitiesApplication',
        operatingSystem: 'macOS 14 or later',
        description: seo.description,
        url: localeHomeUrl(locale),
        downloadUrl: localeDownloadUrl(locale),
        image: DEFAULT_OG_IMAGE,
        offers: {
          '@type': 'Offer',
          price: '0',
          priceCurrency: 'USD',
        },
      }
      tags.push(['script', { type: 'application/ld+json' }, JSON.stringify(appLd)])
    }

    if (pathname.replace(/\/$/, '').endsWith('/guide/faq')) {
      const faqLd = {
        '@context': 'https://schema.org',
        '@type': 'FAQPage',
        mainEntity: FAQ_LD[locale].map((item) => ({
          '@type': 'Question',
          name: item.name,
          acceptedAnswer: {
            '@type': 'Answer',
            text: item.text,
          },
        })),
      }
      tags.push(['script', { type: 'application/ld+json' }, JSON.stringify(faqLd)])
    }

    return tags
  },

  sitemap: {
    hostname: SITE_URL,
    transformItems(items) {
      return items.map((item) => {
        const path = `/${item.url}`.replace(/\/{2,}/g, '/').replace(/\/$/, '') || '/'
        const isHome = isHomePath(path)
        const isDownload = isDownloadPath(path)
        const isQuickStart = path.includes('/guide/getting-started')
        return {
          ...item,
          changefreq: isHome ? ('weekly' as const) : ('monthly' as const),
          priority: isHome ? 1.0 : isDownload ? 0.9 : isQuickStart ? 0.85 : 0.7,
        }
      })
    },
  },
  markdown: {
    theme: {
      light: 'github-light',
      dark: 'github-dark',
    },
    lineNumbers: false,
  },
  themeConfig: {
    logo: { src: '/logo.svg', alt: 'StrokeMouse' },
    socialLinks,
    outline: { level: [2, 3] },
    externalLinkIcon: true,
    search: {
      provider: 'local',
      options: {
        locales: searchLocales(),
      },
    },
  },
}
