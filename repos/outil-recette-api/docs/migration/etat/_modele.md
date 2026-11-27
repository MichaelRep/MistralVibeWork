# État de la tranche : <module>

> Écrit uniquement par l'orchestrateur. Permet de reprendre une session interrompue.

- **Branche** : `migration/<module>` (outil-recette-api et outil-recette-webapp)
- **Étape courante** : E1 cartographie
- **Statut** : en cours | bloqué | terminé

## Étapes

| # | Étape | Subagents | Statut | Livrable |
|---|---|---|---|---|
| E1 | Cartographie + projet de spec | archeologue, analyste-fonctionnel | ⬜ | `docs/legacy/<module>.md`, `docs/specs/<module>.md` |
| G1 | **Porte humaine : spec validée** | orchestrateur | ⬜ | |
| E2 | Contrat OpenAPI + ADR + plan | architecte | ⬜ | `api/openapi.yaml`, `docs/plans/<module>.md` |
| G2 | **Porte humaine : plan validé** | orchestrateur | ⬜ | |
| E3 | Caractérisation du legacy | qa-parite | ⬜ | `src/test/resources/parite/<module>/` |
| E4 | Backend (boucle bornée) | dev-backend, relecteur | ⬜ | code + tests, `mvn verify` |
| E5 | Frontend (boucle bornée) | explorateur-pollen, dev-frontend, relecteur | ⬜ | code + tests, build |
| E6 | Rejeu de la parité | qa-parite | ⬜ | `parite/<module>/rapport.md` |
| E7 | Docker + Helm (si nécessaire) | devops | ⬜ | Dockerfile, chart |
| G3 | **Porte humaine : revue finale et fusion** | orchestrateur | ⬜ | |

Légende : ⬜ à faire · 🟡 en cours · ✅ terminé · ⛔ bloqué

## Budgets

| Compteur | Utilisé | Maximum |
|---|---|---|
| Délégations | 0 | 40 |
| Itérations backend (étape en cours) | 0 | 3 |
| Itérations frontend (écran en cours) | 0 | 3 |
| Tours de questions (G1) | 0 | 3 |
| Retours parité → backend | 0 | 2 |

## Questions en attente pour l'équipe

| # | Question | Posée le | Réponse |
|---|---|---|---|

## Historique

| Date | Agent | Statut | Résumé |
|---|---|---|---|
