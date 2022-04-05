These are just a couple of scripts to generate static API json files from OpenAPI to validate some of our yaml files in CI without
installing a cluster.

Look at the `create-schemas.sh` for how to install openapi2json to run this script and create the schemas

Notes:
Since there are no swagger.json files for ACM around, I just installed it on a 4.9 OCP cluster (ACM 2.4.2)
and retrieved all APIs with the following:
```
kubectl proxy --port=8080
curl localhost:8080/openapi/v2 | jq . > ocp-4.9-acm-2.4.2-clean.json
```
This file was saved in `ocp-acm-schemas/ocp-4.9-acm-2.4.2-clean.json`.

OpenShift publishes schemas here:
```
curl -L -o openshift/swaggers.json https://github.com/openshift/kubernetes/blob/master/api/openapi-spec/swagger.json?raw=true
```

Argo here:
```
https://github.com/argoproj/argo-cd/blob/master/assets/swagger.json
```
