---
name: checklist-migration
description: Checklist de fin de tranche de migration (parité fonctionnelle, règles RG-xxx, tests, contrat OpenAPI, sécurité, conventions, docs, suivi). À utiliser avant de déclarer un module migré, avant une revue ou une fusion.
---
# Checklist de fin de tranche

Remplir chaque case avec ✅, ❌ (avec explication) ou N/A, et ajouter le résultat au plan `outil-recette-api/docs/plans/<module>.md`.

## Fonctionnel
- [ ] Toutes les règles RG-<MODULE>-xxx de la spec sont implémentées (lister les manquantes).
- [ ] Chaque règle a au moins un test qui porte son identifiant.
- [ ] Tests de parité rejoués ; aucun écart non classé dans `outil-recette-api/src/test/resources/parite/<module>/rapport.md`.
- [ ] Les écarts volontaires sont documentés dans la spec.
- [ ] Questions ouvertes de la spec : toutes répondues ou explicitement reportées.

## Technique
- [ ] `mvn -f outil-recette-api/pom.xml verify` passe, avec **100 % de couverture** (lignes et branches) et les tests ArchUnit verts.
- [ ] Architecture hexagonale respectée : aucune annotation Spring, JPA ou Jakarta dans `domain`, règles ArchUnit inchangées.
- [ ] Aucune exclusion JaCoCo ajoutée, aucun test sans assertion significative.
- [ ] Écrans construits avec Pollen, aucun composant inventé, catalogue Pollen à jour.
- [ ] `npm --prefix outil-recette-webapp test -- --watch=false` et `npm --prefix outil-recette-webapp run build` passent.
- [ ] Le code respecte `outil-recette-api/api/openapi.yaml` (aucun endpoint ni champ non décrit).
- [ ] Conventions des fichiers `AGENTS.md` (workspace, api, webapp) respectées.
- [ ] Aucun test désactivé ou ignoré pour faire passer la tranche.

## Sécurité
- [ ] Contrôle d'accès sur chaque endpoint, équivalent ou plus strict que le legacy.
- [ ] Requêtes SQL paramétrées uniquement.
- [ ] Aucun secret, mot de passe ou donnée réelle dans le code, les tests ou les docs.
- [ ] Pas de donnée personnelle dans les logs.

## Exploitation
- [ ] Configuration externalisée (variables d'environnement).
- [ ] L'image se construit ; le chart passe `helm lint` / `template` si modifié.

## Traçabilité
- [ ] `outil-recette-api/docs/migration/suivi.md` à jour (écrans, endpoints, statut).
- [ ] `Outil-recette/` non modifié (`git -C Outil-recette status` propre).
- [ ] Revue humaine demandée.
