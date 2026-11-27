# AGENTS.md — outil-recette-webapp (frontend)

Angular 22, avec la bibliothèque de composants maison **Pollen**.

## Pollen : règles d'usage

Pollen est une bibliothèque interne. Les modèles n'en ont **aucune connaissance préalable** :
**ne devinez jamais** un sélecteur, un input, un output ou un nom de module Pollen.

Sources, par ordre de fiabilité :
1. **Les typages du paquet installé** : `outil-recette-webapp/node_modules/PAQUET_POLLEN/`
   (fichiers `.d.ts`, `README`, éventuels docs ou exemples). Ils reflètent la version réellement utilisée.
2. **Le catalogue** : `outil-recette-webapp/docs/pollen/catalogue.md`, généré et tenu à jour avec la
   skill `cataloguer-pollen`.
3. **Le projet de référence** `PROJET_REFERENCE_POLLEN/` (lecture seule) : exemples d'usage réels.

Règles :
- Utiliser un composant Pollen dès qu'il en existe un pour le besoin (bouton, champ, tableau,
  modale, notification, mise en page...). Pas de composant maison qui doublonne Pollen.
- Si aucun composant Pollen ne convient : le signaler dans le plan et proposer une solution ;
  ne pas improviser.
- Tout composant Pollen utilisé pour la première fois est ajouté au catalogue.
- Pas de CSS qui surcharge l'apparence interne de Pollen ; utiliser ses variables ou ses thèmes s'il en a.

## Structure

```
src/app/
├── core/                    services transverses : auth, intercepteurs HTTP, gestion d'erreurs
├── shared/                  composants et pipes réutilisables (au-dessus de Pollen)
└── <module>/                une feature par module fonctionnel
    ├── data-access/         services HTTP typés (générés ou typés depuis le contrat OpenAPI)
    ├── feature/             composants de page (état, appels services)
    ├── ui/                  composants de présentation (inputs / outputs), basés sur Pollen
    └── <module>.routes.ts   routes lazy-loadées
```

## Conventions Angular 22

- Composants **standalone**, `ChangeDetectionStrategy.OnPush`, `inject()`.
- État en **signals** (`signal`, `computed`) ; control flow `@if`, `@for` (avec `track`), `@switch`.
- **Formulaires réactifs typés** ; les validations reproduisent les règles RG-xxx de la spec.
- Les validations front ne remplacent jamais celles de l'API.
- Contrat d'API : `../outil-recette-api/api/openapi.yaml`. Ne jamais appeler un endpoint absent du contrat.
- Erreurs API au format `ProblemDetail`, traduites en messages utilisateur par `core/`.
- Accessibilité : labels associés aux champs, navigation au clavier, messages d'erreur lisibles.
- Chaque composant et service a ses tests unitaires.

## Commandes (depuis `C:\Local\Git\`)

| Action | Commande |
|---|---|
| Installer | `npm --prefix outil-recette-webapp ci` |
| Tests | `npm --prefix outil-recette-webapp test -- --watch=false` |
| Build | `npm --prefix outil-recette-webapp run build` |
| Lint | `npm --prefix outil-recette-webapp run lint` |

## Déploiement

- `Dockerfile` à la racine du repo, chart Helm dans `deploy/helm/outil-recette-webapp/`.

## Git

- Branche par tranche : `migration/<module>`, le même nom que dans `outil-recette-api`.
