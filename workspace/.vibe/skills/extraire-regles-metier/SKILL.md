---
name: extraire-regles-metier
description: Extrait les règles métier du code legacy (validations, calculs, statuts, droits, workflows) au format RG-<MODULE>-<NNN> sourcé, avec niveau de confiance et questions pour l'équipe, dans outil-recette-api/docs/specs/<module>.md. À utiliser pour rédiger une spécification fonctionnelle à partir du code.
---
# Extraire les règles métier

## Où chercher
- **Validations** : tests sur les champs (Java, JavaScript des JSP, taglibs), contraintes SQL (`NOT NULL`, `CHECK`, clés uniques).
- **Calculs** : montants, dates, compteurs, agrégats, arrondis.
- **États et workflows** : colonnes statut, `switch` / `if` sur un statut, transitions autorisées.
- **Droits** : tests de profil, de rôle, de propriétaire, menus conditionnels dans les JSP.
- **Effets de bord** : mails, historisation, exports, appels externes, suppressions en cascade.
- **Messages** : textes d'erreur et de confirmation (fichiers `.properties`, JSP).

## Format d'une règle

```markdown
### RG-<MODULE>-<NNN> — <titre court en langage métier>
- **Règle** : <énoncé compréhensible par un testeur>
- **Déclencheur** : <écran / action / batch>
- **Source** : `Outil-recette/chemin/Fichier.java:123` (+ autres sources)
- **Confiance** : Haute (code explicite) | Moyenne (déduite) | Basse (supposée)
- **Statut** : À valider | Validée (équipe, AAAA-MM-JJ) | Corrigée | Bug legacy — à reproduire ?
- **Exemples** : <entrée> → <résultat attendu>
```

## Template de la spec (`outil-recette-api/docs/specs/<module>.md`)

```markdown
# Spécification — <module>
## Objectif du module
## Acteurs et droits
## Cas d'usage
### CU-<MODULE>-01 — <titre>
Acteur, déclencheur, scénario nominal, variantes, erreurs, règles liées (RG-...)
## Règles métier
## Données manipulées (vue métier)
## Questions ouvertes
| # | Question | Ma compréhension | Réponse équipe |
## Écarts volontaires par rapport au legacy
```

## Règles
- Numérotation stable : ne jamais renuméroter une règle existante.
- Une règle = un comportement testable.
- Si un comportement semble être un bug, le marquer comme tel : c'est l'équipe qui décide de le reproduire ou non.
- Toute règle de confiance Moyenne ou Basse génère une question ouverte.
