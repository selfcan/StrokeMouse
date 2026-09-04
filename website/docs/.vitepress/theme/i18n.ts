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

export interface ThemeModeCopy {
  light: string
  dark: string
  auto: string
}

export const THEME_MODE_COPY: Record<SiteLocale, ThemeModeCopy> = {
  'zh-Hans': { light: '浅色模式', dark: '深色模式', auto: '跟随系统' },
  'zh-Hant': { light: '淺色模式', dark: '深色模式', auto: '跟隨系統' },
  en: { light: 'Light', dark: 'Dark', auto: 'System' },
  ko: { light: '라이트 모드', dark: '다크 모드', auto: '시스템 설정' },
  ja: { light: 'ライトモード', dark: 'ダークモード', auto: 'システム設定' },
  ru: { light: 'Светлая тема', dark: 'Тёмная тема', auto: 'Системная' },
  fr: { light: 'Mode clair', dark: 'Mode sombre', auto: 'Système' },
}

export interface ShowcaseCopy {
  stripPresets: string
  stripGestures: string
  stripLatency: string
  stripChips: string
  fighdTitle: string
  fighdHint: string
  scopes: string
  gestures: string
  tabCanvas: string
  tabLog: string
  tabRule: string
  targetAction: string
  scope: string
  trigger: string
  points: string
  engineRunning: string
  matchScore: string
  latency: string
  captured: string
  drawHint: string
  figCaption: string
}

