---
name: cataloguer-pollen
description: Construit ou complète le catalogue des composants de la bibliothèque maison Pollen (outil-recette-webapp/docs/pollen/catalogue.md) à partir des typages installés dans node_modules et des usages du projet de référence, pour que les agents n'inventent jamais un composant. À utiliser avant de migrer des écrans, ou quand un composant Pollen est nécessaire mais absent du catalogue.
---
# Cataloguer les composants Pollen

Pollen est une bibliothèque interne inconnue des modèles. Ce catalogue est la **mémoire** des
agents sur Pollen : il doit être exact, sourcé et relu par l'équipe.

## Sources, par ordre de fiabilité
1. **Le paquet installé** : `outil-recette-webapp/node_modules/PAQUET_POLLEN/`
   - `package.json` : version, points d'entrée (`exports`).
   - `*.d.ts` : composants (`ɵcmp` / `ComponentDeclaration` donnent le sélecteur, les inputs et les outputs), directives, services, tokens d'injection.
   - `README.md`, dossiers `docs/` ou `examples/` s'ils existent.
   - Si `node_modules` est absent : demander à l'humain de lancer `npm --prefix outil-recette-webapp ci`.
2. **Le projet de référence** `PROJET_REFERENCE_POLLEN/` (lecture seule) :
   - Chercher les imports du paquet (`from 'PAQUET_POLLEN`), les sélecteurs dans les templates `.html`, la configuration dans `app.config.ts` ou `main.ts`, les styles et thèmes importés.
   - Relever des **exemples réels** courts avec leur source `fichier:ligne`.
3. Ce qui n'est confirmé par aucune source est marqué « Non vérifié ».

## Étapes
1. Noter la version de Pollen installée en tête du catalogue.
2. Remplir « Import et configuration » : providers, thème et styles globaux requis.
3. Pour chaque composant utile à la migration, remplir une ligne du tableau « Composants » : besoin, sélecteur, import, inputs et outputs principaux, source.
4. Ajouter 1 ou 2 exemples par composant fréquent (formulaire, champ texte, liste déroulante, date, tableau avec tri et pagination, bouton, modale, message, onglets, fil d'Ariane).
5. Remplir « Équivalences JSP → Pollen ».
6. Noter dans « Manques connus » les besoins sans composant Pollen.
7. Demander à l'humain de relire les entrées marquées « Non vérifié ».

## Mode incrémental
Quand un seul composant manque : ne traiter que celui-là, et l'ajouter au catalogue sans réécrire le reste.

## Règles
- Ne jamais modifier `PROJET_REFERENCE_POLLEN/` ni `node_modules/`.
- Ne pas copier de gros blocs du projet de référence : des extraits courts et sourcés suffisent.
- Ne pas recopier de logique métier du projet de référence : seulement l'usage de Pollen.
