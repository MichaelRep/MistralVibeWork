---
name: migrer-acces-donnees
description: Migre l'accès aux données legacy (JDBC, SQL concaténé, DAO maison, procédures stockées) vers un adapter sortant de persistance dans outil-recette-api (implémentation d'un port.out avec Spring Data JPA ou JdbcClient), avec migrations Flyway et tests Testcontainers. À utiliser pour réécrire un DAO, des requêtes SQL ou le schéma de base.
---
# Migrer l'accès aux données (adapter sortant)

## Choisir l'outil
| Cas | Choix |
|---|---|
| CRUD simple sur une table / un agrégat | Spring Data JPA (entité + repository) |
| Requête complexe, reporting, SQL existant à conserver tel quel | `JdbcClient` avec SQL paramétré |
| Procédure stockée | `JdbcClient` / `SimpleJdbcCall`, ADR si on la garde |

## Étapes
1. **Inventorier** les requêtes du DAO legacy (depuis `outil-recette-api/docs/legacy/<module>.md`) : SQL, paramètres, résultat, transactions.
2. **Partir du port** : le `domain/port/out/<Objet>RepositoryPort` est défini par les besoins du domaine, **pas** par la forme des tables. Ne pas y faire apparaître de type JPA ou SQL.
3. **Schéma** :
   - Base existante conservée : script Flyway `V1__baseline.sql` reflétant l'existant, et `baselineOnMigrate` ; aucune modification destructive sans ADR.
   - Nouvelle base : scripts `V<n>__<description>.sql` versionnés + plan de reprise des données (ADR).
4. **Implémenter** dans `<module>/adapter/out/persistence/` :
   - `<Objet>JpaEntity` : reste dans ce package, `equals/hashCode` sur l'identifiant, chargement `LAZY` par défaut.
   - `<Objet>JpaRepository` (Spring Data) ou requêtes `JdbcClient`.
   - `<Objet>PersistenceMapper` : entité ↔ modèle du domaine.
   - `<Objet>PersistenceAdapter implements <Objet>RepositoryPort`.
   - **Toujours** des requêtes paramétrées : remplacer tout SQL concaténé (risque d'injection).
5. **Tests** (`@DataJpaTest` + Testcontainers, avec la même base que la production) :
   - chaque méthode de l'adapter, y compris les cas vides et « non trouvé » ;
   - le mapper dans les deux sens, champs optionnels compris ;
   - **équivalence** : pour chaque requête legacy, même résultat sur le même jeu de données.
6. **Performance** : vérifier les requêtes N+1, ajouter pagination et index si la liste legacy n'était pas paginée.

## Règles
- Ne jamais pointer les tests vers une vraie base partagée.
- Les identifiants de connexion viennent de variables d'environnement, jamais du code.
