# Forschungsprojekt Pumpendemonstrator

Demonstrator App für https://github.com/JuliaPelzer/1HP_NN

Unser Fork: https://github.com/FabioTucciarone/1HP_NN

## Installation und Ausführung

Installation sowie Ausführung funktionieren für Klienten- und Serverteil des Projekts jeweils separat.

- [Backend](demonstrator_backend)
- [Frontend](demonstrator_app)

Zur Ausführung des Demonstrator im Gesamten muss zunächst ein Backend-Server installiert und gestartet werden.
Das kann entweder lokal auf dem Klientengerät oder auch auf dem IPVS-Institutsserver "pcsgs08" geschehen.

1. Befolge die Installationsanweisungen in der [README.md des Backends](demonstrator_backend) auf dem Zielgerät (lokal oder pcsgs08)
2. Befolge dann die Installationsanweisungen in der [README.md des Frontends](demonstrator_app) auf dem Klientengerät.
3. Starte den Backend-Server, wie in der [README.md des Backends](demonstrator_backend) beschrieben.
4. Starte das Frontend.
5. - Backend ist lokal gestartet: Wähle den "Debug Modus" im Frontend aus, eine Anmeldung ist nicht notwendig.
   - Backend ist auf pcsgs08 gestartet: Im Frontend über SSH und IPVS-Benutzerkonto anmelden .

## Bericht / Dokumentation

Die aktuellste Version des Berichts ist unter [overleaf.com/read/hsnfdjxddxxf#3cba3a](https://www.overleaf.com/read/hsnfdjxddxxf#3cba3a) zu finden.

## Phase 1 Zwischenstand:

Commit SHA: 8ff39d5e4d50101823bf38ba2b03981162d71d52
