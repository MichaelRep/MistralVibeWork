---
name: deployer-k8s
description: Crée ou révise le chart Helm de outil-recette-api ou de outil-recette-webapp (Deployment, Service, Ingress, ConfigMap, références aux Secrets, probes Actuator, ressources, HPA) et le valide avec helm lint, helm template et un dry-run, sans jamais déployer. À utiliser pour préparer un déploiement Kubernetes.
---
# Préparer le déploiement Kubernetes

Un chart par repo :
- `outil-recette-api/deploy/helm/outil-recette-api/`
- `outil-recette-webapp/deploy/helm/outil-recette-webapp/`

## Structure d'un chart
```
Chart.yaml
values.yaml               valeurs par défaut (sans secret)
values-recette.yaml       surcharges par environnement
values-prod.yaml
templates/
  deployment.yaml  service.yaml  ingress.yaml  configmap.yaml
  hpa.yaml  pdb.yaml  serviceaccount.yaml
```

## Exigences
- **Probes** (api) : `livenessProbe` → `/actuator/health/liveness`, `readinessProbe` → `/actuator/health/readiness`, `startupProbe` pour les démarrages lents. (webapp) : probe HTTP sur `/`.
- **Ressources** : `requests` et `limits` définis pour chaque conteneur.
- **Sécurité** : `runAsNonRoot: true`, `readOnlyRootFilesystem: true` (+ volume `emptyDir` pour `/tmp`), `allowPrivilegeEscalation: false`, capabilities supprimées.
- **Configuration** : ConfigMap pour le non-sensible ; Secrets **référencés** (`secretKeyRef`), jamais leur valeur dans le repo. Utiliser le mécanisme de l'entreprise (External Secrets, Vault, Sealed Secrets) s'il existe.
- **Image** : `repository` et `tag` paramétrables, pas de `latest`.
- **Disponibilité** : `replicas` ≥ 2 en prod, `PodDisruptionBudget`, arrêt gracieux (`server.shutdown=graceful` côté Spring).
- **Ingress** : classe et annotations selon la plateforme de l'entreprise, TLS. La webapp et l'api partagent le même hôte si possible (`/` et `/api`) pour éviter le CORS.

## Validation (obligatoire)
```
helm lint outil-recette-api/deploy/helm/outil-recette-api
helm template outil-recette-api outil-recette-api/deploy/helm/outil-recette-api -f outil-recette-api/deploy/helm/outil-recette-api/values-recette.yaml
```
Puis `kubectl apply --dry-run=client -f <rendu>`. Même chose pour la webapp.

## Règles
- **Jamais** de `helm install/upgrade`, de `kubectl apply` réel ni de `kubectl delete` : fournir les commandes à l'humain.
- Si les contraintes de la plateforme (registry, ingress class, namespaces, politique réseau) sont inconnues, les demander.
