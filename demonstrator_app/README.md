# Demonstrator App

Der gesamte Code liegt unter [lib](/lib/), [assets](/assets/) und in der pubspec.yaml Datei.

## Frontend Ausführung/Installation

### 1. Windows (Supported)
Relevant für die Ausführung ist nur der [Release](/Release/Windows/) Ordner. Dieser kann alleinstehend exportiert und benutzt werden.

Öffne [demonstrator_app.exe](/Releases/Windows/demonstrator_app.exe).

Melde dich an oder wähle lokale Ausführung.
Bestimme die Version.

### 2. Linux (Unsupported)
Warnung!  Da Flutter für Linux nicht von Windows aus gebaut werden kann, ist Linux als Plattform nicht unterstützt. Das Design ist außerdem nicht für Linux ausgelegt und getestet. Design weicht ab!

Wir haben testweise versucht die Linux App über das WSL gebaut, ohne Garantie. 
Öffne [demonstrator_app](/Releases/Linux/demonstrator_app).

Wenn das nicht funktioniert, kann man selbst Flutter zu installieren.
Mehr dazu auf der [Flutter Website](https://docs.flutter.dev/get-started/install/linux).
Wir empfehlen eine manuelle Installation (method 2).
Nach erfolgreicher Installation kann man innerhalb des demonstrator_app Ordners mit "flutter run --release" die App benutzen oder mit "flutter build linux" die App selber bauen. Man findet den Build (demonstrator_app Datei) danach [hier](/build/linux/x64/release/bundle/).

Wie bei Windows auch ist nur der [Releases](/Releases/Linux/) (oder /build/linux/x64/release/bundle/) Ordner wichtig und kann alleinstehend exportiert werden zur Benutzung.

Melde dich an oder wähle lokale Ausführung.
Bestimme die Version.


