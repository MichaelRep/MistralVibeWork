---
name: migrer-ecran-jsp
description: Migre un écran JSP legacy vers un composant Angular 22 standalone dans outil-recette-webapp, construit avec les composants Pollen (signals, formulaires réactifs typés, service HTTP typé, route), branché sur l'API REST, avec tests. À utiliser pour migrer, convertir ou refaire un écran JSP en Angular.
---
# Migrer un écran JSP vers Angular 22 + Pollen

## Prérequis
- Spec validée `outil-recette-api/docs/specs/<module>.md` et endpoints présents dans `outil-recette-api/api/openapi.yaml`.
- Catalogue `outil-recette-webapp/docs/pollen/catalogue.md` existant. S'il est vide ou si un besoin n'y figure pas, appliquer d'abord la skill `cataloguer-pollen`.

## Étapes

1. **Inventaire de la JSP** (`Outil-recette/...`) : champs (type, obligatoire, format), listes déroulantes et leur source, tableaux (colonnes, tri, pagination), boutons et actions, messages, éléments affichés selon les droits, JavaScript embarqué.
2. **Associer les règles** : pour chaque RG-xxx de l'écran, décider : validation front + back, ou back seulement.
3. **Choisir les composants Pollen** : pour chaque élément de l'inventaire, trouver l'équivalent dans le catalogue (section « Équivalences JSP → Pollen »). Écrire ce tableau dans le plan **avant** de coder. Un élément sans équivalent est signalé, pas improvisé.
4. **Structure** (`outil-recette-webapp/src/app/<module>/`) :
   - `data-access/<ressource>.service.ts` : appels HTTP typés depuis le contrat OpenAPI.
   - `feature/<ecran>.component.ts` : composant de page (état en signals, appels service).
   - `ui/` : composants de présentation (inputs / outputs) assemblant des composants Pollen.
   - `<module>.routes.ts` : route lazy-loadée, guard de droits si nécessaire.
5. **Correspondances JSP → Angular** :
   | JSP | Angular |
   |---|---|
   | `<form action>` + rechargement de page | formulaire réactif + appel HTTP, champs Pollen |
   | `<c:if>` / `<c:choose>` | `@if` / `@switch` |
   | `<c:forEach>` | `@for (x of liste(); track x.id)` ou tableau Pollen |
   | `<fmt:formatDate>` / `<fmt:formatNumber>` | pipes `date` / `number` avec la locale `fr` |
   | Attribut de session | état dans un service à signals ou donnée renvoyée par l'API |
   | Message en attribut de requête | erreurs `ProblemDetail` → composant de message Pollen |
   | `confirm()` JavaScript | modale de confirmation Pollen |
   | Taglib maison | composant `ui/` basé sur Pollen |
6. **Composant** : `standalone`, `ChangeDetectionStrategy.OnPush`, `inject()`, `signal` / `computed`, formulaires réactifs typés, messages d'erreur par champ. Imports Pollen exactement comme indiqué dans le catalogue.
7. **Tests** : rendu des champs, validations RG-xxx, appel du service, affichage des erreurs API.
8. **Vérifier** : `npm --prefix outil-recette-webapp test -- --watch=false`, `npm --prefix outil-recette-webapp run build`, puis vérification manuelle avec l'humain.
9. **Tracer** : ajouter la ligne `<ecran>.jsp → <composant>` dans `outil-recette-api/docs/migration/suivi.md`, et tout nouveau composant Pollen utilisé dans le catalogue.

## Interdits
- Ne jamais deviner un sélecteur, un input ou un import Pollen : vérifier dans `node_modules` ou le projet de référence.
- Ne pas inventer de règle absente de la spec : poser la question.
- Pas de logique métier uniquement côté front.
