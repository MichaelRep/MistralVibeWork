---
name: migrer-servlet-vers-rest
description: Migre une servlet ou action legacy Java vers outil-recette-api en architecture hexagonale (cas d'usage du domaine, port, adapter REST avec DTO record, erreurs ProblemDetail, tests), conforme au contrat OpenAPI. À utiliser pour convertir une servlet, une action Struts ou un traitement JSP en API REST.
---
# Migrer une servlet vers un cas d'usage + endpoint REST

## Prérequis
- Spec validée `outil-recette-api/docs/specs/<module>.md` et endpoint décrit dans `outil-recette-api/api/openapi.yaml`.
- Le module respecte la structure de la skill `structurer-module-hexagonal`. Sinon, l'appliquer d'abord.

## Étapes

1. **Analyser l'existant** : paramètres lus, attributs de session utilisés, validations, appels service/DAO, redirections et messages, codes d'erreur.
2. **Séparer métier et technique** : lister ce qui relève du **métier** (règles RG-xxx, calculs, états) et ce qui relève de la **technique** (HTTP, session, SQL, format). Le premier va dans `domain`, le second dans les adapters.
3. **Correspondance HTTP** :
   | Legacy | REST |
   |---|---|
   | GET affichage liste / détail | `GET /api/<ressources>`, `GET /api/<ressources>/{id}` |
   | POST création | `POST /api/<ressources>` → 201 + `Location` |
   | POST modification | `PUT` ou `PATCH /api/<ressources>/{id}` |
   | POST suppression | `DELETE /api/<ressources>/{id}` → 204 |
   | Message d'erreur dans la JSP | 400 / 404 / 409 / 422 + `ProblemDetail` |
   | Test de droit | 401 / 403 via Spring Security |
4. **Domaine, dans cet ordre** (package `fr.icdc.dei.bdt.sw1.outilrecette.<module>`) :
   1. `domain/model/` : modèle métier (records, value objects), invariants dans les constructeurs.
   2. `domain/port/in/<Action><Objet>UseCase.java` : une interface par cas d'usage, avec une commande en entrée (`record`).
   3. `domain/port/out/<Objet>RepositoryPort.java` (ou `<Systeme>Port`) : ce dont le cas d'usage a besoin.
   4. `domain/service/<Action><Objet>Service.java` : implémente le use case. Chaque règle porte un commentaire `// RG-<MODULE>-<NNN>`.
   5. `domain/exception/` : exceptions métier explicites (`CampagneIntrouvableException`...).
   6. **Tests unitaires du domaine d'abord**, avec des faux en mémoire ou des mocks des `port.out`.
5. **Adapter entrant** `adapter/in/rest/` :
   - `<Objet>Controller.java` : mince, appelle uniquement des `port.in`.
   - `dto/*.java` : `record` avec Jakarta Validation ; `<Objet>RestMapper` DTO ↔ commande / modèle.
   - Tests `@WebMvcTest` : codes HTTP, validation, sécurité, mapping, traduction des exceptions métier.
6. **Adapter sortant** : skill `migrer-acces-donnees`.
7. **Câblage** `config/<Module>Config.java` : `@Bean` des services du domaine (le domaine n'a aucune annotation Spring). Transactions : `@Transactional` sur l'adapter ou via un décorateur dans la config, jamais dans le domaine.
8. **Erreurs** : les exceptions métier sont traduites en `ProblemDetail` par `shared/error`, avec un `type` stable par erreur.
9. **État de session** : le supprimer. L'API est sans état : les informations passent par le token (utilisateur, rôles) ou par les paramètres.
10. **Vérifier** : `mvn -f outil-recette-api/pom.xml verify` (ArchUnit + 100 % de couverture), puis les tests de parité du module. S'il manque de la couverture, utiliser la skill `atteindre-couverture-100`.

## Pièges fréquents du legacy
- Encodage (ISO-8859-1 vs UTF-8), formats de dates et nombres localisés, `null` vs chaîne vide.
- Effets de bord cachés : historisation, mails, mise à jour d'autres tables. Chacun devient un `port.out` explicite.
- Transactions implicites (autocommit JDBC) : vérifier ce qui doit être atomique.
