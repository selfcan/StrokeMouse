import type { DefaultTheme, LocaleSpecificConfig } from 'vitepress'
import { GITHUB_URL, LOCALES, type LocaleKey } from './locales'

export interface SearchTranslations {
  button: {
    buttonText: string
    buttonAriaLabel: string
  }
  modal: {
    displayDetails: string
    resetButtonTitle: string
    backButtonTitle: string
    noResultsText: string
    footer: {
      selectText: string
      navigateText: string
      closeText: string
    }
  }
}

export interface ChromeUi {
  description: string
  nav: { home: string; download: string; docs: string }
  sidebar: {
    start: string
    quickStart: string
    install: string
    permissions: string
    manual: string
    gestures: string
    actions: string
    settings: string
    config: string
    other: string
    faq: string
  }
  editLink: string
  lastUpdated: string
  outline: string
  prev: string
  next: string
  returnToTop: string
  sidebarMenu: string
  darkMode: string
  lightMode: string
  darkModeTitle: string
  footerMessage: string
  footerCopyright: string
  search: SearchTranslations
}

export const CHROME: Record<LocaleKey, ChromeUi> = {
  root: {
    description:
      'macOS 鼠标手势自定义工具。按住触发键绘制轨迹，匹配后执行快捷键、窗口操作与脚本。',
    nav: { home: '首页', download: '下载', docs: '文档' },
    sidebar: {
      start: '开始使用',
      quickStart: '快速开始',
      install: '安装与构建',
      permissions: '权限说明',
      manual: '操作手册',
      gestures: '手势系统',
      actions: '动作类型',
      settings: '设置与菜单栏',
      config: '配置文件',
      other: '其他',
      faq: '常见问题 FAQ',
    },
    editLink: '在 GitHub 上编辑此页',
    lastUpdated: '最后更新',
    outline: '本页目录',
    prev: '上一页',
    next: '下一页',
    returnToTop: '回到顶部',
    sidebarMenu: '菜单',
    darkMode: '主题',
    lightMode: '切换到浅色',
    darkModeTitle: '切换到深色',
    footerMessage: '本地工具 · 全局事件与脚本具有系统级能力',
    footerCopyright: 'StrokeMouse · 仅添加你信任的 Shell / AppleScript',
    search: {
      button: { buttonText: '搜索', buttonAriaLabel: '搜索文档' },
      modal: {
        displayDetails: '显示详情',
        resetButtonTitle: '清除查询',
        backButtonTitle: '返回',
        noResultsText: '没有找到结果',
        footer: { selectText: '选择', navigateText: '切换', closeText: '关闭' },
      },
    },
  },
  en: {
    description:
      'Custom mouse gestures for macOS. Hold a trigger button, draw a stroke, run shortcuts, window actions, and scripts.',
    nav: { home: 'Home', download: 'Download', docs: 'Docs' },
    sidebar: {
      start: 'Get started',
      quickStart: 'Quick start',
      install: 'Install & build',
      permissions: 'Permissions',
      manual: 'Manual',
      gestures: 'Gestures',
      actions: 'Actions',
      settings: 'Settings & menu bar',
      config: 'Config file',
      other: 'Other',
      faq: 'FAQ',
    },
    editLink: 'Edit this page on GitHub',
    lastUpdated: 'Last updated',
    outline: 'On this page',
    prev: 'Previous',
    next: 'Next',
    returnToTop: 'Back to top',
    sidebarMenu: 'Menu',
    darkMode: 'Theme',
    lightMode: 'Switch to light',
    darkModeTitle: 'Switch to dark',
    footerMessage: 'Local tool · Global events and scripts have system-level power',
    footerCopyright: 'StrokeMouse · Only add Shell / AppleScript you trust',
    search: {
      button: { buttonText: 'Search', buttonAriaLabel: 'Search docs' },
      modal: {
        displayDetails: 'Display details',
        resetButtonTitle: 'Reset search',
        backButtonTitle: 'Back',
        noResultsText: 'No results',
        footer: {
          selectText: 'to select',
          navigateText: 'to navigate',
          closeText: 'to close',
        },
      },
    },
  },
  'zh-hant': {
    description:
      'macOS 滑鼠手勢自訂工具。按住觸發鍵繪製軌跡，比對成功後執行快捷鍵、視窗操作與指令碼。',
    nav: { home: '首頁', download: '下載', docs: '文件' },
    sidebar: {
      start: '開始使用',
      quickStart: '快速開始',
      install: '安裝與建置',
      permissions: '權限說明',
      manual: '操作手冊',
      gestures: '手勢系統',
      actions: '動作類型',
      settings: '設定與選單列',
      config: '設定檔',
      other: '其他',
      faq: '常見問題 FAQ',
    },
    editLink: '在 GitHub 上編輯此頁',
    lastUpdated: '最後更新',
    outline: '本頁目錄',
    prev: '上一頁',
    next: '下一頁',
    returnToTop: '回到頂部',
    sidebarMenu: '選單',
    darkMode: '主題',
    lightMode: '切換到淺色',
    darkModeTitle: '切換到深色',
    footerMessage: '本機工具 · 全域事件與指令碼具有系統級能力',
    footerCopyright: 'StrokeMouse · 僅新增你信任的 Shell / AppleScript',
    search: {
      button: { buttonText: '搜尋', buttonAriaLabel: '搜尋文件' },
      modal: {
        displayDetails: '顯示詳情',
        resetButtonTitle: '清除查詢',
        backButtonTitle: '返回',
        noResultsText: '找不到結果',
        footer: { selectText: '選擇', navigateText: '切換', closeText: '關閉' },
      },
    },
  },
  ko: {
    description:
      'macOS용 마우스 제스처 도구. 트리거를 누른 채 궤적을 그리면 단축키, 윈도우 동작, 스크립트를 실행합니다.',
    nav: { home: '홈', download: '다운로드', docs: '문서' },
    sidebar: {
      start: '시작하기',
      quickStart: '빠른 시작',
      install: '설치와 빌드',
      permissions: '권한',
      manual: '사용 설명서',
      gestures: '제스처',
      actions: '동작',
      settings: '설정과 메뉴 막대',
      config: '구성 파일',
      other: '기타',
      faq: 'FAQ',
    },
    editLink: 'GitHub에서 이 페이지 편집',
    lastUpdated: '마지막 업데이트',
    outline: '이 페이지',
    prev: '이전',
    next: '다음',
    returnToTop: '맨 위로',
    sidebarMenu: '메뉴',
    darkMode: '테마',
    lightMode: '라이트로 전환',
    darkModeTitle: '다크로 전환',
    footerMessage: '로컬 도구 · 전역 이벤트와 스크립트는 시스템 수준 권한을 가집니다',
    footerCopyright: 'StrokeMouse · 신뢰하는 Shell / AppleScript만 추가하세요',
    search: {
      button: { buttonText: '검색', buttonAriaLabel: '문서 검색' },
      modal: {
        displayDetails: '자세히 보기',
        resetButtonTitle: '검색 지우기',
        backButtonTitle: '뒤로',
        noResultsText: '결과 없음',
        footer: { selectText: '선택', navigateText: '이동', closeText: '닫기' },
      },
    },
  },
  ja: {
    description:
      'macOS 向けマウスジェスチャツール。トリガーを押したまま軌跡を描き、ショートカットやウインドウ操作、スクリプトを実行します。',
    nav: { home: 'ホーム', download: 'ダウンロード', docs: 'ドキュメント' },
    sidebar: {
      start: 'はじめに',
      quickStart: 'クイックスタート',
      install: 'インストールとビルド',
      permissions: '権限',
      manual: 'マニュアル',
      gestures: 'ジェスチャ',
      actions: 'アクション',
      settings: '設定とメニューバー',
      config: '設定ファイル',
      other: 'その他',
      faq: 'FAQ',
    },
    editLink: 'GitHub でこのページを編集',
    lastUpdated: '最終更新',
    outline: 'このページ',
    prev: '前へ',
    next: '次へ',
    returnToTop: 'トップへ戻る',
    sidebarMenu: 'メニュー',
    darkMode: 'テーマ',
    lightMode: 'ライトに切り替え',
    darkModeTitle: 'ダークに切り替え',
    footerMessage: 'ローカルツール · グローバルイベントとスクリプトはシステムレベルの権限を持ちます',
    footerCopyright: 'StrokeMouse · 信頼できる Shell / AppleScript だけを追加してください',
    search: {
      button: { buttonText: '検索', buttonAriaLabel: 'ドキュメントを検索' },
      modal: {
        displayDetails: '詳細を表示',
        resetButtonTitle: '検索をクリア',
        backButtonTitle: '戻る',
        noResultsText: '結果なし',
        footer: { selectText: '選択', navigateText: '移動', closeText: '閉じる' },
      },
    },
  },
  ru: {
    description:
      'Настройка жестов мыши для macOS. Удерживайте триггер, нарисуйте траекторию и запускайте сочетания, окна и скрипты.',
    nav: { home: 'Главная', download: 'Скачать', docs: 'Документация' },
    sidebar: {
      start: 'Начало работы',
      quickStart: 'Быстрый старт',
      install: 'Установка и сборка',
      permissions: 'Доступ',
      manual: 'Руководство',
      gestures: 'Жесты',
      actions: 'Действия',
      settings: 'Настройки и строка меню',
      config: 'Файл конфигурации',
      other: 'Другое',
      faq: 'FAQ',
    },
    editLink: 'Редактировать на GitHub',
    lastUpdated: 'Обновлено',
    outline: 'На этой странице',
    prev: 'Назад',
    next: 'Далее',
    returnToTop: 'Наверх',
    sidebarMenu: 'Меню',
    darkMode: 'Тема',
    lightMode: 'Светлая тема',
    darkModeTitle: 'Тёмная тема',
    footerMessage: 'Локальный инструмент · Глобальные события и скрипты имеют системные права',
    footerCopyright: 'StrokeMouse · Добавляйте только доверенные Shell / AppleScript',
    search: {
      button: { buttonText: 'Поиск', buttonAriaLabel: 'Искать в документации' },
      modal: {
        displayDetails: 'Подробности',
        resetButtonTitle: 'Очистить запрос',
        backButtonTitle: 'Назад',
        noResultsText: 'Ничего не найдено',
        footer: { selectText: 'выбрать', navigateText: 'перейти', closeText: 'закрыть' },
      },
    },
  },
  fr: {
    description:
      'Gestes souris pour macOS. Maintenez un déclencheur, dessinez une trajectoire, lancez raccourcis, fenêtres et scripts.',
    nav: { home: 'Accueil', download: 'Télécharger', docs: 'Documentation' },
    sidebar: {
      start: 'Premiers pas',
      quickStart: 'Démarrage rapide',
      install: 'Installation et compilation',
      permissions: 'Autorisations',
      manual: 'Manuel',
      gestures: 'Gestes',
      actions: 'Actions',
      settings: 'Réglages et barre des menus',
      config: 'Fichier de config',
      other: 'Autre',
      faq: 'FAQ',
    },
    editLink: 'Modifier cette page sur GitHub',
    lastUpdated: 'Dernière mise à jour',
    outline: 'Sur cette page',
    prev: 'Précédent',
    next: 'Suivant',
    returnToTop: 'Haut de page',
    sidebarMenu: 'Menu',
    darkMode: 'Thème',
    lightMode: 'Passer en clair',
    darkModeTitle: 'Passer en sombre',
    footerMessage: 'Outil local · Les événements globaux et les scripts ont des pouvoirs système',
    footerCopyright: 'StrokeMouse · N’ajoutez que des Shell / AppleScript de confiance',
    search: {
      button: { buttonText: 'Rechercher', buttonAriaLabel: 'Rechercher dans la doc' },
      modal: {
        displayDetails: 'Afficher les détails',
        resetButtonTitle: 'Effacer la recherche',
        backButtonTitle: 'Retour',
        noResultsText: 'Aucun résultat',
        footer: { selectText: 'sélectionner', navigateText: 'naviguer', closeText: 'fermer' },
      },
    },
  },
}

