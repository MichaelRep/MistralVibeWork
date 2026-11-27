---
name: piloter-backend
description: Procédure de l'orchestrateur pour l'étape backend d'une tranche (E4) : boucle bornée dev-backend → mvn verify → relecteur, 3 itérations maximum par étape du plan, avec détection de non-progrès. À utiliser par l'orchestrateur pour faire implémenter un module dans outil-recette-api.
---
# Piloter le backend (E4)

Pour **chaque étape backend du plan** `outil-recette-api/docs/plans/<module>.md`, dans l'ordre :

## Boucle (3 itérations maximum par étape)
1. **Implémenter** : délègue à `dev-backend`. Brief type :
   ```
   Module : <module>   Étape du plan : <n — titre>   Itération : <i>/3
   Entrées : docs/specs/<module>.md, api/openapi.yaml, docs/plans/<module>.md (étape n)
   Règles RG concernées : <liste>
   Critères de fin : mvn -f outil-recette-api/pom.xml verify vert (ArchUnit + 100 % couverture)
   Corrections demandées : <liste exacte issue de l'itération précédente, ou « aucune »>
   ```
2. **Vérifier toi-même** : `mvn -f outil-recette-api/pom.xml -q verify`. Ne fais pas confiance au seul retour du subagent. Note dans l'état : tests en échec, couverture, violations ArchUnit (noms seulement, pas les traces complètes).
3. **Relire** : délègue à `relecteur` avec le module, l'étape et la sortie de `git -C outil-recette-api diff --stat`.
4. **Décider** :
   - verify vert et relecteur `OK` (aucun point bloquant ni important) → étape suivante ;
   - sinon, construis la liste exacte des corrections (échecs de verify + points bloquants et importants) et passe à l'itération suivante.

## Arrêts
- **Non-progrès** (protocole §3) : même test ou même erreur en échec deux itérations de suite, aucun fichier modifié, mêmes points bloquants → arrêt immédiat.
- **Budget** : 3 itérations sans succès → arrêt.
- `BLOQUE` de `dev-backend` (contrat faux, règle ambiguë) → pose la question à l'humain avant toute nouvelle itération.
- À chaque arrêt : présente à l'humain ce qui passe, ce qui échoue et ton option recommandée. Ne relance pas sans son accord.

## Parallélisme
Pendant cette boucle, seul `dev-backend` écrit dans `outil-recette-api`. La boucle frontend (`piloter-frontend`) peut tourner en parallèle, car elle n'écrit que dans `outil-recette-webapp`.
