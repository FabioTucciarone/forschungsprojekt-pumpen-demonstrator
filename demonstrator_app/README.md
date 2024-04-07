# Demonstrator App

Der gesamte Code liegt unter [lib](lib/), die Bilder und Audiodateien unter [assets](assets/) und die Dependencies in der pubspec.yaml Datei.

## Frontend Ausführung/Installation

### 1. Windows (Supported)
Relevant für die **Ausführung** ist nur der [Release](Releases/Windows/) Ordner. Dieser kann alleinstehend exportiert und benutzt werden.

Öffne [demonstrator_app.exe](Releases/Windows/demonstrator_app.exe).

Wenn das Programm **selbst ausgeführt** oder gebaut werden soll, dann installiere dafür [Flutter](https://docs.flutter.dev/get-started/install/windows/desktop?tab=vscode). Nach erfolgreicher Installation kann man die App  direkt ausführen via `flutter run --release`. Es kann sein, dass Flutter einen auffordert das Gerät auszuwählen, befolge hierfür die Anweisungen in der Konsole. Da mit Plugins gearbeitet wird, kann es sein, dass beim selber kompilieren der Entwicklermodus in den Einstellungen eingeschaltet werden muss. Befolge auch hier den Anweisungen der Konsole. Der Entwicklermodus kann nach dem ersten Bauen/Ausführen direkt wieder deaktiviert werden. 

Für die **Entwicklung** eignet sich `flutter run`, was die App im Debug Modus startet. Die Punkte von oben treffen hier auch zu. Im Debug Modus hat man eine Reihe von extra Commands, die helfen können, diese werden in der Konsole dann beschrieben. 

Zum **Bauen** kann `flutter build windows` ausgeführt werden. Dies kompiliert die App [hier](build/windows/runner/release). Dieser Ordner kann alleinstehend zur Ausführung exportiert werden und die .exe darin ausgeführt werden.
Pakete und Plugins werden automatisch installiert.


### 2. Linux (Unsupported)
Warnung!  Da Flutter für Linux nicht von Windows aus gebaut werden kann, ist Linux als Plattform nicht unterstützt. Das Design ist außerdem nicht für Linux ausgelegt und getestet. Design weicht ab!

Wir haben testweise versucht die Linux App über das WSL zu bauen, ohne Garantie. 
Öffne [demonstrator_app](Releases/Linux/demonstrator_app).

Wenn das nicht funktioniert, kann man selbst Flutter installieren.
Mehr dazu auf der [Flutter Website](https://docs.flutter.dev/get-started/install/linux).
Wir empfehlen eine manuelle Installation (method 2).

Nach erfolgreicher Installation kann man innerhalb des demonstrator_app Ordners mit `flutter run --release` die App **benutzen** oder mit `flutter build linux` die App **selber bauen**. Man findet den Build (demonstrator_app Datei) danach [hier](build/linux/x64/release/bundle/).

Für die **Entwicklung** eignet sich `flutter run`, was die App im Debug Modus startet. Es gelten die Punkte von Windows auch hier. Im Debug Modus hat man eine Reihe von extra Commands, die helfen können, diese werden in der Konsole dann beschrieben. 

Wie bei Windows auch ist nur der [Releases](Releases/Linux/) (oder /build/linux/x64/release/bundle/) Ordner wichtig und kann alleinstehend exportiert werden zur Benutzung.

Pakete und Plugins werden automatisch installiert.

## Benutzung

Wichtig! Vor der Benutzung der App muss der Server gestartet werden (siehe Backend)

Melde dich an oder wähle lokale Ausführung.
Bestimme die Version.

## Projektstruktur

Beschreibung der [Dart-Dateien](lib/):
- **main.dart**: Hier wird die App mit RegisterApp (Anmeldeseite) gestartet.
- **BackendConnection.dart**: Die Datei enthält Methoden, die für die Anmeldung zum IPVS-Server benutzt werden, und die HTTP-Anfragen an den Server. 
- **BuildConnection.dart**: Diese Datei enthält den Code für die Anmeldeseite mit zugehöriger Rückmeldung, ob sie erfolgreich war. Es kann zwischen lokaler und Serverausführung gewählt werden.
- **AdminPage.dart**: Hier wird die Adminseite definiert, wo zwischen wissenschaftlicher und Kinderversion gewählt werden kann. Außerdem wird *useOfBackend* definiert, mit der auf *backend* und damit die Methoden von BackendConnection von überall zugegriffen werden kann.
- **Intro.dart**: In der Datei ist der Code für die Einführung der wissenschaftlichen mit dem Einführungstext und der Klasse *TooltipTextSpan*, mit der beim Hovern über Text Bilder angezeigt werden können. Des Weiteren gibt es auch die Einführung der Kinderversion bestehend aus den Erklärungen des Roboters, den Interaktionen mit diesem (in Form von Schaltflächen) und dem Abspielen der Audio. In der Klasse *OurColors* können die Farben des Hintergrunds, der Anwendungsleiste, der Schaltflächen, etc. angepasst werden.
- **MainScreen.dart**: Hier ist der Code für die Seite, mit der der Benutzer interagiert, wobei nur für die Stufe 1 und 2 der wissenschaftlichen Version. Code für die Kinderversion ist nur für die Anwendungsleiste und Elemente, die von beiden Versionen verwendet werden, welche im mixin *MainScreenElements* definiert werden, vorhanden. Außerdem gibt es die Future Notifier Klassen, die für die Ausgabebilder eingesetzt werden.   
- **MainScreen_kids.dart**: In dieser Datei ist der Code für die Stufe 1 und 2 der Kinderversion mit den Anweisungen und Reaktionen des Roboters.
- **Highscores.dart**: Hier ist der Code für die Punktzahl, die Anzeige des Highscores und die Bestenliste in der Kinderversion bzw. der durchschnittliche Fehler in der wissenschaftlichen Version.
- **NamePicker.dart**: Hier wird zufällig der Benutzername für die Bestenliste in der Kinderversion bestimmt. 
- **Timer.dart**: Die Datei enthält einen Timer, der nach einer bestimmten Zeit die Ergebnisse zurücksetzt und zur Einführung wechselt. 
- **Slider.dart**: In der Datei wird der Schieberegler für die Eingabe und das Senden der Parameter an das Backend definiert. 
- **PumpInputBox.dart**: Hier wird die Eingabebox für die Position der zweiten Wärmepumpe definiert, die gleichzeitig das Ausgabebild anzeigt. 
- **Outputbox.dart**: Diese Datei enthält den Code für das Ausgabefeld, das das Ergebnis des neuronalen Netzwerks anzeigt. Außerdem gibt es die Klasse *ResponseDecoder*, mit der die HTTP Response (Bild) decodiert wird. 