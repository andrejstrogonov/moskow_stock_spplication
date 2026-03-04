# 📂 Структура файлов проекта

## 📍 Главная папка проекта
```
C:\Users\strog\StudioProjects\moskow_stock_spplication\
```

---

## 📋 Основные документы (читайте в этом порядке)

### 1. **INDEX.md** ⭐ НАЧНИТЕ ОТСЮДА
Полный обзор проекта, быстрый старт, что создано.

### 2. **QUICKSTART.md**
Инструкция по запуску приложения и первые шаги.

### 3. **USAGE_GUIDE.md**
Детальное руководство по использованию всех функций.

### 4. **README.md**
Полная техническая документация проекта.

### 5. **FINAL_REPORT.md**
Итоговый отчёт о разработке и всех компонентах.

### 6. **REQUIREMENTS.md**
Исходные требования от пользователя (рекомендации по стратегиям).

---

## 🚀 Скомпилированное приложение

```
build/windows/x64/runner/Release/moskow_stock_spplication.exe
```

**Размер:** ~200 МБ  
**Готово к запуску:** ДА ✅  
**Требует установки:** НЕТ (всё встроено)

---

## 📁 Исходный код (lib/)

### lib/main.dart (1 файл)
```
lib/main.dart                    - Точка входа приложения
```

### lib/models/ (3 основных файла + 3 .g.dart)
```
lib/models/instrument.dart       - Bond, Stock, Futures классы
lib/models/instrument.g.dart     - Генерированный код (JSON)
lib/models/position.dart         - Позиция в портфеле
lib/models/position.g.dart       - Генерированный код (JSON)
lib/models/portfolio.dart        - Портфель и его методы
lib/models/portfolio.g.dart      - Генерированный код (JSON)
```

### lib/services/ (1 файл)
```
lib/services/portfolio_service.dart  - Управление портфелями и инструментами
```

### lib/screens/ (5 файлов)
```
lib/screens/home_screen.dart                - Главный экран (список портфелей)
lib/screens/create_portfolio_screen.dart    - Создание портфеля
lib/screens/portfolio_detail_screen.dart    - Детали портфеля (3 вкладки)
lib/screens/add_position_screen.dart        - Добавление позиции (выбор инструмента)
lib/screens/instrument_details_screen.dart  - Детали инструмента (расчёты + форма)
```

### lib/utils/ (3 файла)
```
lib/utils/bond_calculator.dart              - Расчёты облигаций (YTM, Duration, Fair Price)
lib/utils/stock_analyzer.dart               - Анализ акций (P/E, ROE, DDM, Risk)
lib/utils/black_scholes_calculator.dart     - Модель Блека-Шоулза (3 сценария)
```

---

## 🔧 Конфигурационные файлы

```
pubspec.yaml                    - Зависимости и конфигурация Flutter
pubspec.lock                    - Заблокированные версии пакетов
analysis_options.yaml           - Правила анализа кода
```

---

## 🎨 Конфигурация Windows

```
windows/CMakeLists.txt          - Сборка для Windows (CMake)
windows/flutter/CMakeLists.txt
windows/flutter/generated_plugins.cmake
windows/runner/main.cpp         - Точка входа на уровне ОС
windows/runner/flutter_window.h/.cpp - Окно приложения
windows/runner/win32_window.h/.cpp   - Работа с Windows API
windows/runner/utils.h/.cpp
windows/runner/Runner.rc        - Ресурсы приложения
windows/runner/runner.exe.manifest
windows/runner/resource.h
windows/runner/resources/app_icon.ico
```

---

## 🧪 Тесты

```
test/widget_test.dart           - Базовый тест приложения
```

---

## 📦 Папки сборки (создаются при компиляции)

```
build/windows/                  - Скомпилированные файлы Windows
build/windows/x64/              - Архитектура x64
build/windows/x64/runner/       - Исполняемые файлы
build/windows/x64/runner/Release/
└── moskow_stock_spplication.exe  ⭐ ГЛАВНЫЙ ФАЙЛ ПРИЛОЖЕНИЯ

.dart_tool/                     - Временные файлы сборки
.packages                       - Ссылки на пакеты
```

---

## 📊 Примеры данных (встроены в код)

Все примеры данных находятся в:
```
lib/services/portfolio_service.dart

Методы инициализации:
- _loadSampleInstruments()     - Загрузка 15 инструментов Мосбиржи
- _loadSamplePortfolios()      - Загрузка 3 примеров портфелей
```

