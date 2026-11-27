---
name: dockeriser-service
description: Crée ou révise le Dockerfile de outil-recette-api (Java 21 / Spring Boot) ou de outil-recette-webapp (Angular) : multi-stage, non-root, image minimale, healthcheck, validé par un docker build local. À utiliser pour dockeriser, conteneuriser ou créer une image.
---
# Dockeriser un service

## Backend (`outil-recette-api/Dockerfile`)
- Étape build : image Maven + JDK 21 (version épinglée), cache des dépendances (`mvn dependency:go-offline` avant la copie des sources), `mvn -DskipTests package` (les tests et la couverture tournent en CI, pas dans l'image).
- Extraction des couches Spring Boot (`java -Djarmode=tools -jar app.jar extract --layers`) pour un meilleur cache.
- Étape run : JRE 21 minimale (version épinglée ; image de base validée par l'entreprise si elle existe), utilisateur non-root (`USER 1001`), `EXPOSE 8080`.
- JVM adaptée aux conteneurs : `-XX:MaxRAMPercentage=75`, pas de `-Xmx` en dur.
- Aucun secret ni configuration d'environnement dans l'image : tout passe par des variables d'environnement.

## Frontend (`outil-recette-webapp/Dockerfile`)
- Étape build : Node LTS épinglée, `npm ci` (le registry interne qui sert Pollen doit être accessible : `.npmrc` sans jeton en clair, jeton passé en secret de build), `npm run build`.
- Étape run : serveur statique non-root (par exemple nginx unprivileged) sur un port > 1024, fallback SPA vers `index.html`, en-têtes de cache (assets hashés longs, `index.html` sans cache), en-têtes de sécurité.
- URL de l'API configurable à l'exécution (fichier de config chargé au démarrage ou reverse proxy), pas figée au build.

## Commun
- `.dockerignore` : `node_modules`, `target`, `.git`, fichiers d'environnement, `.npmrc` contenant un jeton.
- Labels OCI (`org.opencontainers.image.source`, `version`).
- Valider : `docker build -t outil-recette-api:dev outil-recette-api` (ou webapp), puis `docker run --rm -p 8080:8080 ...` et vérifier le healthcheck.

## Règles
- Ne jamais faire `docker push` ni `docker login` : c'est la CI ou l'humain.
