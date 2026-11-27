---
name: structurer-module-hexagonal
description: Crée ou vérifie la structure hexagonale d'un module de outil-recette-api (package fr.icdc.dei.bdt.sw1.outilrecette : domain/model, port/in, port/out, service, adapter/in/rest, adapter/out/persistence, config) et les règles ArchUnit associées. À utiliser pour créer un nouveau module backend, vérifier le respect de l'architecture hexagonale ou mettre en place les tests ArchUnit.
---
# Structurer un module en architecture hexagonale

## Arborescence d'un module
```
outil-recette-api/src/main/java/fr/icdc/dei/bdt/sw1/outilrecette/<module>/
├── domain/
│   ├── model/              <Objet>.java (record ou classe), value objects
│   ├── exception/          <Objet>IntrouvableException.java, ...
│   ├── port/in/            <Action><Objet>UseCase.java (+ <Action><Objet>Commande.java)
│   ├── port/out/           <Objet>RepositoryPort.java, <Systeme>Port.java
│   └── service/            <Action><Objet>Service.java implements <Action><Objet>UseCase
├── adapter/
│   ├── in/rest/            <Objet>Controller.java, dto/, <Objet>RestMapper.java
│   └── out/persistence/    <Objet>JpaEntity.java, <Objet>JpaRepository.java,
│                           <Objet>PersistenceMapper.java, <Objet>PersistenceAdapter.java
└── config/                 <Module>Config.java (@Configuration, @Bean des services)
```
Les tests reprennent la même arborescence sous `src/test/java/`.

## Nommage
| Élément | Convention | Exemple |
|---|---|---|
| Cas d'usage | verbe + objet + `UseCase` | `CreerCampagneUseCase` |
| Entrée d'un cas d'usage | verbe + objet + `Commande` (record) | `CreerCampagneCommande` |
| Port sortant | objet + `RepositoryPort` ou système + `Port` | `CampagneRepositoryPort`, `NotificationPort` |
| Service | verbe + objet + `Service` | `CreerCampagneService` |
| Adapter | objet + techno + `Adapter` | `CampagnePersistenceAdapter` |

## Règles ArchUnit (`src/test/java/fr/icdc/dei/bdt/sw1/outilrecette/architecture/ArchitectureTest.java`)
À créer une seule fois, puis à garder vert :
1. Les classes de `..domain..` ne dépendent que de `java..` et de `..domain..`.
2. `..domain.service..` ne dépend pas de `..adapter..`.
3. `..adapter.in..` ne dépend que de `..domain.port.in..`, `..domain.model..`, `..domain.exception..` côté domaine.
4. `..adapter.out..` ne dépend que de `..domain.port.out..` et `..domain.model..` côté domaine.
5. Aucun package `..adapter.in..` ne dépend de `..adapter.out..`, et inversement.
6. Les classes annotées `@Entity` résident dans `..adapter.out.persistence..`.
7. Les classes annotées `@RestController` résident dans `..adapter.in.rest..`.
8. Un module ne dépend d'un autre module que par son `..domain.port.in..`.
9. Pas de cycle entre modules (`slices().matching("..outilrecette.(*)..").should().beFreeOfCycles()`).

## Vérification d'un module existant
Lister chaque violation sous la forme `Fichier:ligne | règle violée | correction`. Ne pas assouplir une règle ArchUnit pour faire passer le build : corriger le code ou proposer un ADR.
