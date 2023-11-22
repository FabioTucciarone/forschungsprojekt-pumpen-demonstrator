# Ausführung des Projekts usw.

Alles funktioniert bisher nur unter Linux / WSL, das liegt primär nicht an uns sondern an ein paar Problemen mit 1HP_NN!

## Python Pakete

- Überlegen, ob man eine virtuelle Pythonumgebung möchte und diese ggf. in `<Forschungsprojekt-Ordner>` erstellen.
- `forschungsprojekt-pumpen-demonstrator/demonstrator_backend` öffnen.
- Alle Pakete mit `pip install -r requirements.txt` installieren.

## Ordnerstruktur des Forschungsprojekts

### Phase 1

Relevante Pfade in paths.yaml:

```yaml
default_raw_dir: <Forschungsprojekt-Ordner>/data/datasets_raw # Datensatz der Rohdaten
models_1hp_dir:  <Forschungsprojekt-Ordner>/data/models_1hpnn # Trainiertes Modell
```

Programm sucht zunächst an den pfaden in der Datei und falls diese nicht existiert am Standardpfad. Gesucht wird:

- `models_1hp_dir/gksi/current_unet_dataset_2d_small_1000dp_gksi_v7`
- `default_raw_dir/datasets_raw_1000_1HP` oder `default_raw_dir/dataset_2d_small_1000dp`

### Phase 1 Standardpfade:

```bash
<Forschungsprojekt-Ordner>
 |
 |- forschungsprojekt-pumpen-demonstrator # Unser Git-Repositiory
 |   |- demonstrator_app
 |   |- demonstrator_backend
 |   ..
 |- data # Das wird als Standardpfad verwendet
 |   |- datasets_raw
 |   |   |- datasets_raw_1000_1HP # Von Darus
 |   |   ..
 |   |- models_1hpnn
 |   |   |- gksi1000
 |   |   ..
 |   |- models_2hpnn # (Für erste Phase irrelevant)
 |   ..
 |- 1HP_NN # Von mir abgezweigte Version: baforschungsprojekt_23 Zweig
 |   |- main.py 
 |   |- paths.yaml # Pfade hier eintragen!
 ..  ..
```

### Phase 1 Lokal: paths.yaml

Folgende Datei respektiert die Standardordnerstruktur (für Linux):

```yaml
default_raw_dir:                        <Forschungsprojekt-Ordner>/data/datasets_raw # egal
datasets_prepared_dir:                  <Forschungsprojekt-Ordner>/data/ # egal
datasets_raw_domain_dir:                <Forschungsprojekt-Ordner>/data/ # egal
datasets_prepared_domain_dir:           <Forschungsprojekt-Ordner>/data/ # egal
prepared_1hp_best_models_and_data_dir:  <Forschungsprojekt-Ordner>/data/ # egal
models_2hp_dir:                         <Forschungsprojekt-Ordner>/data/models_2hpnn
models_1hp_dir:                         <Forschungsprojekt-Ordner>/data/models_1hpnn
datasets_prepared_dir_2hp:              <Forschungsprojekt-Ordner>/data/ # egal
```

### Phase 1 pcsgs08: paths.yaml

Pfade falls das Projekt auf pcsgs08 ausgeführt werden soll.

Achtung auf dem Server liegt nur `dataset_2d_small_1000dp`. Falls das nicht klappt: datasets_raw_1000dp von Darus runterladen und auf den Server in `datasets_1hpnn` hochladen.

```yaml
default_raw_dir:                        /scratch/pelzerja_demonstrator_studis/datasets_1hpnn 
datasets_prepared_dir:                  /scratch/pelzerja_demonstrator_studis/datasets_prepared_1hpnn
datasets_raw_domain_dir:                /scratch/pelzerja_demonstrator_studis/datasets_domain # keine Ahnung
datasets_prepared_domain_dir:           /scratch/pelzerja_demonstrator_studis/datasets_domain # keine Ahnung
prepared_1hp_best_models_and_data_dir:  /scratch/pelzerja_demonstrator_studis/ # keine Ahnung
models_1hp_dir:                         /scratch/pelzerja_demonstrator_studis/models_1hpnn
models_2hp_dir:                         /scratch/pelzerja_demonstrator_studis/models_2hpnn
datasets_prepared_dir_2hp:              /scratch/pelzerja_demonstrator_studis/datasets_prepared_2hpnn
```
