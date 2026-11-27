---
name: rediger-adr
description: Rédige un ADR (Architecture Decision Record) dans outil-recette-api/docs/adr/ avec contexte, options comparées, décision et conséquences. À utiliser pour documenter ou proposer une décision d'architecture ou technique.
---
# Rédiger un ADR

## Fichier
`outil-recette-api/docs/adr/NNNN-<titre-en-kebab-case>.md` : numéro suivant le dernier ADR existant, jamais réutilisé.

## Template
```markdown
# NNNN — <Titre de la décision>

- **Statut** : Proposé | Accepté | Remplacé par NNNN | Abandonné
- **Date** : AAAA-MM-JJ
- **Décideurs** : <noms ou rôles>

## Contexte
Le problème, les contraintes (techniques, équipe, plateforme, délais), ce qui existe dans le legacy.

## Options envisagées
### Option A — <nom>
Avantages / Inconvénients / Coût / Risques
### Option B — <nom>
...

## Décision
L'option retenue et **pourquoi**.

## Conséquences
Ce que cela implique (positif et négatif), ce qu'il faudra faire, ce qui devient plus difficile.
```

## Règles
- Au moins deux options réelles.
- Le statut reste « Proposé » tant qu'un humain n'a pas validé.
- Un ADR accepté ne se modifie pas : on en écrit un nouveau qui le remplace.

## Sujets d'ADR attendus pour la refonte
Stratégie de cohabitation legacy / nouvelle appli (big bang ou migration progressive avec routage), authentification (SSO de l'entreprise), base de données (conservée ou nouvelle, reprise des données), génération des clients HTTP depuis OpenAPI, observabilité (logs, métriques, traces), découpage du chart Helm.