export const SHOWCASE_COPY: Record<SiteLocale, ShowcaseCopy> = {
  'zh-Hans': {
    stripPresets: '开箱预设动作',
    stripGestures: '类原生手势支持',
    stripLatency: '原生识别延迟',
    stripChips: 'Apple Silicon 与 Intel',
    fighdTitle: '手势识别引擎 · 实时轨迹检验',
    fighdHint: '点击左侧手势观察轨迹匹配与派发',
    scopes: '作用域',
    gestures: '手势规则',
    tabCanvas: '实时画布',
    tabLog: '引擎事件流',
    tabRule: 'JSON 规则',
    targetAction: '映射动作',
    scope: '范围',
    trigger: '触发',
    points: '采样点',
    engineRunning: '引擎活跃 (120Hz 挂钩)',
    matchScore: '匹配置信度',
    latency: '识别延迟',
    captured: '✓ 轨迹捕获成功',
    drawHint: '点击左侧手势规则播放轨迹重放动画',
    figCaption:
      '真实运行状态：原生 Swift 编写，无后台遥测，亚毫秒级低延迟响应。点击左侧规则，实时查看匹配与事件派发。',
  },
  'zh-Hant': {
    stripPresets: '開箱預設動作',
    stripGestures: '類原生手勢支援',
    stripLatency: '原生辨識延遲',
    stripChips: 'Apple Silicon 與 Intel',
    fighdTitle: '手勢辨識引擎 · 即時軌跡檢驗',
    fighdHint: '點擊左側手勢觀察軌跡比對與發送',
    scopes: '範圍',
    gestures: '手勢規則',
    tabCanvas: '即時畫布',
    tabLog: '引擎事件流',
    tabRule: 'JSON 規則',
    targetAction: '對應動作',
    scope: '範圍',
    trigger: '觸發',
    points: '取樣點',
    engineRunning: '引擎活躍 (120Hz 掛鉤)',
    matchScore: '比對信賴度',
    latency: '辨識延遲',
    captured: '✓ 軌跡擷取成功',
    drawHint: '點擊左側手勢規則播放軌跡重放動畫',
    figCaption:
      '真實執行狀態：原生 Swift 編寫，無背景遙測，次毫秒級低延遲回應。點擊左側規則，即時查看比對與事件發送。',
  },
  en: {
    stripPresets: 'Built-in Presets',
    stripGestures: 'Gestures Supported',
    stripLatency: 'Recognition Latency',
    stripChips: 'Apple Silicon & Intel',
    fighdTitle: 'the stroke engine · real-time recognition',
    fighdHint: 'click a preset to inspect recognition and actions',
    scopes: 'Scopes',
    gestures: 'Gestures',
    tabCanvas: 'Live Canvas',
    tabLog: 'Engine Log',
    tabRule: 'JSON Rule',
    targetAction: 'Target Action',
    scope: 'Scope',
    trigger: 'Trigger',
    points: 'Points',
    engineRunning: 'Engine Active (120Hz Hook)',
    matchScore: 'Match Confidence',
    latency: 'Latency',
    captured: '✓ Stroke Captured',
    drawHint: 'Click any gesture preset on the left to replay',
    figCaption:
      'A real session: native Swift input hook, zero telemetry, sub-millisecond recognition. Click an action in the sidebar to inspect real-time stroke recognition.',
  },
  ko: {
    stripPresets: '기본 제공 동작',
    stripGestures: '지원되는 제스처',
    stripLatency: '인식 지연 시간',
    stripChips: 'Apple Silicon 및 Intel',
    fighdTitle: '제스처 인식 엔진 · 실시간 궤적 테스트',
    fighdHint: '사이드바 프리셋을 클릭하여 궤적을 확인하세요',
    scopes: '범위',
    gestures: '제스처',
    tabCanvas: '실시간 캔버스',
    tabLog: '엔진 로그',
    tabRule: 'JSON 규칙',
    targetAction: '매핑 동작',
    scope: '범위',
    trigger: '트리거',
    points: '샘플링 포인트',
    engineRunning: '엔진 활성화 (120Hz)',
    matchScore: '일치 신뢰도',
    latency: '지연 시간',
    captured: '✓ 궤적 캡처 완료',
    drawHint: '왼쪽 제스처를 클릭하여 궤적 애니메이션을 재생하세요',
    figCaption:
      '실제 세션: 기본 Swift 입력 후크, 제로 원격 측정, 서브밀리초 응답. 사이드바 항목을 클릭하여 실시간 인식과 키 발송을 확인하세요.',
  },
  ja: {
    stripPresets: 'プリセット操作',
    stripGestures: 'ジェスチャ対応数',
    stripLatency: 'ネイティブ認識遅延',
    stripChips: 'Apple Silicon および Intel',
    fighdTitle: 'ジェスチャ認識エンジン · リアルタイム軌跡テスト',
    fighdHint: 'サイドバーのプリセットをクリックして軌跡を確認',
    scopes: 'スコープ',
    gestures: 'ジェスチャ',
    tabCanvas: 'リアルタイム描画',
    tabLog: 'エンジンログ',
    tabRule: 'JSON ルール',
    targetAction: '対象アクション',
    scope: 'スコープ',
    trigger: 'トリガー',
    points: 'サンプリング数',
    engineRunning: 'エンジン稼働中 (120Hz)',
    matchScore: '認識信頼度',
    latency: '遅延',
    captured: '✓ 軌跡をキャプチャ',
    drawHint: '左側のジェスチャをクリックしてアニメーションを再生',
    figCaption:
      '実際の実行セッション：ネイティブ Swift による入力フック、テレメトリなし、ミリ秒未満の応答。リアルタイム認識とキー送信を確認できます。',
  },
  ru: {
    stripPresets: 'Готовые действия',
    stripGestures: 'Поддерживаемые жесты',
    stripLatency: 'Задержка распознавания',
    stripChips: 'Apple Silicon и Intel',
    fighdTitle: 'Движок жестов · распознавание в реальном времени',
    fighdHint: 'Выберите жест слева для анимации траектории',
    scopes: 'Области',
    gestures: 'Жесты',
    tabCanvas: 'Холст',
    tabLog: 'Журнал событий',
    tabRule: 'Правило JSON',
    targetAction: 'Действие',
    scope: 'Область',
    trigger: 'Триггер',
    points: 'Точки',
    engineRunning: 'Движок активен (120 Гц)',
    matchScore: 'Точность совпадения',
    latency: 'Задержка',
    captured: '✓ Траектория захвачена',
    drawHint: 'Нажмите на жест слева для воспроизведения',
    figCaption:
      'Нативная сессия: перехват событий на Swift, отсутствие телеметрии, задержка менее миллисекунды. Нажмите на жест для проверки распознавания.',
  },
  fr: {
    stripPresets: 'Actions prédéfinies',
    stripGestures: 'Gestes pris en charge',
    stripLatency: 'Latence de détection',
    stripChips: 'Apple Silicon et Intel',
    fighdTitle: 'Moteur de gestes · détection en temps réel',
    fighdHint: 'Cliquez sur un geste pour voir l’animation',
    scopes: 'Portées',
    gestures: 'Gestes',
    tabCanvas: 'Canevas interactif',
    tabLog: 'Journal système',
    tabRule: 'Règle JSON',
    targetAction: 'Action assignée',
    scope: 'Portée',
    trigger: 'Déclencheur',
    points: 'Points',
    engineRunning: 'Moteur actif (120 Hz)',
    matchScore: 'Confiance',
    latency: 'Latence',
    captured: '✓ Trait capturé',
    drawHint: 'Cliquez sur un geste à gauche pour rejouer le tracé',
    figCaption:
      'Session réelle : interception native en Swift, zéro télémétrie, réponse inférieure à la milliseconde. Testez la reconnaissance en direct.',
  },
}

