---
name: cartographier-module-legacy
description: Cartographie un module de l'application legacy Java/JSP (points d'entrée, JSP, servlets, services, DAO, SQL, tables, dépendances) et produit outil-recette-api/docs/legacy/<module>.md avec des références fichier:ligne. À utiliser pour comprendre, explorer, documenter ou rétro-documenter du code legacy avant une migration.
---
# Cartographier un module legacy

Objectif : obtenir une vue **factuelle et sourcée** d'un module, sans rien modifier.

## Étapes

1. **Points d'entrée**
   - Lire `WEB-INF/web.xml` (servlets, filtres, listeners, mappings d'URL, `welcome-file`, `error-page`).
   - Chercher les frameworks : `struts-config.xml`, `*-servlet.xml` (Spring MVC), annotations `@WebServlet`, `faces-config.xml`.
   - Lister les URL du module et la classe ou JSP qui traite chacune.

2. **Écrans (JSP)**
   - Pour chaque JSP : formulaires (`<form action=... method=...>`), champs (nom, type, obligatoire), boutons et actions, `include`, taglibs (JSTL, taglibs maison), JavaScript embarqué.
   - Repérer les **scriptlets** `<% ... %>` contenant de la logique (calculs, accès base, tests de droits) : ce sont des règles métier cachées.

3. **Traitements**
   - Suivre chaque action : servlet/action → service → DAO.
   - Noter les attributs de session et de requête lus ou écrits (`session.getAttribute`, `request.setAttribute`).
   - Noter les contrôles de droits et de profils.

4. **Données**
   - Lister les requêtes SQL (JDBC, `PreparedStatement`, SQL concaténé, procédures stockées, fichiers de requêtes).
   - Déduire les tables, colonnes, jointures et transactions. Signaler le **SQL dynamique** et les risques d'injection.

5. **Dépendances**
   - Appels externes (web services, LDAP, mail, fichiers, batchs, files de messages), bibliothèques maison, configuration (`.properties`, JNDI).

6. **Qualité et risques**
   - Code mort, doublons, `catch` vides, gestion des erreurs, encodage, formats de dates, gestion des transactions.

## Template de sortie (`outil-recette-api/docs/legacy/<module>.md`)

```markdown
# Module <nom> — cartographie legacy
_Généré le AAAA-MM-JJ, à valider par l'équipe._

## Résumé (5 lignes max)

## Points d'entrée
| URL | Méthode | Classe / JSP | Source |

## Écrans
### <ecran>.jsp (`Outil-recette/...:l`)
- Champs : | nom | type | obligatoire | validation | source |
- Actions : | bouton | URL cible | effet |
- Logique dans la JSP : ...

## Flux de traitement
<URL> → <Servlet> → <Service> → <DAO> (avec sources)

## Données
| Table | Colonnes utilisées | Lecture/Écriture | Requête (source) |

## Session et droits
## Dépendances externes
## Règles métier repérées (à détailler avec extraire-regles-metier)
## Risques et points d'attention
## Hypothèses (non vérifiées dans le code)
```

## Règles
- Toujours citer `chemin:ligne`. Pas de source, pas d'affirmation : passer en « Hypothèse ».
- Ne rien modifier dans `Outil-recette/`.
- Pour un gros module, découper par sous-partie et fusionner les synthèses.
