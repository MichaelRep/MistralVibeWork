---
name: atteindre-couverture-100
description: Analyse le rapport JaCoCo de outil-recette-api et écrit les tests manquants pour atteindre 100 % de couverture des lignes et des branches, avec des tests utiles (assertions significatives, règles RG-xxx). Configure aussi la règle JaCoCo si elle manque. À utiliser quand mvn verify échoue sur la couverture ou pour combler des trous de tests.
---
# Atteindre 100 % de couverture (utile)

## Configuration attendue (`outil-recette-api/pom.xml`)
- Plugin `jacoco-maven-plugin` : `prepare-agent`, `report` et `check` liés à `verify`.
- Règle `check` : élément `BUNDLE`, compteurs `LINE` et `BRANCH`, `COVEREDRATIO` minimum `1.00`.
- Exclusions limitées à `**/OutilRecetteApplication.class` et au code généré. Toute autre exclusion exige un ADR.

## Méthode
1. Lancer `mvn -f outil-recette-api/pom.xml verify`.
2. Lire `outil-recette-api/target/site/jacoco/jacoco.csv` : lister les classes avec `LINE_MISSED > 0` ou `BRANCH_MISSED > 0`, triées par nombre de manques.
3. Pour le détail ligne par ligne, lire `outil-recette-api/target/site/jacoco/jacoco.xml` (éléments `<line nr=... mi=... mb=...>`).
4. Pour chaque manque, se demander **quel comportement** n'est pas testé, puis écrire le test au bon niveau :
   | Code non couvert | Test à écrire |
   |---|---|
   | Branche d'une règle dans `domain.service` | Test unitaire nommé d'après la règle (`RG-...`) |
   | Invariant d'un modèle (constructeur qui lève une exception) | Test unitaire du modèle, cas valide et invalide |
   | Gestion d'erreur d'un controller | `@WebMvcTest` vérifiant le code HTTP et le `ProblemDetail` |
   | Mapper | Test aller-retour avec tous les champs, y compris `null` et optionnels |
   | Adapter de persistance | `@DataJpaTest` + Testcontainers, cas « trouvé » et « non trouvé » |
5. Relancer `verify` jusqu'à 100 %.

## Si une ligne semble impossible à couvrir
C'est souvent du **code mort** ou une **branche défensive inutile** : proposer de la supprimer plutôt que d'écrire un test artificiel. Le signaler à l'humain.

## Interdits
- Test sans assertion, ou qui ne vérifie qu'un appel sans regarder le résultat.
- Tester des getters ou `toString` générés juste pour la couverture : si un record n'est pas couvert, c'est qu'un comportement qui l'utilise n'est pas testé.
- Ajouter une exclusion JaCoCo, `@Generated` ou un `// NOSONAR` pour masquer un manque.
- Baisser le seuil.

## Recommandé
Tests de mutation PIT (`pitest-maven`) sur `..domain..` pour vérifier que les tests détectent réellement les erreurs. Une couverture à 100 % avec un faible score de mutation signale des tests creux.