export interface GeneralUiCopy {
  allDownloads: string
  viewDocs: string
  installGuide: string
  workflow: string
  capabilities: string
  presets: string
  surface: string
  getStarted: string
  copy: string
  copied: string
  install: string
}

export const GENERAL_UI_COPY: Record<SiteLocale, GeneralUiCopy> = {
  'zh-Hans': {
    allDownloads: '全部下载与构建方式 →',
    viewDocs: '阅读文档',
    installGuide: '安装指引',
    workflow: '快速上手',
    capabilities: '核心能力',
    presets: '开箱手势',
    surface: '应用界面',
    getStarted: '开始使用',
    copy: '复制',
    copied: '已复制',
    install: '下载安装',
  },
  'zh-Hant': {
    allDownloads: '全部下載與建置方式 →',
    viewDocs: '閱讀文件',
    installGuide: '安裝指引',
    workflow: '快速上手',
    capabilities: '核心能力',
    presets: '開箱手勢',
    surface: '應用介面',
    getStarted: '開始使用',
    copy: '複製',
    copied: '已複製',
    install: '下載安裝',
  },
  en: {
    allDownloads: 'all install & download methods →',
    viewDocs: 'Documentation',
    installGuide: 'Installation',
    workflow: 'Workflow',
    capabilities: 'Capabilities',
    presets: 'Built-in Strokes',
    surface: 'Interface',
    getStarted: 'Get Started',
    copy: 'copy',
    copied: 'copied',
    install: 'Install',
  },
  ko: {
    allDownloads: '모든 다운로드 및 빌드 방법 →',
    viewDocs: '문서 보기',
    installGuide: '설치 가이드',
    workflow: '워크플로',
    capabilities: '주요 기능',
    presets: '기본 제스처',
    surface: '인터페이스',
    getStarted: '시작하기',
    copy: '복사',
    copied: '복사됨',
    install: '설치하기',
  },
  ja: {
    allDownloads: 'すべてのダウンロードとビルド方法 →',
    viewDocs: 'ドキュメントを見る',
    installGuide: 'インストールガイド',
    workflow: 'クイックスタート',
    capabilities: '主な機能',
    presets: '標準ジェスチャ',
    surface: 'インターフェース',
    getStarted: '今すぐ始める',
    copy: 'コピー',
    copied: '完了',
    install: 'インストール',
  },
  ru: {
    allDownloads: 'все способы установки и сборки →',
    viewDocs: 'Документация',
    installGuide: 'Инструкция по установке',
    workflow: 'Рабочий процесс',
    capabilities: 'Возможности',
    presets: 'Встроенные жесты',
    surface: 'Интерфейс',
    getStarted: 'Начать работу',
    copy: 'копировать',
    copied: 'скопировано',
    install: 'Установить',
  },
  fr: {
    allDownloads: 'toutes les méthodes d’installation →',
    viewDocs: 'Documentation',
    installGuide: 'Guide d’installation',
    workflow: 'Prise en main',
    capabilities: 'Fonctionnalités',
    presets: 'Gestes intégrés',
    surface: 'Interface',
    getStarted: 'Commencer',
    copy: 'copier',
    copied: 'copié',
    install: 'Installer',
  },
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
    manual: '手动下载 DMG 安装包',
    armTitle: 'Apple Silicon 芯片',
    armDesc: '适用于搭载 M1 / M2 / M3 / M4 芯片的 Mac',
    intelTitle: 'Intel 处理器',
    intelDesc: '适用于 Intel 架构的 Mac 设备',
    get: '下载 DMG',
    reqLabel: '系统要求',
    reqValue: 'macOS 14 Sonoma 或更高版本',
    installTitle: 'DMG 安装步骤',
    steps: [
      '下载对应芯片架构的 .dmg 安装镜像',
      '双击打开 .dmg，将 StrokeMouse 拖拽至「应用程序」文件夹',
      '首次启动时请在「系统设置 → 隐私与安全性 → 辅助功能」中授予权限',
      '按住鼠标右键或修饰键绘制手势，即刻开启高效操作',
    ],
    releases: '全部 GitHub 发行版',
    source: '从源码构建与贡献',
    note: '当前安装包为开源自签名版本；首次运行若遇 macOS 安全拦截，请在系统设置中点击「仍要打开」。',
  },
  'zh-Hant': {
    title: '下載 StrokeMouse',
    lead: 'macOS 正式建置。請依晶片架構選擇對應安裝包。',
    homebrewTitle: 'Homebrew（建議）',
    homebrewDesc:
      '安裝、升級與解除安裝依序使用以下命令；安裝命令會自動加入 StrokeMouse 專案維護的 Tap。',
    homebrewNote: 'StrokeMouse 同時支援應用內更新，因此 Homebrew 升級命令使用 --greedy。',
    manual: '手動下載 DMG 安裝檔',
    armTitle: 'Apple Silicon 晶片',
    armDesc: '適用於搭載 M1 / M2 / M3 / M4 晶片的 Mac',
    intelTitle: 'Intel 處理器',
    intelDesc: '適用於 Intel 架構的 Mac 設備',
    get: '下載 DMG',
    reqLabel: '系統需求',
    reqValue: 'macOS 14 Sonoma 或更高版本',
    installTitle: 'DMG 安裝步驟',
    steps: [
      '下載對應晶片架構的 .dmg 安裝檔',
      '連按兩下打開 .dmg，將 StrokeMouse 拖曳至「應用程式」檔案夾',
      '首次啟動請在「系統設定 → 隱私權與安全性 → 輔助使用」中授權',
      '按住滑鼠右鍵或修飾鍵繪製手勢，即刻開啟高效操作',
    ],
    releases: '全部 GitHub 發行版本',
    source: '從原始碼建置與貢獻',
    note: '目前安裝檔為開源自簽版本；首次執行若遇 macOS 安全攔截，請在系統設定中點擊「仍要開啟」。',
  },
  en: {
    title: 'Download StrokeMouse',
    lead: 'Production builds for macOS. Pick the package that matches your chip architecture.',
    homebrewTitle: 'Homebrew Cask (Recommended)',
    homebrewDesc:
      'Install, upgrade, or uninstall cleanly via the terminal. The cask automatically taps the official repo.',
    homebrewNote: 'StrokeMouse supports in-app updates, so Homebrew upgrades use --greedy.',
    manual: 'Direct DMG Downloads',
    armTitle: 'Apple Silicon',
    armDesc: 'For Mac computers with M1, M2, M3, M4 chips',
    intelTitle: 'Intel Mac',
    intelDesc: 'For Mac computers with Intel x86_64 processors',
    get: 'Download DMG',
    reqLabel: 'Requirements',
    reqValue: 'macOS 14 Sonoma or later',
    installTitle: 'DMG Installation Guide',
    steps: [
      'Download the DMG package matching your chip architecture',
      'Open the DMG and drag StrokeMouse into your Applications folder',
      'Launch StrokeMouse and grant Accessibility permissions in System Settings',
      'Draw with right click or modifier keys to trigger gestures instantly',
    ],
    releases: 'All GitHub Releases',
    source: 'Build from Source',
    note: 'Builds are open-source and signed. If macOS Gatekeeper asks for confirmation on first launch, choose Open Anyway in System Settings.',
  },
  ko: {
    title: 'StrokeMouse 다운로드',
    lead: 'macOS 프로덕션 빌드입니다. 칩 아키텍처에 맞는 패키지를 선택하세요.',
    homebrewTitle: 'Homebrew(권장)',
    homebrewDesc:
      '설치, 업그레이드, 제거는 터미널 명령을 사용합니다. 공식 Tap이 자동으로 추가됩니다.',
    homebrewNote: 'StrokeMouse는 앱 내 업데이트도 지원하므로 --greedy 옵션을 사용합니다.',
    manual: 'DMG 직접 다운로드',
    armTitle: 'Apple Silicon',
    armDesc: 'M1 / M2 / M3 / M4 칩이 탑재된 Mac',
    intelTitle: 'Intel Mac',
    intelDesc: 'Intel x86_64 프로세서 탑재 Mac',
    get: 'DMG 다운로드',
    reqLabel: '시스템 요구 사항',
    reqValue: 'macOS 14 Sonoma 이상',
    installTitle: 'DMG 설치 안내',
    steps: [
      '아키텍처에 맞는 .dmg 설치 파일을 다운로드합니다',
      '.dmg 파일을 열고 StrokeMouse를 응용 프로그램 폴더로 드래그합니다',
      '앱 실행 후 시스템 설정 → 개인정보 보호 및 보안 → 손쉬운 사용에서 권한을 허용합니다',
      '마우스 오른쪽 버튼 또는 보조 키로 제스처를 바로 시작하세요',
    ],
    releases: '모든 GitHub 릴리스',
    source: '소스에서 빌드',
    note: '오픈 소스 자체 서명 빌드입니다. 첫 실행 시 차단 메시지가 나타나면 시스템 설정에서 계속 열기를 선택하세요.',
  },
  ja: {
    title: 'StrokeMouse をダウンロード',
    lead: 'macOS 向けの正式ビルドです。プロセッサに合ったパッケージを選んでください。',
    homebrewTitle: 'Homebrew（推奨）',
    homebrewDesc:
      'ターミナルからインストール、更新、アンインストールできます。公式 Tap が自動で登録されます。',
    homebrewNote: 'アプリ内アップデートにも対応しているため、更新時は --greedy を使用します。',
    manual: 'DMG を直接ダウンロード',
    armTitle: 'Apple Silicon',
    armDesc: 'M1 / M2 / M3 / M4 搭載の Mac 向け',
    intelTitle: 'Intel プロセッサ',
    intelDesc: 'Intel x86_64 搭載の Mac 向け',
    get: 'DMG をダウンロード',
    reqLabel: 'システム要件',
    reqValue: 'macOS 14 Sonoma 以降',
    installTitle: 'DMG のインストール手順',
    steps: [
      'アーキテクチャに合った .dmg ファイルをダウンロードします',
      '.dmg を開き、StrokeMouse をアプリケーションフォルダにドラッグします',
      '初回起動後、システム設定 → プライバシーとセキュリティ → アクセシビリティで許可します',
      '右クリックまたは修飾キーを押しながらジェスチャを描いて操作を開始できます',
    ],
    releases: 'すべての GitHub リリース',
    source: 'ソースコードからビルド',
    note: 'オープンソースの安定署名ビルドです。初回起動でブロックされた場合はシステム設定から許可してください。',
  },
  ru: {
    title: 'Скачать StrokeMouse',
    lead: 'Релизные сборки для macOS. Выберите версию под свой процессор.',
    homebrewTitle: 'Homebrew Cask (рекомендуется)',
    homebrewDesc:
      'Установка, обновление и удаление через терминал с автоматическим подключением репозитория.',
    homebrewNote: 'StrokeMouse поддерживает автообновления, поэтому используется флаг --greedy.',
    manual: 'Прямая загрузка DMG',
    armTitle: 'Apple Silicon',
    armDesc: 'Для компьютеров Mac на чипах M1 / M2 / M3 / M4',
    intelTitle: 'Процессор Intel',
    intelDesc: 'Для компьютеров Mac на базе Intel x86_64',
    get: 'Скачать DMG',
    reqLabel: 'Системные требования',
    reqValue: 'macOS 14 Sonoma или новее',
    installTitle: 'Инструкция по установке',
    steps: [
      'Загрузите установочный файл .dmg для своей архитектуры',
      'Откройте образ и перетащите StrokeMouse в папку «Программы»',
      'Разрешите доступ в «Системные настройки → Конфиденциальность и безопасность → Универсальный доступ»',
      'Начните рисовать жесты правой кнопкой мыши или клавишами-модификаторами',
    ],
    releases: 'Все релизы на GitHub',
    source: 'Собрать из исходного кода',
    note: 'Приложение подписано разработчиком. Если Gatekeeper заблокирует первый запуск, разрешите его в Системных настройках.',
  },
  fr: {
    title: 'Télécharger StrokeMouse',
    lead: 'Versions de production pour macOS. Choisissez le fichier adapté à votre processeur.',
    homebrewTitle: 'Homebrew Cask (recommandé)',
    homebrewDesc:
      'Installez, mettez à jour ou désinstallez en une commande via le tap officiel StrokeMouse.',
    homebrewNote: 'L’app gère les mises à jour intégrées, d’où l’usage du paramètre --greedy.',
    manual: 'Téléchargement direct DMG',
    armTitle: 'Apple Silicon',
    armDesc: 'Pour les Mac équipés de puces M1 / M2 / M3 / M4',
    intelTitle: 'Processeur Intel',
    intelDesc: 'Pour les Mac avec processeurs Intel x86_64',
    get: 'Télécharger le DMG',
    reqLabel: 'Configuration requise',
    reqValue: 'macOS 14 Sonoma ou ultérieur',
    installTitle: 'Étapes d’installation',
    steps: [
      'Téléchargez le fichier .dmg adapté à votre architecture',
      'Ouvrez le fichier et glissez StrokeMouse dans le dossier Applications',
      'Accordez l’Accessibilité dans Réglages Système → Confidentialité et sécurité',
      'Maintenez le clic droit ou une touche modificatrice pour exécuter vos premiers gestes',
    ],
    releases: 'Toutes les versions GitHub',
    source: 'Compiler depuis les sources',
    note: 'Version open-source signée. Si Gatekeeper affiche un avertissement au premier lancement, autorisez l’application dans Réglages Système.',
  },
}

