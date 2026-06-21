<#
.SYNOPSIS
    Skrypt GUI do szybkiej zmiany konfiguracji IP karty Wi-Fi.
    Dedykowany do uruchamiania przez Harmonogram Zadań po połączeniu z siecią.
#>

# Wymagane zestawy dla GUI
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.VisualBasic")

function Show-Notification {
    param([string]$Message, [string]$Title = "Info")
    [System.Windows.Forms.MessageBox]::Show($Message, $Title, [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
}

function Show-ErrorNotification {
    param([string]$Message)
    [System.Windows.Forms.MessageBox]::Show($Message, "Błąd", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
}

# 1. Znajdź aktywną kartę Wi-Fi
$adapter = Get-NetAdapter | Where-Object { ($_.Status -eq "Up") -and ($_.MediaType -eq "802.11" -or $_.InterfaceDescription -like "*Wi-Fi*") } | Select-Object -First 1

if (-not $adapter) {
    # Próba znalezienia jakiejkolwiek karty Wi-Fi jeśli "Up" nie zadziałało (może być w trakcie łączenia)
    $adapter = Get-NetAdapter | Where-Object { $_.MediaType -eq "802.11" -or $_.InterfaceDescription -like "*Wi-Fi*" } | Select-Object -First 1
}

if (-not $adapter) {
    Show-ErrorNotification "Nie znaleziono karty sieciowej Wi-Fi."
    exit
}

$interfaceAlias = $adapter.Name

# 2. Definicja okna GUI
$form = New-Object System.Windows.Forms.Form
$form.Text = "Konfiguracja IP Wi-Fi: $interfaceAlias"
$form.Size = New-Object System.Drawing.Size(420, 320)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.TopMost = $true
$form.MaximizeBox = $false
$form.MinimizeBox = $false

$fontHeader = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$fontButton = New-Object System.Drawing.Font("Segoe UI", 9)

$label = New-Object System.Windows.Forms.Label
$label.Text = "Wykryto połączenie Wi-Fi. Wybierz profil:"
$label.Location = New-Object System.Drawing.Point(20, 20)
$label.AutoSize = $true
$label.Font = $fontHeader
$form.Controls.Add($label)

# Funkcja pomocnicza do tworzenia przycisków
function Add-MenuButton {
    param($Text, $Y, $OnClick)
    $btn = New-Object System.Windows.Forms.Button
    $btn.Text = $Text
    $btn.Location = New-Object System.Drawing.Point(40, $Y)
    $btn.Size = New-Object System.Drawing.Size(320, 35)
    $btn.Font = $fontButton
    $btn.Add_Click($OnClick)
    $form.Controls.Add($btn)
}

# OPCJA 1: DHCP
Add-MenuButton "1. DHCP (Automatyczny)" 60 {
    try {
        Set-NetIPInterface -InterfaceAlias $interfaceAlias -DHCP Enabled -ErrorAction Stop
        Set-DnsClientServerAddress -InterfaceAlias $interfaceAlias -ResetServerAddresses -ErrorAction Stop
        Show-Notification "Ustawiono DHCP dla $interfaceAlias"
        $form.Close()
    } catch {
        Show-ErrorNotification "Błąd przy ustawianiu DHCP: $_"
    }
}

# OPCJA 2: 27WE
Add-MenuButton "2. 27WE - IP 10.52.99.101" 105 {
    try {
        Set-NetIPInterface -InterfaceAlias $interfaceAlias -DHCP Disabled -ErrorAction Stop
        Remove-NetIPAddress -InterfaceAlias $interfaceAlias -Confirm:$false -ErrorAction SilentlyContinue
        New-NetIPAddress -InterfaceAlias $interfaceAlias -IPAddress "10.52.99.101" -PrefixLength 24 -DefaultGateway "10.52.99.1" -ErrorAction Stop
        Set-DnsClientServerAddress -InterfaceAlias $interfaceAlias -ServerAddresses ("8.8.8.8", "8.8.4.4") -ErrorAction Stop
        Show-Notification "Ustawiono profil 27WE (10.52.99.101)"
        $form.Close()
    } catch {
        Show-ErrorNotification "Błąd przy ustawianiu profilu 27WE: $_"
    }
}

# OPCJA 3: AKM
Add-MenuButton "3. AKM - IP 10.5.99.101" 150 {
    try {
        Set-NetIPInterface -InterfaceAlias $interfaceAlias -DHCP Disabled -ErrorAction Stop
        Remove-NetIPAddress -InterfaceAlias $interfaceAlias -Confirm:$false -ErrorAction SilentlyContinue
        New-NetIPAddress -InterfaceAlias $interfaceAlias -IPAddress "10.5.99.101" -PrefixLength 24 -DefaultGateway "10.5.99.1" -ErrorAction Stop
        Set-DnsClientServerAddress -InterfaceAlias $interfaceAlias -ServerAddresses ("8.8.8.8", "8.8.4.4") -ErrorAction Stop
        Show-Notification "Ustawiono profil AKM (10.5.99.101)"
        $form.Close()
    } catch {
        Show-ErrorNotification "Błąd przy ustawianiu profilu AKM: $_"
    }
}

# OPCJA 4: Custom
Add-MenuButton "4. Custom - Podaj adres IP" 195 {
    $customIP = [Microsoft.VisualBasic.Interaction]::InputBox("Podaj adres IP (np. 192.168.1.50):", "Custom IP", "")
    if ($customIP -match '^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$') {
        try {
            Set-NetIPInterface -InterfaceAlias $interfaceAlias -DHCP Disabled -ErrorAction Stop
            Remove-NetIPAddress -InterfaceAlias $interfaceAlias -Confirm:$false -ErrorAction SilentlyContinue
            New-NetIPAddress -InterfaceAlias $interfaceAlias -IPAddress $customIP -PrefixLength 24 -ErrorAction Stop
            Show-Notification "Ustawiono niestandardowy adres IP: $customIP`nPamiętaj o ręcznym ustawieniu bramy i DNS jeśli są wymagane."
            $form.Close()
        } catch {
            Show-ErrorNotification "Błąd przy ustawianiu Custom IP: $_"
        }
    } elseif ($customIP) {
        Show-ErrorNotification "Nieprawidłowy format adresu IP."
    }
}

# Przycisk Anuluj
$btnCancel = New-Object System.Windows.Forms.Button
$btnCancel.Text = "Anuluj"
$btnCancel.Location = New-Object System.Drawing.Point(150, 245)
$btnCancel.Size = New-Object System.Drawing.Size(100, 25)
$btnCancel.Add_Click({ $form.Close() })
$form.Controls.Add($btnCancel)

# Wyświetl okno
$form.ShowDialog() | Out-Null
