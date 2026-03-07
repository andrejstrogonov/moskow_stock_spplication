cd C:\Users\strog\StudioProjects\moskow_stock_spplication

# (опционально) посмотреть, есть ли папка build\windows
if (Test-Path .\build\windows) { Write-Output "build\\windows exists" } else { Write-Output "build\\windows not found" }

# Удалить старые артефакты CMake (наиболее целенаправленно)
Remove-Item -Recurse -Force .\build\windows\x64\CMakeFiles, .\build\windows\x64\CMakeCache.txt -ErrorAction SilentlyContinue

# (если вы хотите полностью очистить сборочные файлы) — безопасно:
Remove-Item -Recurse -Force .\build\windows -ErrorAction SilentlyContinue

# Очистить flutter-артефакты
flutter clean

# Загрузить зависимости
flutter pub get

# Попробовать собрать/запустить снова (debug)
flutter run -d windows
