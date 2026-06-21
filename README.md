# Wifi IP Selector - Automatyczny przełącznik adresacji IP

Projekt umożliwia automatyczne wyświetlanie okna wyboru konfiguracji IP (DHCP lub adres statyczny) natychmiast po połączeniu z siecią Wi-Fi w systemie Windows 11 Pro.

## Szybki start
1. Pobierz pliki `Set-IpConfig.ps1` oraz `Install-WifiTrigger.ps1`.
2. Uruchom PowerShell jako Administrator.
3. Wykonaj skrypt instalacyjny (jeśli system blokuje skrypt, użyj Unblock-File):
   ```powershell
   ls | Unblock-File
   powershell -ExecutionPolicy Bypass -File .\Install-WifiTrigger.ps1
   ```

## Dokumentacja
Pełna dokumentacja, opis działania oraz instrukcja rozwiązywania problemów znajduje się w pliku [DOKUMENTACJA.md](DOKUMENTACJA.md).

## Analiza techniczna
Szczegółowe porównanie dostępnych rozwiązań i uzasadnienie wyboru metody opartej na Harmonogramie Zadań znajduje się w pliku [ANALIZA.md](ANALIZA.md).
