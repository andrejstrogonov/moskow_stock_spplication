# Run static analysis and all tests and save outputs to files
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $root\..\

Write-Output "Running flutter analyze..."
flutter analyze > analysis.log 2>&1
Write-Output "Analyze finished. Output saved to analysis.log"

Write-Output "Running flutter test..."
flutter test -r expanded > tests.log 2>&1
Write-Output "Tests finished. Output saved to tests.log"

Write-Output "Files:"
Get-ChildItem analysis.log, tests.log | Format-List Name,Length

Write-Output "Done. Please attach analysis.log and tests.log if there are failures."

