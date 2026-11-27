# AGENTS.md — outil-recette-api (backend)

Java 21, Spring Boot, Maven. **Architecture hexagonale stricte** et **100 % de couverture**
(lignes et branches), vérifiée par JaCoCo dans `mvn verify`.
Package racine : **`fr.icdc.dei.bdt.sw1.outilrecette`**.

## Architecture hexagonale

```
src/main/java/fr/icdc/dei/bdt/sw1/outilrecette/
├── OutilRecetteApplication.java
├── shared/                         transverse : config Spring, sécurité, gestion des erreurs
│   ├── config/
│   └── error/                      @RestControllerAdvice → ProblemDetail (RFC 9457)
└── <module>/                       un dossier par module fonctionnel (ex. campagne, anomalie)
    ├── domain/                     CŒUR : Java pur, aucune dépendance technique
    │   ├── model/                  entités et value objects métier (records si immuables)
    │   ├── exception/              exceptions métier
    │   ├── port/in/                cas d'usage exposés (interfaces) : CreerCampagneUseCase
    │   ├── port/out/               besoins sortants (interfaces) : CampagneRepositoryPort
    │   └── service/                implémentation des cas d'usage, porte les règles RG-xxx
    ├── adapter/in/rest/            controllers, DTO (record), mappers DTO ↔ domaine
    ├── adapter/out/persistence/    entités JPA, repositories Spring Data, mappers, implémente port/out
    ├── adapter/out/<systeme>/      autres sorties (mail, web service, fichiers...)
    └── config/<Module>Config.java  câblage : @Bean des services du domaine
```

### Règles de dépendance (vérifiées par ArchUnit)
- `domain` ne dépend **de rien** d'autre que du JDK : pas de Spring, JPA, Jakarta, Jackson ni Lombok.
- `domain.service` implémente `port.in` et n'utilise que `port.out` et `domain.model`.
- `adapter.in` appelle uniquement `port.in`. `adapter.out` implémente uniquement `port.out`.
- Aucun adapter ne dépend d'un autre adapter.
- Les entités JPA ne sortent jamais de `adapter.out.persistence`, les DTO ne sortent jamais de `adapter.in.rest`.
- Un module ne dépend d'un autre module que par ses `port.in`.
- Ces règles sont codées dans `src/test/java/.../architecture/ArchitectureTest.java`. Ne jamais les assouplir sans ADR.

## Tests et couverture à 100 %

| Couche | Type de test | Outils |
|---|---|---|
| `domain.service`, `domain.model` | Unitaire pur, un test par règle RG-xxx | JUnit 5, AssertJ, Mockito ou faux en mémoire pour les `port.out` |
| `adapter.in.rest` | Tranche web : codes HTTP, validation, sécurité, mapping | `@WebMvcTest`, MockMvc |
| `adapter.out.persistence` | Tranche données : requêtes, mapping | `@DataJpaTest` + Testcontainers |
| Architecture | Règles de dépendance | ArchUnit |
| Parité | Rejeu des scénarios de caractérisation | `@SpringBootTest` + MockMvc ou RestAssured, `src/test/resources/parite/<module>/` |

- JaCoCo : règle `check` à **1.00 en LINE et en BRANCH**, liée à la phase `verify`.
- Exclusions autorisées, et seulement celles-ci : `OutilRecetteApplication`, le code généré
  (`target/generated-sources`). Toute autre exclusion passe par un ADR.
- **Pas de test de complaisance** : chaque test vérifie un comportement avec des assertions
  significatives. Un test sans assertion, ou qui ne fait qu'appeler un getter, est refusé.
- Recommandé : tests de mutation PIT sur `domain` pour vérifier que les tests détectent vraiment les erreurs.
- Les tests portent l'identifiant de la règle : `@DisplayName("RG-CAMP-003 : ...")`.

## Conventions

- DTO et value objects en `record`. Injection par constructeur.
- Validation des entrées par Jakarta Bean Validation **dans l'adapter REST** ; invariants métier dans le domaine.
- Erreurs : exceptions métier du domaine traduites en `ProblemDetail` par `shared/error`.
- Schéma de base géré par **Flyway** (`src/main/resources/db/migration`).
- Configuration par variables d'environnement, probes via Spring Boot Actuator.
- Logs structurés, sans donnée personnelle.
- Mappers : manuels ou MapStruct, selon l'ADR. Ils sont testés comme le reste.

## Artefacts transverses hébergés ici

- `api/openapi.yaml` : contrat d'API (OpenAPI 3.1).
- `docs/` : cartographie du legacy, specs, ADR, plans, suivi.

## Déploiement

- `Dockerfile` à la racine du repo, chart Helm dans `deploy/helm/outil-recette-api/`.

## Git

- Branche par tranche : `migration/<module>`. Commits `feat(<module>): ...`, `test(<module>): ...`.
