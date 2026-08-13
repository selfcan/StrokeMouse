import { computed } from 'vue'
import { useData } from 'vitepress'

export type SiteLocale = 'zh-Hans' | 'zh-Hant' | 'en' | 'ko' | 'ja' | 'ru' | 'fr'

const PREFIX: Record<SiteLocale, string> = {
  'zh-Hans': '',
  'zh-Hant': '/zh-hant',
  en: '/en',
  ko: '/ko',
  ja: '/ja',
  ru: '/ru',
  fr: '/fr',
}

export function resolveSiteLocale(lang: string | undefined): SiteLocale {
  const value = (lang ?? '').toLowerCase()
  if (value.startsWith('zh-hant') || value.includes('zh-tw') || value.includes('zh-hk')) {
    return 'zh-Hant'
  }
  if (value.startsWith('zh')) return 'zh-Hans'
  if (value.startsWith('ko')) return 'ko'
  if (value.startsWith('ja')) return 'ja'
  if (value.startsWith('ru')) return 'ru'
  if (value.startsWith('fr')) return 'fr'
  if (value.startsWith('en')) return 'en'
  return 'zh-Hans'
}

export function localePrefix(locale: SiteLocale): string {
  return PREFIX[locale]
}

export function localeHref(locale: SiteLocale, path: string): string {
  const clean = path.startsWith('/') ? path : `/${path}`
  const prefix = PREFIX[locale]
  if (!prefix) return clean
  return `${prefix}${clean}`
}

export function useSiteLocale() {
  const { lang } = useData()
  return computed(() => resolveSiteLocale(lang.value))
}

export interface DownloadCopy {
  title: string
  lead: string
  homebrewTitle: string
  homebrewDesc: string
  homebrewNote: string
  manual: string
  armTitle: string
  armDesc: string
  intelTitle: string
  intelDesc: string
  get: string
  reqLabel: string
  reqValue: string
  installTitle: string
  steps: string[]
  releases: string
  source: string
  note: string
}

export interface FooterCopy {
  docs: string
  download: string
  install: string
  github: string
}

export interface GestureUi {
  trigger: string
  matched: string
  capture: string
  matchLabel: (pct: number) => string
  columns: { stroke: string; action: string; note: string }
}

