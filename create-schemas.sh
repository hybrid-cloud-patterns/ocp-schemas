#!/bin/bash
set -eu

OCPVER=${OCPVER:-4.10}
ARGOVER=${ARGOVER:-master}
V=${VENV:-~/.virtualenvs}
FILE=${FILE:-ocp-4.10-acm-2.5.0-clean.json}
# NOTE The prerequisite of this script is that you installed
# Install openapi2json via pip in a virtualenv with the following patch
# need to patch it with https://github.com/instrumenta/openapi2jsonschema/pull/55
# and patch it with https://github.com/instrumenta/openapi2jsonschema/pull/58
# Like this:
# virtualenv ~/.virtualenvs/openapi2json
# source ~/.virtualenvs/openapi2json/bin/activate
# pip install openapi2jsonschema
# curl -L https://github.com/instrumenta/openapi2jsonschema/commit/eeed25046b189924fe835ab784eadbb241ae574c.diff | patch -d ~/.virtualenvs/openapi2json/lib/python3.10/site-packages/openapi2jsonschema -p2
# curl -L https://github.com/instrumenta/openapi2jsonschema/pull/58/commits/7a208e9becae9c66bccb4c89869bb24f634a42af.diff | patch -d ~/.virtualenvs/openapi2json/lib/python3.10/site-packages/openapi2jsonschema -p2
source ${V}/openapi2json/bin/activate
echo "Working on ${FILE}"

# for i in ${URLS[@]}; do
#   base=$(basename $i)
#   echo "$i -> $base"
#   curl -L -o upstream/$base $i
# done

mkdir openshift/${OCPVER} -p
cp ocp-acm-schemas/${FILE} openshift/${OCPVER}
cd openshift/${OCPVER}
curl -L -o ocp-swagger.json https://github.com/openshift/kubernetes/blob/release-${OCPVER}/api/openapi-spec/swagger.json?raw=true
curl -L -o argo-swagger.json https://raw.githubusercontent.com/argoproj/argo-cd/${ARGOVER}/assets/swagger.json
curl -L -o tekton-swagger.json https://raw.githubusercontent.com/tektoncd/hub/main/vendor/github.com/tektoncd/pipeline/pkg/apis/pipeline/v1beta1/swagger.json
mkdir -p master-standalone master-standalone-strict
set +e
# Order is important keep the downloaded json files last so they override the others
for f in ${FILE} ocp-swagger.json argo-swagger.json tekton-swagger.json; do
openapi2jsonschema -o "master-standalone" --expanded --kubernetes --stand-alone "$f" &
openapi2jsonschema -o "master-standalone-strict" --expanded --kubernetes --stand-alone --strict "$f" &
done
wait
set -e
rm ${FILE} ocp-swagger.json argo-swagger.json tekton-swagger.json
echo "Finished"
