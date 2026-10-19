# CryptoN — Video Editor

**CryptoN** — мощный видеоредактор в стиле CapCut с дизайном **Liquid Glass** (серо-голубая палитра, без неона).

## Что уже есть

- Liquid Glass UI
- Создание и управление проектами
- Редактор с таймлайном (видео / аудио / текст дорожки)
- Превью + playhead
- Панель инструментов (Media, Audio, Text, Stickers, Effects, Filters, Transition, Adjust, Speed, Animation, Canvas, Export)
- Система кастомизации (прозрачность стекла, blur, акценты, timeline и т.д.)
- Экспорт (заготовка с прогрессом)
- GitHub Actions → автоматическая сборка APK

## Архитектура под 200+ функций

Смотри файл `FEATURES.md` — полный список запланированных и частично реализованных функций.

## Сборка APK

После пуша в репозиторий:

1. Открой вкладку **Actions**
2. Дождись workflow **Build APK**
3. Скачай артефакт `CryptoN-APK`

## Локально

```bash
flutter pub get
flutter run
flutter build apk --release
```

---

CryptoN Video Editor · Liquid Glass · CapCut-level ambition