const DOWNLOAD: Record<SiteLocale, DownloadCopy> = {
  'zh-Hans': {
    title: '下载 StrokeMouse',
    lead: 'macOS 生产构建。请按芯片架构选择对应安装包。',
    homebrewTitle: 'Homebrew（推荐）',
    homebrewDesc:
      '安装、升级与卸载依次使用以下命令；安装命令会自动添加 StrokeMouse 项目维护的 Tap。',
    homebrewNote: 'StrokeMouse 同时支持应用内更新，因此 Homebrew 升级命令使用 --greedy。',
    manual: '手动下载 DMG',
    armTitle: 'Apple Silicon',
    armDesc: 'M1 / M2 / M3 / M4 及更新芯片',
    intelTitle: 'Intel',
    intelDesc: 'Intel 处理器 Mac',
    get: '下载',
    reqLabel: '系统要求',
    reqValue: 'macOS 14 Sonoma 或更高',
    installTitle: 'DMG 安装说明',
    steps: [
      '下载对应架构的 .dmg 安装包',
      '打开 .dmg，将 StrokeMouse 拖入「应用程序」',
      '首次启动请右键点按 App 并选择「打开」，或在「隐私与安全性」中选择「仍要打开」',
      '首次启动后，在「系统设置 → 隐私与安全性 → 辅助功能」中授权',
      '打开设置 → 手势，开始配置',
    ],
    releases: '全部发行版',
    source: '从源码构建',
    note: '当前版本使用固定自签代码签名且未经 Apple 公证；首次启动如被拦截，请按下方步骤在系统设置中放行。',
  },
  'zh-Hant': {
    title: '下載 StrokeMouse',
    lead: 'macOS 正式建置。請依晶片架構選擇對應安裝包。',
    homebrewTitle: 'Homebrew（建議）',
    homebrewDesc:
      '安裝、升級與解除安裝依序使用以下命令；安裝命令會自動加入 StrokeMouse 專案維護的 Tap。',
    homebrewNote: 'StrokeMouse 同時支援應用內更新，因此 Homebrew 升級命令使用 --greedy。',
    manual: '手動下載 DMG',
    armTitle: 'Apple Silicon',
    armDesc: 'M1 / M2 / M3 / M4 及更新晶片',
    intelTitle: 'Intel',
    intelDesc: 'Intel 處理器 Mac',
    get: '下載',
    reqLabel: '系統需求',
    reqValue: 'macOS 14 Sonoma 或更高',
    installTitle: 'DMG 安裝說明',
    steps: [
      '下載對應架構的 .dmg 安裝包',
      '打開 .dmg，將 StrokeMouse 拖入「應用程式」',
      '首次啟動請按住 Control 點按 App 並選擇「打開」，或在「隱私權與安全性」中選擇「仍要打開」',
      '首次啟動後，在「系統設定 → 隱私權與安全性 → 輔助使用」中授權',
      '打開設定 → 手勢，開始設定',
    ],
    releases: '全部發行版',
    source: '從原始碼建置',
    note: '目前版本使用固定自簽程式碼簽署且未經 Apple 公證；首次啟動如被攔截，請按下方步驟在系統設定中放行。',
  },
  en: {
    title: 'Download StrokeMouse',
    lead: 'Production builds for macOS. Pick the package that matches your chip.',
    homebrewTitle: 'Homebrew (recommended)',
    homebrewDesc:
      'Use these commands to install, upgrade, or uninstall. Installation automatically adds the project-maintained Licoy tap.',
    homebrewNote: 'StrokeMouse also supports in-app updates, so Homebrew upgrades use --greedy.',
    manual: 'Manual DMG download',
    armTitle: 'Apple Silicon',
    armDesc: 'M1 / M2 / M3 / M4 and later',
    intelTitle: 'Intel',
    intelDesc: 'Intel-based Mac',
    get: 'Download',
    reqLabel: 'Requirements',
    reqValue: 'macOS 14 Sonoma or later',
    installTitle: 'DMG installation',
    steps: [
      'Download the .dmg for your architecture',
      'Open the .dmg and drag StrokeMouse into Applications',
      'For first launch, right-click the app and choose Open, or use Privacy & Security → Open Anyway',
      'On first launch, grant Accessibility in System Settings → Privacy & Security',
      'Open Settings → Gestures and start configuring',
    ],
    releases: 'All releases',
    source: 'Build from source',
    note: 'Current releases use a stable self-signed identity and are not Apple-notarized. If first launch is blocked, follow the steps below to approve the app in System Settings.',
  },
  ko: {
    title: 'StrokeMouse 다운로드',
    lead: 'macOS 프로덕션 빌드입니다. 칩에 맞는 패키지를 선택하세요.',
    homebrewTitle: 'Homebrew(권장)',
    homebrewDesc:
      '설치, 업그레이드, 제거는 아래 명령을 사용합니다. 설치 시 StrokeMouse 프로젝트가 관리하는 Tap이 자동으로 추가됩니다.',
    homebrewNote: 'StrokeMouse는 앱 내 업데이트도 지원하므로 Homebrew 업그레이드에 --greedy를 사용합니다.',
    manual: 'DMG 직접 다운로드',
    armTitle: 'Apple Silicon',
    armDesc: 'M1 / M2 / M3 / M4 및 이후 칩',
    intelTitle: 'Intel',
    intelDesc: 'Intel 프로세서 Mac',
    get: '다운로드',
    reqLabel: '시스템 요구 사항',
    reqValue: 'macOS 14 Sonoma 이상',
    installTitle: 'DMG 설치',
    steps: [
      '아키텍처에 맞는 .dmg를 다운로드합니다',
      '.dmg를 열고 StrokeMouse를 응용 프로그램으로 드래그합니다',
      '처음 실행할 때는 앱을 Control-클릭한 뒤 「열기」를 선택하거나 「개인정보 보호 및 보안」에서 「계속 열기」를 선택합니다',
      '처음 실행 후 「시스템 설정 → 개인정보 보호 및 보안 → 손쉬운 사용」에서 권한을 허용합니다',
      '설정 → 제스처를 열고 구성을 시작합니다',
    ],
    releases: '모든 릴리스',
    source: '소스에서 빌드',
    note: '현재 릴리스는 고정 자체 서명 신원을 사용하며 Apple 공증을 받지 않았습니다. 첫 실행이 차단되면 아래 단계로 시스템 설정에서 허용하세요.',
  },
  ja: {
    title: 'StrokeMouse をダウンロード',
    lead: 'macOS 向けの製品ビルドです。チップに合ったパッケージを選んでください。',
    homebrewTitle: 'Homebrew（推奨）',
    homebrewDesc:
      'インストール、アップグレード、アンインストールは次のコマンドを使います。インストール時に StrokeMouse プロジェクト管理の Tap が自動追加されます。',
    homebrewNote: 'StrokeMouse はアプリ内アップデートにも対応するため、Homebrew のアップグレードは --greedy を使います。',
    manual: 'DMG を手動ダウンロード',
    armTitle: 'Apple Silicon',
    armDesc: 'M1 / M2 / M3 / M4 以降',
    intelTitle: 'Intel',
    intelDesc: 'Intel プロセッサの Mac',
    get: 'ダウンロード',
    reqLabel: 'システム要件',
    reqValue: 'macOS 14 Sonoma 以降',
    installTitle: 'DMG のインストール',
    steps: [
      'アーキテクチャに合った .dmg をダウンロードします',
      '.dmg を開き、StrokeMouse を「アプリケーション」にドラッグします',
      '初回起動は App を Control クリックして「開く」を選ぶか、「プライバシーとセキュリティ」で「このまま開く」を選びます',
      '初回起動後、「システム設定 → プライバシーとセキュリティ → アクセシビリティ」で許可します',
      '設定 → ジェスチャを開き、構成を始めます',
    ],
    releases: 'すべてのリリース',
    source: 'ソースからビルド',
    note: '現行リリースは固定の自己署名 ID を使い、Apple の公証は受けていません。初回起動がブロックされたら、下の手順でシステム設定から許可してください。',
  },
  ru: {
    title: 'Скачать StrokeMouse',
    lead: 'Производственные сборки для macOS. Выберите пакет под свой процессор.',
    homebrewTitle: 'Homebrew (рекомендуется)',
    homebrewDesc:
      'Для установки, обновления и удаления используйте эти команды. Установка автоматически добавляет поддерживаемый проектом StrokeMouse Tap.',
    homebrewNote:
      'StrokeMouse также обновляется из приложения, поэтому команда обновления Homebrew использует --greedy.',
    manual: 'Скачать DMG вручную',
    armTitle: 'Apple Silicon',
    armDesc: 'M1 / M2 / M3 / M4 и новее',
    intelTitle: 'Intel',
    intelDesc: 'Mac на процессоре Intel',
    get: 'Скачать',
    reqLabel: 'Системные требования',
    reqValue: 'macOS 14 Sonoma или новее',
    installTitle: 'Установка из DMG',
    steps: [
      'Скачайте .dmg для своей архитектуры',
      'Откройте .dmg и перетащите StrokeMouse в «Программы»',
      'При первом запуске нажмите Control и щёлкните приложение, выберите «Открыть», либо «Конфиденциальность и безопасность → Всё равно открыть»',
      'После первого запуска выдайте Универсальный доступ в «Системные настройки → Конфиденциальность и безопасность»',
      'Откройте Настройки → Жесты и начните настройку',
    ],
    releases: 'Все выпуски',
    source: 'Собрать из исходников',
    note: 'Текущие выпуски используют стабильную самоподписанную подпись и не нотаризованы Apple. Если первый запуск заблокирован, разрешите приложение в системных настройках по шагам ниже.',
  },
  fr: {
    title: 'Télécharger StrokeMouse',
    lead: 'Builds de production pour macOS. Choisissez le paquet qui correspond à votre puce.',
    homebrewTitle: 'Homebrew (recommandé)',
    homebrewDesc:
      'Utilisez ces commandes pour installer, mettre à jour ou désinstaller. L’installation ajoute automatiquement le tap maintenu par le projet StrokeMouse.',
    homebrewNote:
      'StrokeMouse gère aussi les mises à jour dans l’app, donc la commande Homebrew utilise --greedy.',
    manual: 'Télécharger le DMG manuellement',
    armTitle: 'Apple Silicon',
    armDesc: 'M1 / M2 / M3 / M4 et suivants',
    intelTitle: 'Intel',
    intelDesc: 'Mac à processeur Intel',
    get: 'Télécharger',
    reqLabel: 'Configuration requise',
    reqValue: 'macOS 14 Sonoma ou ultérieur',
    installTitle: 'Installation du DMG',
    steps: [
      'Téléchargez le .dmg de votre architecture',
      'Ouvrez le .dmg et glissez StrokeMouse dans Applications',
      'Au premier lancement, cliquez l’app en maintenant Contrôle puis choisissez Ouvrir, ou Confidentialité et sécurité → Ouvrir quand même',
      'Après le premier lancement, accordez l’Accessibilité dans Réglages Système → Confidentialité et sécurité',
      'Ouvrez Réglages → Gestes et commencez la configuration',
    ],
    releases: 'Toutes les versions',
    source: 'Compiler depuis les sources',
    note: 'Les versions actuelles utilisent une identité auto-signée stable et ne sont pas notariées par Apple. Si le premier lancement est bloqué, suivez les étapes ci-dessous dans Réglages Système.',
  },
}

