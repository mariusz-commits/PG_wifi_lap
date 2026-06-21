# Dokumentacja: Wifi IP Selector

## Opis projektu
Narzędzie służy do automatycznego wyświetlania okna wyboru profilu adresacji IP (DHCP lub adresy statyczne) natychmiast po połączeniu laptopa z dowolną siecią Wi-Fi na systemie Windows 11 Pro.

## Wymagania
*   **System operacyjny:** Windows 10 lub Windows 11 (zalecany Pro).
*   **Uprawnienia:** Administrator (wymagane do instalacji i zmiany ustawień sieciowych).
*   **Środowisko:** PowerShell 5.1 lub nowszy (standard w Windows).

## Zawartość pakietu
1.  `Set-IpConfig.ps1` – Główny skrypt realizujący interfejs graficzny i logikę zmiany IP.
2.  `Install-WifiTrigger.ps1` – Skrypt instalacyjny konfigurujący Harmonogram Zadań.
3.  `ANALIZA.md` – Dokumentacja techniczna z analizą wybranych rozwiązań.

## Instrukcja instalacji
1.  Skopiuj pliki `Set-IpConfig.ps1` oraz `Install-WifiTrigger.ps1` do wybranego folderu na dysku (np. `C:\Scripts\WifiSelector`).
    *   *Uwaga: Nie usuwaj plików po instalacji, ponieważ Harmonogram Zadań będzie się odwoływał do tej lokalizacji.*
2.  Kliknij Start, wpisz **PowerShell**, kliknij prawym przyciskiem myszy i wybierz **Uruchom jako Administrator**.
3.  Przejdź do folderu ze skryptami, np.:
    ```powershell
    cd C:\Scripts\WifiSelector
    ```
4.  Uruchom instalator:
    ```powershell
    .\Install-WifiTrigger.ps1
    ```
5.  Jeśli pojawi się błąd o zablokowanych skryptach (np. *UnauthorizedAccess* lub *SecurityError*), odblokuj pliki poleceniem:
    ```powershell
    ls | Unblock-File
    ```
    A następnie uruchom instalator z pominięciem polityki:
    ```powershell
    powershell -ExecutionPolicy Bypass -File .\Install-WifiTrigger.ps1
    ```

## Sposób działania
Skrypt instalacyjny tworzy zadanie w Harmonogramie Zadań Windows o nazwie `WifiIpAddressSelector`. Zadanie to monitoruje dziennik zdarzeń systemowych:
*   **Log:** `Microsoft-Windows-NetworkProfile/Operational`
*   **Event ID:** `10000` (Połączenie z siecią)

Gdy system zarejestruje to zdarzenie, automatycznie uruchamia skrypt `Set-IpConfig.ps1`, który:
1.  Identyfikuje aktywną kartę Wi-Fi.
2.  Wyświetla okno graficzne z 4 opcjami:
    *   **DHCP:** Przywraca automatyczne pobieranie adresu IP i DNS.
    *   **27WE:** Ustawia IP `10.52.99.101`, maskę `255.255.255.0` i bramę `10.52.99.1`.
    *   **AKM:** Ustawia IP `10.5.99.101`, maskę `255.255.255.0` i bramę `10.5.99.1`.
    *   **Custom:** Prosi o podanie własnego adresu IP (ustawia maskę `/24`).

## Odinstalowanie
Aby usunąć narzędzie, uruchom PowerShell jako Administrator i wpisz:
```powershell
Unregister-ScheduledTask -TaskName "WifiIpAddressSelector" -Confirm:$false
```

## Rozwiązywanie problemów
*   **Okno się nie pojawia:** Upewnij się, że usługa "Harmonogram zadań" jest uruchomiona i że w podglądzie zdarzeń (eventvwr.msc) pojawiają się zdarzenia o ID 10000 w ścieżce `Dzienniki aplikacji i usług > Microsoft > Windows > NetworkProfile > Operational`.
*   **Błąd uprawnień w oknie wyboru:** Skrypt musi być wyzwalany z najwyższymi uprawnieniami (zapewnia to skrypt instalacyjny przez parametr `RunLevel Highest`).
