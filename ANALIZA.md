# Analiza rozwiązań: Przełącznik adresacji IP po połączeniu z Wi-Fi

## Wstęp
Zadanie polega na stworzeniu mechanizmu, który w systemie Windows 11 Pro, po każdym połączeniu z siecią Wi-Fi, wyświetli użytkownikowi menu wyboru konfiguracji sieciowej (DHCP, predefiniowane adresy statyczne lub własny adres).

## Rozwiązania poddane analizie

### 1. Harmonogram Zadań (Task Scheduler) z wyzwalaczem zdarzeń (Event Trigger)
To podejście wykorzystuje wbudowany w Windows mechanizm logowania zdarzeń. System Windows generuje zdarzenie o ID 10000 w dzienniku `Microsoft-Windows-NetworkProfile/Operational` w momencie połączenia z siecią.

*   **Zalety:**
    *   Brak procesu działającego w tle (minimalne zużycie zasobów).
    *   Natywny mechanizm systemowy.
    *   Wysoka niezawodność – system sam dba o uruchomienie skryptu.
*   **Wady:**
    *   Wymaga uprawnień administratora do konfiguracji.
    *   Nieco bardziej skomplikowana konfiguracja (wymaga edycji XML zadania lub użycia skryptu instalacyjnego).
*   **Werdykt:** **Zalecane.** Jest to najbardziej profesjonalne i "czyste" rozwiązanie.

### 2. Skrypt PowerShell działający w tle (Event Subscription)
Skrypt PowerShell uruchamiany przy starcie systemu, który używa polecenia `Register-ObjectEvent` lub monitoruje zdarzenia WMI/CIM.

*   **Zalety:**
    *   Cała logika w jednym pliku skryptu.
    *   Łatwiejsze debugowanie w czasie rzeczywistym.
*   **Wady:**
    *   Proces `powershell.exe` musi stale działać w tle, co zużywa pamięć RAM.
    *   Ryzyko przypadkowego zamknięcia procesu przez użytkownika.
*   **Werdykt:** Opcjonalne, ale mniej efektywne niż Harmonogram Zadań.

### 3. Usługa Windows (Windows Service) napisana w C#/.NET
Dedykowana usługa systemowa monitorująca stan interfejsów sieciowych.

*   **Zalety:**
    *   Pełna kontrola nad zachowaniem aplikacji.
    *   Najwyższy poziom integracji systemowej.
*   **Wady:**
    *   Wymaga kompilacji kodu i instalacji (nie jest to "lekki skrypt").
    *   Usługi działają w sesji 0, więc wyświetlenie GUI użytkownikowi wymaga dodatkowych zabiegów (np. komunikacji z procesem użytkownika).
*   **Werdykt:** Przerost formy nad treścią dla tego konkretnego zadania.

## Wybrana technologia
Zdecydowano się na **Rozwiązanie 1 (Harmonogram Zadań + PowerShell + WinForms)**.
*   **PowerShell** zapewni logikę zmiany ustawień sieciowych.
*   **Windows Forms (System.Windows.Forms)** zostanie użyty do stworzenia interfejsu graficznego.
*   **Task Scheduler** zapewni automatyczne wyzwalanie skryptu przy każdym połączeniu z Wi-Fi.
