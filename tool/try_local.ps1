# Runs kahwa on this computer against the Firebase emulators, with demo data.
# Nothing here touches a real Firebase project. From the repository:
#
#     powershell -ExecutionPolicy Bypass -File tool\try_local.ps1
#
# It builds the web app, starts the emulators in a new window, seeds them
# (tool/seed_emulators.mjs) and opens the app. Close the "kahwa emulators"
# window to stop; the data is gone with it.
$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)

# The emulators answer for the project the app is built with.
$match = Select-String -Path lib\firebase_options_dev.dart -Pattern "projectId: '([^']+)'" |
  Select-Object -First 1
if (-not $match) { throw 'No projectId found in lib/firebase_options_dev.dart.' }
$project = $match.Matches[0].Groups[1].Value

if (-not (Get-Command java -ErrorAction SilentlyContinue)) {
  $jbr = 'C:\Program Files\Android\Android Studio\jbr'
  if (-not (Test-Path "$jbr\bin\java.exe")) { throw 'The emulators need Java.' }
  $env:JAVA_HOME = $jbr
  $env:Path = "$jbr\bin;$env:Path"
}

$ports = 5000, 8080, 9099
foreach ($port in $ports) {
  if (Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue) {
    throw "Port $port is in use. Close what runs there (old emulators?) and try again."
  }
}

Write-Host 'Building the web app for the emulators (a few minutes)...'
flutter build web --release --dart-define=USE_EMULATORS=true --output build/web-local
if ($LASTEXITCODE -ne 0) { throw 'The build failed.' }

Write-Host 'Starting the emulators in a new window...'
$command = "`$host.UI.RawUI.WindowTitle = 'kahwa emulators'; " +
  "firebase emulators:start --config firebase.emulators.json --project $project"
Start-Process powershell -ArgumentList '-NoExit', '-Command', $command -WorkingDirectory (Get-Location)

$deadline = (Get-Date).AddMinutes(2)
while ($ports | Where-Object { -not (Get-NetTCPConnection -LocalPort $_ -State Listen -ErrorAction SilentlyContinue) }) {
  if ((Get-Date) -gt $deadline) { throw 'The emulators did not start: see their window.' }
  Start-Sleep -Seconds 2
}

node tool/seed_emulators.mjs $project
if ($LASTEXITCODE -ne 0) { throw 'Seeding failed.' }

Start-Process 'http://localhost:5000'
Write-Host ''
Write-Host 'kahwa runs at http://localhost:5000 (data browser: http://localhost:4000)'
Write-Host '  nour@example.com / kahwa-demo-1   creator page and admin'
Write-Host '  sami@example.com / kahwa-demo-2   supporter with 500,000 L.L. and $5'
Write-Host 'Any other email signs up a new account. Reloading the page signs you out.'
