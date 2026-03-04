# Clean CMake cache and files for Windows Flutter builds
# Usage: Open PowerShell in project root and run:
#   .\scripts\clean_cmake.ps1

$paths = @(
  "build\windows\x64\CMakeCache.txt",
  "build\windows\x64\CMakeFiles",
  "build\windows\x64\flutter\CMakeFiles",
  "build\windows\x64\runner\CMakeFiles",
  "build\windows\x64"
)

Write-Output "Cleaning CMake artifacts..."
foreach ($p in $paths) {
  if (Test-Path $p) {
    try {
      Remove-Item -Recurse -Force $p -ErrorAction Stop
      Write-Output "Removed: $p"
    } catch {
      Write-Output "Failed to remove $p: $_"
    }
  }
}

Write-Output "Running flutter clean..."
flutter clean

Write-Output "Finished. You can now run: flutter build windows --release or flutter run -d windows";

