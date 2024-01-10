# Backend Installation und Ausführung

## Python Pakete und Git-Repositories

- Ggf. eine virtuelle Python Umgebung in `<Forschungsprojekt-Ordner>` erstellen.
  https://docs.python.org/3/library/venv.html
- [1HP_NN](https://github.com/FabioTucciarone/1HP_NN/tree/baforschungsprojekt_23) und [Demonstrator](https://github.com/FabioTucciarone/forschungsprojekt-pumpen-demonstrator) klonen.
- Alle Pakete mit `pip install -r requirements.txt` installieren.

### Enthaltene Pakete:

- flask, flask-caching, Werkzeug, gunicorn, numpy, scipy
- 1HP_NN Abhängigkeiten

### 1HP_NN:


## Ordnerstruktur und Datensätze

Das Projekt kann eine Standardordnerstruktur verwenden oder die Pfade können in einer paths.yaml Datei in 1HP_NN spezifiziert werden. Folgende Ordnerstruktur wird jedoch vorausgesetzt:

```bash
<Forschungsprojekt-Ordner>
 |- forschungsprojekt-pumpen-demonstrator # Git-Repositiory
 |- data # Das wird als Standardpfad verwendet
 |- 1HP_NN # baforschungsprojekt_23 Zweig
 ..
```

Die folgenden Datensätze und Modelle müssen gleich benannt vorliegen.
(Standardordnerstruktur die ohne paths.yaml funktioniert)
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
 |- paths.yaml # Pfade zu Datensätzen hier eintragen, wenn obige Struktur nicht eingehalten!
 ..  ..
```
Folgende Datei respektiert die Standardordnerstruktur:

```yaml
default_raw_dir:                        <Forschungsprojekt-Ordner>/data/datasets_raw # Phase 1
models_1hp_dir:                         <Forschungsprojekt-Ordner>/data/models_1hpnn # Phase 1 und 2
models_2hp_dir:                         <Forschungsprojekt-Ordner>/data/models_2hpnn # Phase 2
datasets_prepared_dir:                  "" # manuelle Ausführung
datasets_raw_domain_dir:                "" # manuelle Ausführung
datasets_prepared_domain_dir:           "" # manuelle Ausführung
prepared_1hp_best_models_and_data_dir:  "" # manuelle Ausführung
datasets_prepared_dir_2hp:              "" # manuelle Ausführung
```

## Ausführen
Alle für's Backend nötigen Dateien liegen unter `forschungsprojekt-pumpen-demonstrator/demonstrator_backend`.

- Ist alles korrekt installiert sollte `test.py` fehlerfrei ausgeführt werden können. Unter `test.py: main()` können einige Dinge separat getestet und visualisiert werden.

- Als Standardgerät für 1HP_NN wird die **cpu** verwendet. Ist das nicht gewünscht, so muss im Code bisher manuell unter `demonstrator_backend.py: initialize_backend()` bei `model_configuration = mc.ModelConfiguration(device="cuda")` oder `test.py` ein anderes Gerät spezifiziert werden.

- Ein Flask **Debugserver** kann einfach durch Ausführen von `python3 demonstrator_backend.py` unter Port 5000 gestartet werden.

- Ein Gunicorn **Produktionsserver** kann mittels `gunicorn --bind 0.0.0.0:5000 'demonstrator_backend:app'` gestartet werden. Windows wird nicht unterstützt aber WSL. Auch hier muss Port 5000 verwendet werden.