const FOOTER: Record<SiteLocale, FooterCopy> = {
  'zh-Hans': { docs: '文档', download: '下载', install: '源码构建', github: '源码' },
  'zh-Hant': { docs: '文件', download: '下載', install: '原始碼建置', github: '原始碼' },
  en: { docs: 'Docs', download: 'Download', install: 'Build from source', github: 'Source' },
  ko: { docs: '문서', download: '다운로드', install: '소스 빌드', github: '소스' },
  ja: { docs: 'ドキュメント', download: 'ダウンロード', install: 'ソースビルド', github: 'ソース' },
  ru: { docs: 'Документация', download: 'Скачать', install: 'Сборка из исходников', github: 'Исходники' },
  fr: { docs: 'Documentation', download: 'Télécharger', install: 'Compiler', github: 'Sources' },
}

const GESTURE_UI: Record<SiteLocale, GestureUi> = {
  'zh-Hans': {
    trigger: '右键',
    matched: '已匹配',
    capture: '轨迹捕获',
    matchLabel: (pct) => `匹配度 ${pct}%`,
    columns: { stroke: '轨迹', action: '动作', note: '触发键' },
  },
  'zh-Hant': {
    trigger: '右鍵',
    matched: '已比對',
    capture: '軌跡擷取',
    matchLabel: (pct) => `比對度 ${pct}%`,
    columns: { stroke: '軌跡', action: '動作', note: '觸發鍵' },
  },
  en: {
    trigger: 'Right button',
    matched: 'Matched',
    capture: 'Stroke capture',
    matchLabel: (pct) => `${pct}%`,
    columns: { stroke: 'Stroke', action: 'Action', note: 'Trigger' },
  },
  ko: {
    trigger: '오른쪽 버튼',
    matched: '일치함',
    capture: '궤적 캡처',
    matchLabel: (pct) => `일치 ${pct}%`,
    columns: { stroke: '궤적', action: '동작', note: '트리거' },
  },
  ja: {
    trigger: '右ボタン',
    matched: '一致',
    capture: '軌跡キャプチャ',
    matchLabel: (pct) => `一致 ${pct}%`,
    columns: { stroke: '軌跡', action: 'アクション', note: 'トリガー' },
  },
  ru: {
    trigger: 'Правая кнопка',
    matched: 'Совпадение',
    capture: 'Захват траектории',
    matchLabel: (pct) => `${pct}%`,
    columns: { stroke: 'Траектория', action: 'Действие', note: 'Триггер' },
  },
  fr: {
    trigger: 'Bouton droit',
    matched: 'Correspondance',
    capture: 'Capture du trait',
    matchLabel: (pct) => `${pct} %`,
    columns: { stroke: 'Trait', action: 'Action', note: 'Déclencheur' },
  },
}

