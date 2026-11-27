---
name: ecrire-test-caracterisation
description: Écrit des tests de caractérisation (golden master) qui figent le comportement de l'application legacy, puis les rejoue sur la nouvelle API pour mesurer la parité. À utiliser avant de migrer un module, ou pour vérifier une non-régression legacy / nouvelle application.
---
# Tests de caractérisation et de parité

Principe : on ne juge pas le legacy, on **enregistre ce qu'il fait** et on vérifie que la nouvelle appli fait pareil (sauf écarts validés).

## Étapes

1. **Choisir les scénarios** à partir de `outil-recette-api/docs/specs/<module>.md` :
   - un scénario nominal par cas d'usage ;
   - au moins un scénario par règle RG-xxx ;
   - erreurs de saisie, droits insuffisants, cas limites (vide, max, caractères spéciaux, accents, dates limites, fuseaux).

2. **Préparer des données de référence** : jeu de données synthétique ou anonymisé, scripts SQL dans `outil-recette-api/src/test/resources/parite/<module>/donnees/`. Jamais de données de production brutes.

3. **Capturer le legacy** : pour chaque scénario, enregistrer dans `outil-recette-api/src/test/resources/parite/<module>/scenarios/<id>.yaml` :
   ```yaml
   id: CU-<MODULE>-01-nominal
   regles: [RG-<MODULE>-001, RG-<MODULE>-004]
   legacy:
     requete: { methode: POST, url: /recette/xxx.do, params: {...} }
     attendu:
       http: 200
       ecran: <éléments clés extraits du HTML : messages, valeurs affichées>
       base: <état des tables après l'action, requête de vérification>
   cible:
     requete: { methode: POST, url: /api/xxx, corps: {...} }
     correspondance: <comment comparer les champs legacy et cible>
   ```
   - Pour le HTML, extraire uniquement les éléments **fonctionnels** (valeurs, messages, lignes de tableau) : pas de comparaison de mise en page.
   - L'état de la base est souvent la comparaison la plus fiable.

4. **Automatiser le rejeu** : un test (JUnit + RestAssured côté backend, ou script) qui charge les données, appelle la nouvelle API et compare au résultat attendu.

5. **Rapport d'écarts** `outil-recette-api/src/test/resources/parite/<module>/rapport.md` :
   | Scénario | Résultat | Écart | Classement (régression / attendu / bug legacy corrigé) | Décision |

## Règles
- Environnements locaux ou de recette uniquement.
- Un écart non classé bloque la tranche.
- Un écart « attendu » doit être référencé dans la section « Écarts volontaires » de la spec.
