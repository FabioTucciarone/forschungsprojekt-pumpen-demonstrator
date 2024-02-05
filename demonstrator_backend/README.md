# Backend Installation und Ausführung

## Python Pakete und Git-Repositories

- Ggf. eine virtuelle Python Umgebung in `<Forschungsprojekt-Ordner>` erstellen.
  https://docs.python.org/3/library/venv.html
- [1HP_NN](https://github.com/FabioTucciarone/1HP_NN/tree/baforschungsprojekt_23) und [Demonstrator](https://github.com/FabioTucciarone/forschungsprojekt-pumpen-demonstrator) klonen.
- Alle Pakete mit `pip install -r requirements.txt` (sollt noch ein bisschen aufgeräumt werden) installieren.

### Enthaltene Pakete:

- flask, flask-caching, Werkzeug, gunicorn, numpy, scipy, 
- csv, pandas (Messen und Grafiken erstellen)
- 1HP_NN Abhängigkeiten

### 1HP_NN:


## Ordnerstruktur und Datensätze

Das Projekt kann eine Standardordnerstruktur verwenden oder die Pfade können in einer `paths.yaml` Datei im Projektordner spezifiziert werden. 
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
Alle für's Backend nötigen Dateien liegen unter `forschungsprojekt-pumpen-demonstrator/demonstrator_backend`.

- Ist alles korrekt installiert sollte `test.py -t` fehlerfrei ausgeführt werden können.
- `test.py -m` ist zum Zeit- und Fehlermessen der Grundwahrheiten verwendbar. Generiert csv Dateien, die mit generate_boxplots.py darstellbar sind.

- Das standardmäßig von 1HP_NN und pytorch verwendete Gerät ist "cuda" sofern dieses verfügbar ist, ansonsten wird "cpu" verwendet.

- Ein Flask **Debugserver** kann einfach durch Ausführen von `python3 demonstrator_backend.py` unter Port 5000 gestartet werden.

- Ein Gunicorn **Produktionsserver** kann mittels `gunicorn --bind 0.0.0.0:5000 'demonstrator_backend:app'` gestartet werden. Windows wird nicht unterstützt aber WSL. Auch hier muss Port 5000 verwendet werden.

## Links zu den Datensätzen auf DaRUS
- [1HP-Boxen 1000 Punkte Rohdatensatz](https://doi.org/10.18419/darus-3650)
- [2HP-Domänen 1000 Punkte Rohdatensatz](https://doi.org/10.18419/darus-3652)
