# Skrypt instalacyjny dla wyzwalacza Wi-Fi IP Selector
# Wymaga uprawnień Administratora

$taskName = "WifiIpAddressSelector"
$scriptFileName = "Set-IpConfig.ps1"
$scriptPath = Join-Path $PSScriptRoot $scriptFileName

# 1. Sprawdzenie uprawnień
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "Ten skrypt musi być uruchomiony jako Administrator!"
    exit
}

# 2. Sprawdzenie czy plik skryptu istnieje
if (-not (Test-Path $scriptPath)) {
    Write-Error "Nie znaleziono pliku $scriptFileName w tej samej lokalizacji co instalator."
    exit
}

Write-Host "Rozpoczynanie instalacji zadania: $taskName..." -ForegroundColor Cyan

# 3. Definicja zadania w formacie XML (najbardziej niezawodny sposób na Event Trigger)
# Pobieramy nazwę użytkownika i domenę dla aktualnego kontekstu
$user = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name

$taskXml = @"
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Date>$(Get-Date -Format "yyyy-MM-ddTHH:mm:ss")</Date>
    <Author>$user</Author>
    <Description>Uruchamia okno wyboru IP po połączeniu z Wi-Fi.</Description>
    <URI>\$taskName</URI>
  </RegistrationInfo>
  <Triggers>
    <EventTrigger>
      <Enabled>true</Enabled>
      <Subscription>&lt;QueryList&gt;&lt;Query Id="0" Path="Microsoft-Windows-NetworkProfile/Operational"&gt;&lt;Select Path="Microsoft-Windows-NetworkProfile/Operational"&gt;*[System[(EventID=10000)]]&lt;/Select&gt;&lt;/Query&gt;&lt;/QueryList&gt;</Subscription>
    </EventTrigger>
  </Triggers>
  <Principals>
    <Principal id="Author">
      <UserId>$user</UserId>
      <LogonType>InteractiveToken</LogonType>
      <RunLevel>Highest</RunLevel>
    </Principal>
  </Principals>
  <Settings>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>false</StopIfGoingOnBatteries>
    <AllowHardTerminate>true</AllowHardTerminate>
    <StartWhenAvailable>true</StartWhenAvailable>
    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
    <IdleSettings>
      <StopOnIdleEnd>true</StopOnIdleEnd>
      <RestartOnIdle>false</RestartOnIdle>
    </IdleSettings>
    <AllowStartOnDemand>true</AllowStartOnDemand>
    <Enabled>true</Enabled>
    <Hidden>false</Hidden>
    <RunOnlyIfIdle>false</RunOnlyIfIdle>
    <WakeToRun>false</WakeToRun>
    <ExecutionTimeLimit>PT1H</ExecutionTimeLimit>
    <Priority>7</Priority>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>powershell.exe</Command>
      <Arguments>-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File "$scriptPath"</Arguments>
    </Exec>
  </Actions>
</Task>
"@

# 4. Zapisanie XML do pliku tymczasowego
$tempXmlPath = [System.IO.Path]::GetTempFileName()
$taskXml | Out-File -FilePath $tempXmlPath -Encoding Unicode

# 5. Rejestracja zadania
try {
    # Usuń istniejące zadanie o tej samej nazwie
    schtasks /delete /tn "$taskName" /f 2>$null

    # Importuj nowe zadanie z XML
    Register-ScheduledTask -Xml (Get-Content $tempXmlPath -Raw) -TaskName $taskName -Force

    Write-Host "Sukces! Zadanie '$taskName' zostało zarejestrowane." -ForegroundColor Green
    Write-Host "Skrypt będzie uruchamiany automatycznie po każdym połączeniu z Wi-Fi." -ForegroundColor Gray
} catch {
    Write-Error "Błąd podczas rejestracji zadania: $_"
} finally {
    if (Test-Path $tempXmlPath) { Remove-Item $tempXmlPath }
}
