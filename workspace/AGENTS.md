# AGENTS.md — Espace de travail « Refonte de l'outil de recette »

> Installé dans `C:\Local\Git\`, à côté des trois repos. **Lancez toujours `vibe` depuis
> `C:\Local\Git\`** pour que les agents voient les trois repos et chargent `.vibe/`.
> Chaque repo cible a aussi son propre `AGENTS.md` (conventions back / front), chargé
> automatiquement dès qu'un agent lit des fichiers de ce repo.
> **Tenez ces fichiers à jour** : quand un agent répète une erreur, ajoutez la règle.

## Contexte

Nous refondons l'application **outil de recette**, écrite en Java / JSP et **sans documentation**,
vers :

- **Backend** : Java 21, Spring Boot, **architecture hexagonale**, **100 % de couverture de tests**,
  API REST décrite en OpenAPI.
- **Frontend** : Angular 22, avec la bibliothèque de composants maison **Pollen**.
- **Déploiement** : images Docker, Kubernetes (Helm).

La connaissance fonctionnelle est détenue par l'équipe : **n'inventez aucune règle métier**.
En cas de doute, posez la question à l'humain ou ajoutez-la aux « Questions ouvertes » de la spec.

## Les trois repos (chemins relatifs à `C:\Local\Git\`)

| Repo | Rôle | Droits des agents |
|---|---|---|
| `Outil-recette/` | Application legacy Java/JSP | **LECTURE SEULE**, c'est la référence du comportement |
| `outil-recette-api/` | Backend cible Java 21 / Spring Boot | Lecture / écriture |
| `outil-recette-webapp/` | Frontend cible Angular 22 + Pollen | Lecture / écriture |
| `PROJET_REFERENCE_POLLEN/` | Projet existant qui utilise Pollen, sert d'exemple | **LECTURE SEULE** |

## Où se trouvent les artefacts partagés

Tout ce qui est transverse est versionné dans **`outil-recette-api/`** :

```
outil-recette-api/api/openapi.yaml     Contrat d'API : source de vérité entre back et front
outil-recette-api/docs/legacy/         Cartographie du legacy (un fichier par module)
outil-recette-api/docs/specs/          Spécifications fonctionnelles validées (règles RG-xxx)
outil-recette-api/docs/adr/            Décisions d'architecture
outil-recette-api/docs/plans/          Plans de travail par tranche
outil-recette-api/docs/migration/suivi.md   Suivi de la migration
outil-recette-webapp/docs/pollen/catalogue.md   Catalogue des composants Pollen
```

## Règles absolues

1. **Ne jamais modifier `Outil-recette/` ni `PROJET_REFERENCE_POLLEN/`.**
2. **Chaque règle métier a un identifiant `RG-<MODULE>-<NNN>` et cite sa source**
   (`Outil-recette/chemin/Fichier.java:123`) ou « validé par l'équipe le AAAA-MM-JJ ».
3. **Pas de code sans plan validé** : chaque tranche a un plan dans `outil-recette-api/docs/plans/`,
   validé par un humain avant l'implémentation.
4. **Le contrat OpenAPI est modifié avant le code**, jamais après coup.
5. **Une tranche n'est terminée que si** `mvn verify` passe (couverture à 100 % comprise), les tests
   et le build du front passent, la parité est vérifiée et la skill `checklist-migration` est remplie.
6. **Aucun secret ni donnée de production non anonymisée** dans le code, les tests, les docs ou les prompts.
7. **Aucune action distante** : pas de `git push`, `docker push`, `kubectl apply`, `helm install/upgrade`.
   Ces actions sont faites par un humain.
8. Une même tranche utilise le même nom de branche dans les deux repos cibles : `migration/<module>`.

## Commandes (à lancer depuis `C:\Local\Git\`)

| Action | Commande |
|---|---|
| Build + tests + couverture backend | `mvn -f outil-recette-api/pom.xml verify` |
| Tests backend rapides | `mvn -f outil-recette-api/pom.xml test` |
| Rapport de couverture | `mvn -f outil-recette-api/pom.xml verify` puis `outil-recette-api/target/site/jacoco/jacoco.csv` |
| Installer le front | `npm --prefix outil-recette-webapp ci` |
| Tests front | `npm --prefix outil-recette-webapp test -- --watch=false` |
| Build front | `npm --prefix outil-recette-webapp run build` |
| Lint front | `npm --prefix outil-recette-webapp run lint` |
| État Git d'un repo | `git -C outil-recette-api status` / `git -C outil-recette-webapp status` |

> Complétez ce tableau avec les commandes du legacy (build, démarrage local) si elles servent
> aux tests de caractérisation.

## Où trouver quoi

- Conventions backend : `outil-recette-api/AGENTS.md`
- Conventions frontend et Pollen : `outil-recette-webapp/AGENTS.md`
- Procédures détaillées : `.vibe/skills/` (invocables par `/<nom-skill>`)
- Rôles spécialisés : `.vibe/agents/`. Un seul agent se lance, l'**orchestrateur** (agent par défaut) ;
  tous les autres sont des subagents qu'il délègue selon la skill `protocole-orchestration`.
- État d'une tranche en cours : `outil-recette-api/docs/migration/etat/<module>.md`.