export const GESTURE_NAMES: Record<string, Record<SiteLocale, string>> = {
  up: {
    'zh-Hans': 'Mission Control',
    'zh-Hant': 'Mission Control',
    en: 'Mission Control',
    ko: 'Mission Control',
    ja: 'Mission Control',
    ru: 'Mission Control',
    fr: 'Mission Control',
  },
  down: {
    'zh-Hans': '应用程序窗口',
    'zh-Hant': '應用程式視窗',
    en: 'Application Windows',
    ko: '응용 프로그램 윈도우',
    ja: 'アプリケーションウインドウ',
    ru: 'Окна программ',
    fr: 'Fenêtres d’application',
  },
  downLeft: {
    'zh-Hans': '最小化窗口',
    'zh-Hant': '最小化視窗',
    en: 'Minimize Window',
    ko: '윈도우 최소화',
    ja: 'ウインドウを最小化',
    ru: 'Свернуть окно',
    fr: 'Réduire la fenêtre',
  },
  downRight: {
    'zh-Hans': '关闭窗口',
    'zh-Hant': '關閉視窗',
    en: 'Close Window',
    ko: '윈도우 닫기',
    ja: 'ウインドウを閉じる',
    ru: 'Закрыть окно',
    fr: 'Fermer la fenêtre',
  },
  upRight: {
    'zh-Hans': '打开 Safari',
    'zh-Hant': '打開 Safari',
    en: 'Open Safari',
    ko: 'Safari 열기',
    ja: 'Safari を開く',
    ru: 'Открыть Safari',
    fr: 'Ouvrir Safari',
  },
  rightLeft: {
    'zh-Hans': '播放 / 暂停',
    'zh-Hant': '播放 / 暫停',
    en: 'Play / Pause',
    ko: '재생 / 일시 정지',
    ja: '再生 / 一時停止',
    ru: 'Воспроизведение / пауза',
    fr: 'Lecture / pause',
  },
  upLeft: {
    'zh-Hans': '打开 GitHub',
    'zh-Hant': '打開 GitHub',
    en: 'Open GitHub',
    ko: 'GitHub 열기',
    ja: 'GitHub を開く',
    ru: 'Открыть GitHub',
    fr: 'Ouvrir GitHub',
  },
}

export function downloadCopy(locale: SiteLocale): DownloadCopy {
  return DOWNLOAD[locale]
}

export function footerCopy(locale: SiteLocale): FooterCopy {
  return FOOTER[locale]
}

export function gestureUi(locale: SiteLocale): GestureUi {
  return GESTURE_UI[locale]
}

export function gestureName(path: string, locale: SiteLocale): string {
  return GESTURE_NAMES[path]?.[locale] ?? path
}

export function toastMatchedText(name: string, score: number, locale: SiteLocale): string {
  const pct = Math.round(score * 100)
  return `${name}  (${GESTURE_UI[locale].matchLabel(pct)})`
}
