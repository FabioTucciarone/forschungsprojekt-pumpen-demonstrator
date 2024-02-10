# Backend Installation und Ausführung

Das Backend kann entweder als lokaler Server auf dem Rechner des Klienten ("lokale Installation") oder als Serveranwendung auf den IPVS-Institutsservern installiert werden ("Serverinstalation").
Die lokale Installation ist für Tests und zum Debugging gedacht.
Es ist jeweils nur einer der beiden Schritte notwendig.

## Installation und Ausführung
1. Lade Python-Code und Pakete herunter: [Abschnitt 1](##1.-Python-Pakete-und-Git-Repositories)
2. Konfiguriere Pfade und Datensätze: [Abschnitt 2](##2.-Ordnerstruktur-und-Datensätze)
3. Ausführung und Testen: [Abschnitt 3](##3.-Ausführen-und-Testen)

## 1. Python Pakete und Git-Repositories

- Erstelle einen Zielordner (`<Forschungsprojekt-Ordner>`).
- Ggf. eine virtuelle Python Umgebung in `<Forschungsprojekt-Ordner>` erstellen.
  https://docs.python.org/3/library/venv.html
- Klone diese [Demonstrator Projekt](https://github.com/FabioTucciarone/forschungsprojekt-pumpen-demonstrator).
- Klone einen [Fork des 1HP_NN Projekts](https://github.com/FabioTucciarone/1HP_NN/tree/baforschungsprojekt_23) von Julia Pelzer.
Hier muss vom Zweig "baforschungsprojekt_23" gepullt werden.
- Alle Pakete mit `pip install -r requirements.txt` (momentan veraltet und unvollständig) installieren.

### Enthaltene Pakete:

- flask, flask-caching, Werkzeug, gunicorn, numpy, scipy, 
- csv, pandas, requests (für Messungen, Grafikerstellung und Tests)
- 1HP_NN Abhängigkeiten


## 2. Ordnerstruktur und Datensätze

Um korrekt funktionieren zu können, benötigt das Demonstrator Backend Zugriff auf einige Daten, die bereitgestellt werden müssen.

- Rohdatensatz der ersten Stufe: [1HP-Boxen 1000 Punkte Rohdatensatz](https://doi.org/10.18419/darus-3650).
- gksi-Modell der ersten Stufe. Trainierbar aus 1HP Datensatz mit [1HP_NN](https://github.com/JuliaPelzer/1HP_NN)
- gksi-seperate-Modell der zweiten Stufe. Trainierbar mit [1HP_NN](https://github.com/JuliaPelzer/1HP_NN) und [2HP-Domänen 1000 Punkte Rohdatensatz](https://doi.org/10.18419/darus-3652)

Um das alles zu finden, kann das Projekt eine Standardordnerstruktur verwenden oder die Pfade können in einer `paths.yaml` Datei im Projektordner spezifiziert werden. 
Folgende Ordnerstruktur wird jedoch vorausgesetzt:

```bash
<Forschungsprojekt-Ordner>
 |- forschungsprojekt-pumpen-demonstrator # Git-Repositiory
 |   |- paths.yaml # Hier Pfade eintragen
 |   ..
 |- data # Das wird als Standardpfad verwendet
 |- 1HP_NN # baforschungsprojekt_23 Zweig
 ..
```

Die folgenden Datensätze und Modelle müssen gleich benannt vorliegen, wenn die Standardordnerstruktur die ohne `paths.yaml` Datei verwendet werden soll.
```bash
data # Das wird als Standardpfad verwendet
 |- datasets_raw # Phase 1. Einer von beiden:
 |   |- dataset_2d_small_1000dp # Von pcsgs08
 |   |- datasets_raw_1000_1HP   # Von Darus
 |   ..
 |- models_1hpnn # Phase 1
 |   |- gksi1000
 |   |   |- current_unet_dataset_2d_small_1000dp_gksi_v7
 |   ..  ..
 |- models_2hpnn # Phase 2
 |   |- 1000dp_1000gksi_separate
 |   |   |- current_unet_dataset_2hps_1fixed_1000dp_2hp_gksi_1000dp_v1
 |   ..  ..
 ..
1HP_NN # baforschungsprojekt_23 Zweig
 |- main.py 
 ..  ..
```

Soll die paths.yaml Datei verwendet werden, müssen die vollständigen Pfade wie unten beschrieben angegeben werden.
D.h. in `default_raw_dir` müssen die Datenpunkte vorliegen und in `models_Xhp_dir` müssen eine info.yaml und eine model.pt Datei zu finden sein.
Die folgende paths.yaml Datei respektiert die Standardordnerstruktur:

```yaml
default_raw_dir: <Forschungsprojekt-Ordner>/data/datasets_raw/dataset_2d_small_1000dp # Phase 1
models_1hp_dir:  <Forschungsprojekt-Ordner>/data/models_1hpnn/gksi1000/current_unet_dataset_2d_small_1000dp_gksi_v7 # Phase 1 und 2
models_2hp_dir:  <Forschungsprojekt-Ordner>/data/models_2hpnn/1000dp_1000gksi_separate/current_unet_dataset_2hps_1fixed_1000dp_2hp_gksi_1000dp_v1 # Phase 2
```

## 3. Ausführen und Testen
Alle für das Backend nötigen Dateien liegen unter `forschungsprojekt-pumpen-demonstrator/demonstrator_backend`.

Das Frontend ist nicht ohne einen aktiven Backendserver funktionsfähig.
Daher muss zunächst dieser gestartet werden.

### Erstmaliges Ausführen und Testen

Wird das Backend zum ersten Mal gestartet, sollten folgende Schritte durchgeführt werden:

1. **Testen der Installation:** Führe `test.py -t installation` aus. Endet das Programm fehlerfrei, ist alles korrekt installiert.

2. **Server starten:** Es ist je nach Installation nur einer der beiden Schritte notwendig.
   - **Produktionsserver starten (Serverinstallation):** Um das Backend zu starten, muss `gunicorn --bind 0.0.0.0:5000 'demonstrator_backend:app'`ausgeführt werden. 
   - **Debugserver starten (lokale Installation):** Ein Flask Debugserver kann durch Ausführen von `python3 demonstrator_backend.py` unter Port 5000 gestartet werden.

3. **Bereit:** Nachdem der Server gestartet wurde, kann er auf HTTP-Anfragen antworten.
Die Schnittstelle hierzu ist in der Dokumentation von `demonstrator_backend.py` zu finden.

### Reguläre Ausführung

**Server starten:** Es ist je nach Installation nur einer der beiden Schritte notwendig.
- Führe bei Serverinstallation `gunicorn --bind 0.0.0.0:5000 'demonstrator_backend:app'` aus.
- Führe bei lokaler Installation  `python3 demonstrator_backend.py` aus.

### Zusätzliche Ausführungsinformationen

- **Testen des Servers:** Führe `test.py -t server` aus, während der Server läuft. Endet das Programm fehlerfrei, treten keine Ausnahmen bei der HTTP-Kommunikation auf. Dazu muss der Server unter `127.0.0.1:5000` erreichbar sein. Starte dafür einen Flask-Debugserver oder öffne einen SSH Tunnel zu pcsgs08.

- **Zeit- und Fehlermessen:** `test.py -m <n>` testet für die ersten $n$ Datenpunkte den Fehler und die Generationszeit der Grundwahrheiten.
Es werden csv Dateien mit den Ergebnissen generiert, die anschließend durch die Ausführung von `generate_boxplots.py` visualisiert werden können.

- **Visualisieren Grundwahrheit:** `test.py -m <n> -v`. Die `-v` Flagge aktiviert die Visualisierung der generierten Wärmefahnen.

- **Debugserver:** Ein Flask-Debugserver kann einfach durch Ausführen von `python3 demonstrator_backend.py` unter Port 5000 gestartet werden.

- **Cuda:** Das standardmäßig von 1HP_NN und pytorch verwendete Gerät ist "cuda" sofern dieses verfügbar ist, ansonsten wird "cpu" verwendet.

## Links zu den Datensätzen auf DaRUS
- [1HP-Boxen 1000 Punkte Rohdatensatz](https://doi.org/10.18419/darus-3650)
- [2HP-Domänen 1000 Punkte Rohdatensatz](https://doi.org/10.18419/darus-3652)
