# Backend Installation und Ausführung

## Python Pakete und Git-Repositories

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


## Ordnerstruktur und Datensätze

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

## Ausführen
Alle für das Backend nötigen Dateien liegen unter `forschungsprojekt-pumpen-demonstrator/demonstrator_backend`.

- **Testen der Installation:** Führe `test.py -t installation` aus. Endet das Programm fehlerfrei, ist alles korrekt installiert.

- **Produktionsserver starten:** Um das Backend zu starten, muss `gunicorn --bind 0.0.0.0:5000 'demonstrator_backend:app'`ausgeführt werden. 

- **Testen des Servers:** Führe `test.py -t server` aus. Endet das Programm fehlerfrei, treten keine Ausnahmen bei der HTTP-Kommunikation auf.

- **Bereit:** Nachdem der Server gestartet wurde, kann er auf HTTP-Anfragen antworten.
Die Schnittstelle hierzu ist in der Dokumentation von `demonstrator_backend.py` zu finden.


## Zusätzliche Ausführungsinformationen

- **Cuda:** Das standardmäßig von 1HP_NN und pytorch verwendete Gerät ist "cuda" sofern dieses verfügbar ist, ansonsten wird "cpu" verwendet.

- **Zeit- und Fehlermessen:** `test.py -m <n>` testet für die ersten $n$ Datenpunkte den Fehler und die Generationszeit der Grundwahrheiten.
Es werden csv Dateien mit den Ergebnissen generiert, die anschließend durch die Ausführung von `generate_boxplots.py` visualisiert werden können.

- **Visualisieren Grundwahrheit:** `test.py -m <n> -v`. Die `-v` Flagge aktiviert die Visualisierung der generierten Wärmefahnen.

- **Debugserver:** Ein Flask Debugserver kann einfach durch Ausführen von `python3 demonstrator_backend.py` unter Port 5000 gestartet werden.

## Links zu den Datensätzen auf DaRUS
- [1HP-Boxen 1000 Punkte Rohdatensatz](https://doi.org/10.18419/darus-3650)
- [2HP-Domänen 1000 Punkte Rohdatensatz](https://doi.org/10.18419/darus-3652)