const FOOTER: Record<SiteLocale, FooterCopy> = {
  'zh-Hans': { docs: '使用文档', download: '下载安装', install: '源码构建', github: 'GitHub 仓库' },
  'zh-Hant': { docs: '使用文件', download: '下載安裝', install: '原始碼建置', github: 'GitHub 存放庫' },
  en: { docs: 'Documentation', download: 'Download', install: 'Source Build', github: 'GitHub' },
  ko: { docs: '문서', download: '다운로드', install: '소스 빌드', github: 'GitHub' },
  ja: { docs: 'ドキュメント', download: 'ダウンロード', install: 'ソースビルド', github: 'GitHub' },
  ru: { docs: 'Документация', download: 'Скачать', install: 'Сборка', github: 'GitHub' },
  fr: { docs: 'Documentation', download: 'Télécharger', install: 'Compilation', github: 'GitHub' },
}

const GESTURE_UI: Record<SiteLocale, GestureUi> = {
  'zh-Hans': {
    trigger: '鼠标右键',
    matched: '已匹配',
    capture: '轨迹捕获',
    matchLabel: (pct) => `匹配度 ${pct}%`,
    columns: { stroke: '手势轨迹', action: '映射动作', note: '触发按键' },
  },
  'zh-Hant': {
    trigger: '滑鼠右鍵',
    matched: '已比對',
    capture: '軌跡擷取',
    matchLabel: (pct) => `比對度 ${pct}%`,
    columns: { stroke: '手勢軌跡', action: '對應動作', note: '觸發按鍵' },
  },
  en: {
    trigger: 'Right Click',
    matched: 'Matched',
    capture: 'Stroke Capture',
    matchLabel: (pct) => `${pct}% match`,
    columns: { stroke: 'Stroke', action: 'Action', note: 'Trigger' },
  },
  ko: {
    trigger: '우클릭',
    matched: '일치함',
    capture: '궤적 캡처',
    matchLabel: (pct) => `일치 ${pct}%`,
    columns: { stroke: '제스처 궤적', action: '동작', note: '트리거' },
  },
  ja: {
    trigger: '右クリック',
    matched: '一致',
    capture: '軌跡キャプチャ',
    matchLabel: (pct) => `一致 ${pct}%`,
    columns: { stroke: 'ジェスチャ軌跡', action: 'アクション', note: 'トリガー' },
  },
  ru: {
    trigger: 'Правая кнопка',
    matched: 'Совпадение',
    capture: 'Захват траектории',
    matchLabel: (pct) => `${pct}%`,
    columns: { stroke: 'Траектория', action: 'Действие', note: 'Триггер' },
  },
  fr: {
    trigger: 'Clic droit',
    matched: 'Correspondance',
    capture: 'Capture du trait',
    matchLabel: (pct) => `${pct} %`,
    columns: { stroke: 'Tracé du geste', action: 'Action', note: 'Déclencheur' },
  },
}

