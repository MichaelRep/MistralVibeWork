---
name: piloter-analyse
description: Procédure de l'orchestrateur pour l'étape d'analyse d'une tranche (E1 + porte G1) : découpage du module legacy, délégation aux subagents archeologue puis analyste-fonctionnel, tours de questions à l'équipe bornés à 3. À utiliser par l'orchestrateur pour cartographier un module et obtenir une spec validée.
---
# Piloter l'analyse d'un module (E1 → G1)

## 1. Découper
- Repère les points d'entrée du module dans `Outil-recette/` (`WEB-INF/web.xml`, mappings, JSP du module) avec `grep`. **Ne lis pas le code en détail toi-même.**
- Découpe en 1 à 4 parties (par groupe d'écrans ou de servlets). Note le découpage dans le fichier d'état.

## 2. Cartographier (délégation à `archeologue`, une par partie)
Brief type :
```
Module : <module>   Partie : <partie>
Points de départ : <fichiers ou URL>
Périmètre : <ce qui est inclus / exclu>
Livrable : outil-recette-api/docs/legacy/<module>/<partie>.md (template de cartographier-module-legacy)
Critère de fin : toutes les URL et JSP du périmètre cartographiées, sources fichier:ligne.
```
- Les parties sont indépendantes : elles peuvent tourner 2 par 2.
- `ECHEC` ou `BLOQUE` sur une partie → relance une fois avec un brief précisé, puis remonte à l'humain.

## 3. Rédiger la spec (délégation à `analyste-fonctionnel`)
Brief : module, liste des fichiers partiels, réponses de l'équipe déjà obtenues (verbatim).

## 4. Porte G1 (toi + humain), 3 tours maximum
- Présente les `QUESTIONS` par lots de 5, avec la compréhension proposée : l'humain valide ou corrige.
- Note les réponses telles quelles dans le fichier d'état.
- Relance `analyste-fonctionnel` avec les réponses. Incrémente le compteur « Tours de questions ».
- Au 3e tour, s'il reste des questions : propose à l'humain de figer la spec avec ces questions **reportées** (elles bloqueront seulement les règles concernées) ou d'organiser un atelier.
- G1 est franchie seulement quand l'humain dit explicitement que la spec est validée.