**Примеры включают:**
- 4 облигации (ОФЗ, корпораты)
- 8 акций (основные эмитенты)
- 3 фьючерса (валюта, акция, сырьё)
- 3 портфеля (консервативный, сбалансированный, агрессивный)

---

## 📈 Соотношение строк кода

| Модуль | Строк | Назначение |
|--------|-------|-----------|
| screens/ | ~1200 | Интерфейс пользователя |
| models/ | ~400 | Модели данных |
| utils/ | ~800 | Калькуляторы и анализ |
| services/ | ~600 | Управление данными |
| main.dart | ~50 | Инициализация |
| **Итого** | **~3050** | |

---

## 🔍 Как найти нужный код

| Если нужно... | Смотрите файл |
|--------------|---------------|
| Запустить приложение | lib/main.dart |
| Главный экран | lib/screens/home_screen.dart |
| Управлять портфелями | lib/services/portfolio_service.dart |
| Расчёты YTM облигаций | lib/utils/bond_calculator.dart |
| Анализ акций | lib/utils/stock_analyzer.dart |
| Модель Блека-Шоулза | lib/utils/black_scholes_calculator.dart |
| Модели данных | lib/models/*.dart |
| Примеры данных | lib/services/portfolio_service.dart |
| Все функции приложения | lib/screens/*.dart (5 файлов) |

---

## 💾 Общий размер

| Часть | Размер |
|-------|--------|
| Исходный код (lib/) | ~150 КБ |
| Конфигурация | ~50 КБ |
| .dart_tool/ | ~500 МБ (временный) |
| build/ | ~300 МБ |
| **Скомпилированный exe** | **~200 МБ** |
| **Полный проект** | **~900 МБ** |

*Примечание: .dart_tool/ и большая часть build/ можно удалить - они пересоздаются при сборке*

---

## 🎯 Что находится где

### 🔴 ГЛАВНОЕ ПРИЛОЖЕНИЕ
```
build/windows/x64/runner/Release/moskow_stock_spplication.exe ✅
```

### 🔵 ИСХОДНЫЙ КОД (для разработки)
```
lib/                            ✅
```

### 🟢 ДОКУМЕНТАЦИЯ (читайте!)
```
INDEX.md                        ⭐ Начните отсюда
QUICKSTART.md                   - Быстрый старт
USAGE_GUIDE.md                  - Руководство пользователя
README.md                       - Полная документация
FINAL_REPORT.md                 - Итоговый отчёт
REQUIREMENTS.md                 - Требования
```

### 🟡 КОНФИГУРАЦИЯ
```
pubspec.yaml                    - Зависимости
```

### 🟠 СИСТЕМА СБОРКИ
```
android/                        - Для мобильных версий (не используется)
windows/                        - Для Windows (используется)
test/                           - Тесты
```

---

## 📝 Общий план организации

```
ПРОЕКТ
│
├─ 📄 ДОКУМЕНТАЦИЯ (5 файлов)
│  ├─ INDEX.md                    ⭐ НАЧНИТЕ ОТСЮДА
│  ├─ QUICKSTART.md
│  ├─ USAGE_GUIDE.md
│  ├─ README.md
│  └─ FINAL_REPORT.md
│
├─ 🚀 ПРИЛОЖЕНИЕ (готово к запуску)
│  └─ build/windows/.../moskow_stock_spplication.exe
│
├─ 📝 ИСХОДНЫЙ КОД (13 файлов Dart)
│  ├─ main.dart
│  ├─ models/ (3 файла)
│  ├─ services/ (1 файл)
│  ├─ screens/ (5 файлов)
│  └─ utils/ (3 файла)
│
├─ 🔧 КОНФИГУРАЦИЯ
│  ├─ pubspec.yaml
│  └─ analysis_options.yaml
│
└─ 🛠️ СИСТЕМА СБОРКИ
   ├─ windows/
   └─ test/
```

---

## ✨ Итого

**Всего создано:**
- ✅ 1 готовое к запуску приложение (.exe)
- ✅ 13 файлов исходного кода
- ✅ 6 документов на русском языке
- ✅ 3 встроенных примера портфелей
- ✅ 15 примеров финансовых инструментов
- ✅ 3 калькулятора (облигации, акции, фьючерсы)

**Статус:** Готово к использованию 🚀

---

**Версия:** 1.0.0  
**Дата:** Март 2026  
**Платформа:** Windows x64  

**Для быстрого старта:** читайте INDEX.md → QUICKSTART.md → запустите .exe ✅

