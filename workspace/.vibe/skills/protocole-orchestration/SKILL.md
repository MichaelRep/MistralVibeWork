---
name: protocole-orchestration
description: Règles communes de délégation entre l'orchestrateur et ses subagents pour la refonte : délégation sur un seul niveau, budgets de boucles, détection de non-progrès, format de retour obligatoire, fichier d'état, un seul écrivain par repo. À appliquer par l'orchestrateur avant chaque délégation et par tout subagent avant de rendre son résultat.
---
# Protocole d'orchestration

## 1. Un seul niveau de délégation

Dans Vibe, **un subagent ne peut pas lancer de subagent**. L'organisation est donc en étoile :

```
                         orchestrateur  (seul agent lancé, seul à parler à l'humain)
   ┌──────────┬──────────┬───────┼────────┬───────────┬──────────┬─────────┬────────┐
archeologue analyste  architecte qa-parite dev-backend dev-frontend explorateur relecteur devops
            fonctionnel                                            -pollen
```

- La logique de coordination (boucles, vérifications, relectures) est portée par **l'orchestrateur**, au moyen
  des skills `piloter-analyse`, `piloter-backend` et `piloter-frontend`.
- Les subagents sont des **exécutants** : ils font une tâche, écrivent leurs livrables sur disque et rendent
  un retour court. Ils ne délèguent jamais et ne parlent jamais à l'humain.
- **Les livrables passent par des fichiers, pas par l'orchestrateur** : un subagent écrit sur disque,
  le suivant relit sur disque. Le contexte de l'orchestrateur reste ainsi léger.

## 2. Budgets (bornes de boucles)

Tous les compteurs sont tenus par l'orchestrateur dans le fichier d'état.

| Boucle | Maximum | Au-delà |
|---|---|---|
| Tours de questions à l'équipe (G1) | 3 | Spec figée avec questions reportées, ou atelier : décision humaine |
| Itérations dev-backend → verify → relecteur, par étape du plan | 3 | Arrêt, bilan à l'humain |
| Itérations dev-frontend → tests/build → relecteur, par écran | 3 | Arrêt, bilan à l'humain |
| Tentatives d'un subagent pour corriger un même échec | 3 | Le subagent rend `ECHEC` |
| Relance d'un subagent en `ECHEC` avec un brief précisé | 1 | Décision humaine |
| Retours parité → dev | 2 | Décision humaine |
| Délégations par tranche | 40 | Arrêt, bilan à l'humain |
| Subagents simultanés | 2 (config) | File d'attente |

## 3. Détection de non-progrès

L'orchestrateur arrête une boucle immédiatement, sans attendre la fin du budget, si :
- le **même** test ou la **même** erreur échoue deux itérations de suite ;
- une itération ne modifie aucun fichier ;
- le relecteur renvoie deux fois de suite les mêmes points bloquants ;
- la couverture ne progresse pas entre deux itérations.

## 4. Aucun subagent n'attend l'humain

Un subagent ne peut pas poser de question ni obtenir d'approbation. Tout besoin humain (règle métier
ambiguë, choix d'architecture, commande refusée) donne un retour `BLOQUE` avec la question dans
`QUESTIONS`. **Seul l'orchestrateur pose les questions**, puis relance avec les réponses.
Les commandes hors liste autorisée sont refusées d'office (`permission = "never"`) : ne pas les retenter, les signaler.

## 5. Brief d'une délégation (orchestrateur)

Le subagent ne voit pas la conversation. Chaque brief est **autonome** et contient : module, objectif,
fichiers d'entrée, livrable attendu (chemin), critères de fin, itération courante / maximum,
corrections demandées, réponses de l'équipe utiles (verbatim).

## 6. Format de retour obligatoire (tout subagent)

Le dernier message d'un subagent est **exactement** ce bloc, sans préambule, et fait moins de 40 lignes.
Le détail va dans des fichiers, pas dans le retour.

```
STATUT: OK | A_CORRIGER | BLOQUE | ECHEC
AGENT: <nom>   MODULE: <module>   ITERATION: <i>/<max>
RESUME:
- <5 à 10 puces factuelles>
FICHIERS:
- <chemin> (créé | modifié)
VERIFICATIONS:
- <commande> → <résultat : OK, ou nombre d'échecs>
QUESTIONS:
- <question pour l'équipe, avec ta compréhension proposée>   (ou « aucune »)
SUITE_PROPOSEE: <prochaine étape>
```

- `OK` : objectif atteint et vérifié.
- `A_CORRIGER` : livrable produit, mais des points restent (listés).
- `BLOQUE` : décision humaine nécessaire.
- `ECHEC` : livrable impossible (prérequis absent, échec persistant après 3 tentatives).

Un retour qui ne respecte pas ce format est traité comme `ECHEC`.

## 7. Fichier d'état

Chaque tranche a un fichier `outil-recette-api/docs/migration/etat/<module>.md` (modèle : `_modele.md`).
- **Seul l'orchestrateur l'écrit**, après chaque retour de subagent.
- Il contient l'étape courante, les compteurs, les portes franchies, les questions et l'historique.
- Une session interrompue reprend en relisant ce fichier : ne jamais refaire une étape terminée.

## 8. Un seul écrivain par repo

Deux subagents n'écrivent jamais dans le même repo en même temps. Seuls `dev-backend`
(outil-recette-api) et `dev-frontend` (outil-recette-webapp) peuvent tourner en parallèle, une fois le
contrat OpenAPI validé. Les subagents en lecture seule (`archeologue`, `relecteur`) peuvent tourner à côté.
