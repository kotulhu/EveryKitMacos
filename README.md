# EveryKit

Нативное офлайн-приложение для строки меню macOS (13.0+). Без Dock-иконки, без регистрации, без телеметрии, без единого сетевого вызова.

## About

AllKit — a universal toolbox for macOS, right in your menu bar.

AllKit is a free, fully offline, native macOS utility that puts a growing set of everyday developer tools one click away — without a single network request, account, or telemetry.

What's inside:

- JSON Formatter — pretty-print, minify, and validate JSON with clear error positions.
- Base64 Encode/Decode — standard and URL-safe variants.
- URL Encode/Decode — percent-encoding for web work.
- Hash Generator — SHA-256, SHA-512, MD5, SHA-1, output in hex.
- UUID Generator — v4 UUIDs, one click to copy.
- Timestamp Converter — Unix seconds/milliseconds ↔ ISO 8601 and local time.
- Password Generator — cryptographically secure, adjustable length and character sets, with an entropy indicator.
- FishText Generator — Russian "lorem ipsum" placeholder text by paragraphs, sentences, or words.
- Cron Parser — human-readable descriptions of cron expressions.

Built for privacy:

- No network calls. No URLSession, no Network framework, no HTTP — ever.
- No telemetry, no analytics, no crash reporting.
- No account, no sign-up, no subscription.
- Everything runs locally, in memory. Your data never leaves your Mac.

Native and lightweight:

- Written in Swift and SwiftUI, using only Apple frameworks (Foundation, AppKit, CryptoKit).
- Lives in the menu bar via MenuBarExtra with LSUIElement = true — no Dock icon, no clutter.
- Targets macOS 13.0+.
- The whole .app weighs under 10 MB.

Free and open:

- Free to use, free to modify. No paywalls, no "pro" tier.
- Source code available for anyone who wants to audit it, fork it, or build their own version.

AllKit — everything you need, nothing you don't.

## Состав

- **JSON Formatter** — pretty-print с сортировкой ключей, minify, позиция ошибки парсинга.
- **Base64** — encode/decode, стандартный и URL-safe режимы.
- **URL Encode/Decode** — percent-encoding/decoding; двойная кавычка `"` не преобразуется и остаётся как есть.
- **Hash Generator** — SHA-256, SHA-512 (CryptoKit), MD5, SHA-1 (Insecure/CryptoKit), hex-вывод.
- **UUID Generator** — UUID v4 + копирование.
- **Timestamp Converter** — Unix (секунды/миллисекунды) ↔ ISO 8601 и локальное время.
- **Password Generator** — длина 8–64, наборы символов, энтропия в битах, `SystemRandomNumberGenerator`.
- **FishText** — русский «рыбный» текст: абзацы / предложения / слова, встроенный словарь.
- **Image Converter** — локальная конвертация PNG / JPEG / TIFF / BMP, предпросмотр, качество JPEG, открытие файла или вставка из буфера обмена.
- **Cron Parser** — расшифровка 5-полевого cron-выражения на русском языке.

Текстовые поля ограничены **1 МиБ** по UTF-8 байтам (счётчик и предупреждение показываются под полем). Для изображений отдельный лимит — **20 МиБ** на файл и **100 Мп** на разрешение.

## Сборка и запуск

1. Откройте `EveryKit.xcodeproj` в Xcode.
2. Выберите схему **EveryKit** и нажмите <kbd>Cmd</kbd>+<kbd>R</kbd>.
3. В строке меню появится монохромная иконка «молоток + шестерёнка» (шаблонное изображение `MenuBarIcon`, автоматически красится под тему). Клик открывает панель инструментов.
4. Выход — кнопка **Quit EveryKit** внизу боковой панели или <kbd>Cmd</kbd>+<kbd>Q</kbd>.

Альтернативная сборка из терминала:

```sh
xcodebuild -project EveryKit.xcodeproj -scheme EveryKit -configuration Release build
```

## Офлайн-гарантии

- Используются только системные фреймворки: SwiftUI, Foundation, AppKit, CryptoKit.
- В исходниках нет сетевых API, аналитики и crash-репортинга.
- Все данные обрабатываются в памяти; настройки инструментов хранятся в `UserDefaults`.
- `LSUIElement = true` скрывает приложение из Dock и Cmd+Tab.
- Одновременно запускается только один экземпляр: файловый лок в `~/Library/Application Support/EveryKit`, повторный запуск активирует существующий экземпляр и завершает новый.

## Структура

```
EveryKit.xcodeproj
project.yml              # источник для xcodegen (опционально)
Info.plist               # LSUIElement = true, macOS 13.0+
EveryKit/
  EveryKitApp.swift       # MenuBarExtra + AppDelegate
  ContentView.swift      # NavigationSplitView по инструментам
  Assets.xcassets/       # монохромная иконка MenuBarIcon
  Tools/                 # по одному файлу на инструмент
  Utils/                 # буфер обмена, лимиты ввода, лок одного экземпляра
```

Размер собранного `.app` — около 850 КБ.

## Разработка

`EveryKit.xcodeproj` уже готов к открытию в Xcode. Если вы меняете состав файлов, пересоберите проект из `project.yml`:

```sh
brew install xcodegen   # если ещё не установлен
xcodegen generate
```

Схема **EveryKit** создаётся автоматически из `project.yml`.

## Лицензия

Проект распространяется по лицензии [MIT](LICENSE).

## Контакты

Разработчик: Speranza

- Email: [speranza.ua@gmail.com](mailto:speranza.ua@gmail.com)
- Website: [https://www.khtulhu.net](https://www.khtulhu.net)

Подробнее — в [CONTACTS.md](CONTACTS.md).
