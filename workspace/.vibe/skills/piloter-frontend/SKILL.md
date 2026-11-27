---
name: piloter-frontend
description: Procédure de l'orchestrateur pour l'étape frontend d'une tranche (E5) : complétion du catalogue Pollen par explorateur-pollen, puis boucle bornée dev-frontend → tests et build → relecteur, 3 itérations maximum par écran. À utiliser par l'orchestrateur pour faire migrer les écrans d'un module dans outil-recette-webapp.
---
# Piloter le frontend (E5)

## 1. Préalable Pollen
1. Liste les besoins d'interface des écrans du plan (champs, listes, dates, tableaux, modales, messages...). Le plan de l'architecte en donne une première liste.
2. Cherche-les dans `outil-recette-webapp/docs/pollen/catalogue.md` (`grep`).
3. Pour les besoins absents, délègue **un seul appel groupé** à `explorateur-pollen`, qui complète lui-même le catalogue.
4. Besoin sans composant Pollen identifié → présente-le à l'humain (solution de repli à valider) avant de migrer l'écran concerné.

## 2. Boucle par écran (3 itérations maximum)
1. **Implémenter** : délègue à `dev-frontend`. Brief type :
   ```
   Module : <module>   Écran : <Outil-recette/.../ecran.jsp>   Itération : <i>/3
   Entrées : docs/specs/<module>.md, api/openapi.yaml (endpoints : ...), docs/plans/<module>.md
   Composants Pollen à utiliser : <lignes du catalogue>
   Critères de fin : npm test et npm run build verts
   Corrections demandées : <liste exacte, ou « aucune »>
   ```
2. **Vérifier toi-même** : `npm --prefix outil-recette-webapp test -- --watch=false` puis `npm --prefix outil-recette-webapp run build`. Note uniquement le nombre et le nom des échecs.
3. **Relire** : délègue à `relecteur` avec l'écran et la sortie de `git -C outil-recette-webapp diff --stat`.
4. **Décider** : vert et relecteur `OK` → écran suivant ; sinon, itération suivante avec la liste exacte des corrections.

## Arrêts
Mêmes règles que `piloter-backend` : non-progrès → arrêt immédiat ; 3 itérations → arrêt ; `BLOQUE` → question à l'humain ; à chaque arrêt, bilan et option recommandée, pas de relance sans accord.