export const GESTURE_NAMES: Record<string, Record<SiteLocale, string>> = {
  back: {
    'zh-Hans': '后退',
    'zh-Hant': '返回',
    en: 'History Back',
    ko: '뒤로 이동',
    ja: '戻る',
    ru: 'Назад',
    fr: 'Page précédente',
  },
  forward: {
    'zh-Hans': '前进',
    'zh-Hant': '前進',
    en: 'History Forward',
    ko: '앞으로 이동',
    ja: '進む',
    ru: 'Вперёд',
    fr: 'Page suivante',
  },
  close: {
    'zh-Hans': '关闭标签页',
    'zh-Hant': '關閉標籤頁',
    en: 'Close Tab',
    ko: '탭 닫기',
    ja: 'タブを閉じる',
    ru: 'Закрыть вкладку',
    fr: 'Fermer l’onglet',
  },
  reload: {
    'zh-Hans': '重新加载',
    'zh-Hant': '重新載入',
    en: 'Reload Page',
    ko: '새로고침',
    ja: 'ページを再読み込み',
    ru: 'Обновить страницу',
    fr: 'Recharger la page',
  },
  up: {
    'zh-Hans': '调度中心 (Mission Control)',
    'zh-Hant': '指揮中心 (Mission Control)',
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

export function themeModeCopy(locale: SiteLocale): ThemeModeCopy {
  return THEME_MODE_COPY[locale]
}

export function showcaseCopy(locale: SiteLocale): ShowcaseCopy {
  return SHOWCASE_COPY[locale]
}

export function generalUiCopy(locale: SiteLocale): GeneralUiCopy {
  return GENERAL_UI_COPY[locale]
}