export function makeLocaleConfig(key: LocaleKey): LocaleSpecificConfig<DefaultTheme.Config> {
  const loc = LOCALES[key]
  const ui = CHROME[key]
  const home = loc.prefix ? `${loc.prefix}/` : '/'
  const download = `${loc.prefix}/download`
  const guide = `${loc.prefix}/guide`
  return {
    lang: loc.htmlLang,
    title: 'StrokeMouse',
    description: ui.description,
    themeConfig: {
      nav: [
        { text: ui.nav.home, link: home },
        { text: ui.nav.download, link: download },
        {
          text: ui.nav.docs,
          link: `${guide}/getting-started`,
          activeMatch: `${guide}/`,
        },
      ],
      sidebar: {
        [`${guide}/`]: [
          {
            text: ui.sidebar.start,
            items: [
              { text: ui.sidebar.quickStart, link: `${guide}/getting-started` },
              { text: ui.sidebar.install, link: `${guide}/installation` },
              { text: ui.sidebar.permissions, link: `${guide}/permissions` },
            ],
          },
          {
            text: ui.sidebar.manual,
            items: [
              { text: ui.sidebar.gestures, link: `${guide}/gestures` },
              { text: ui.sidebar.actions, link: `${guide}/actions` },
              { text: ui.sidebar.settings, link: `${guide}/settings` },
              { text: ui.sidebar.config, link: `${guide}/config-file` },
            ],
          },
          {
            text: ui.sidebar.other,
            items: [{ text: ui.sidebar.faq, link: `${guide}/faq` }],
          },
        ],
      },
      editLink: {
        pattern: `${GITHUB_URL}/edit/main/website/docs/:path`,
        text: ui.editLink,
      },
      lastUpdated: {
        text: ui.lastUpdated,
      },
      outline: {
        label: ui.outline,
        level: [2, 3],
      },
      docFooter: {
        prev: ui.prev,
        next: ui.next,
      },
      returnToTopLabel: ui.returnToTop,
      sidebarMenuLabel: ui.sidebarMenu,
      darkModeSwitchLabel: ui.darkMode,
      lightModeSwitchTitle: ui.lightMode,
      darkModeSwitchTitle: ui.darkModeTitle,
      footer: false,
    },
  }
}
