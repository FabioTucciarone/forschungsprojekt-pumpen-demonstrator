# Ausführung

Alles funktioniert bisher nur unter Linux / WSL, das liegt primär nicht an uns sondern an ein paar Problemen mit 1HP_NN!

## Python Pakete

- Um den Debug-Flask Server zu starten einfach einmal setup_backend.sh ausführen, das sollte alles was für unsere Seite Notwendig ist in einem .venv Ordner installieren
- Für 1HP_NN auf GitHub im README nachschauen
- Eventuell stehen nicht alle notwendigen Pakete im README, dann einfach die fehlenden auch noch installieren (ModuleNotFoundError von python).

## Ordnerstruktur des Forschungsprojekts

Falls im Programm keine optionalen Parameter im Konstruktoraufruf des ModelCommunication Objekts übergeben werden:

- Sucht gksi1000 am Standardpfad
- Sucht datasets_raw_1000_1HP an Pfad in paths.yaml oder falls diese fehlt am Standardpfad

Wenn **dataset_name** spezifiziert wird, wird dieser statt datasets_raw_1000_1HP verwendet, die Suche funktioniert analog.

Wenn **full_model_path** spezifiziert wird, wird dieses Modell statt des Standardmodells verwendet

- Standard: “…/models_1hpnn/gksi1000/current_unet_dataset_2d_small_1000dp_gksi_v7”
- Hier muss ein vollständiger Pfad angegeben werden, 1hp-modelle können nicht über die paths.yaml Datei festgelegt werden.

### Angenommene Standardpfade:

```bash
<Forschungsprojekt-Ordner>
 |
 |- forschungsprojekt-pumpen-demonstrator # (Unser Git-Repositiory)
 |   |- demonstrator_app
 |   |- demonstrator_backend
 |   ..
 |- data # Das wird als Standardpfad verwendet
 |   |- datasets_raw
 |   |   |- datasets_raw_1000_1HP # (Von Darus)
 |   |   ..
 |   |- datasets_prepared
 |   |- models_1hpnn
 |   |   |- gksi1000
 |   |   ..
 |   |- models_2hpnn # (Für erste Phase irrelevant)
 |   |- 1HP_NN_preparation_BEST_models_and_data # (Für erste Phase irrelevant)
 |   ..
 |- 1HP_NN # (Von mir abgezweigte Version: baforschungsprojekt_23 Zweig)
 |   |- main.py 
 |   |- paths.yaml # Pfade hier eintragen!
 ..  ..
```

Das ModelCommunication Objekt wird hier erzeugt:

- demonstrator_backend.py:  initialize_backend()
- model_communication.py:  if __name__ == "__main__":  (falls direkt über die Konsole ausgeführt)

### Die paths.yaml Datei

Folgende Datei respektiert die Standardordnerstruktur (für Linux):

```yaml
default_raw_dir:                        <Forschungsprojekt-Ordner>/data/datasets_raw # where the raw 1st stage data is stored
datasets_prepared_dir:                  <Forschungsprojekt-Ordner>/data/datasets_prepared # where the prepared 1st stage data is stored
datasets_raw_domain_dir:                <Forschungsprojekt-Ordner>/data/datasets_prepared
datasets_prepared_domain_dir:           <Forschungsprojekt-Ordner>/data/datasets_prepared
prepared_1hp_best_models_and_data_dir:  <Forschungsprojekt-Ordner>/data/1HP_NN_preparation_BEST_models_and_data
models_2hp_dir:                         <Forschungsprojekt-Ordner>/data/models_2hpnn/runs
datasets_prepared_dir_2hp:              <Forschungsprojekt-Ordner>/data/datasets_prepared
```