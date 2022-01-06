#!/bin/bash
# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This file creates pub/sub Cloud Build triggers.
# It should be migrated to Terraform once Terraform supports it.

#################################
## Staging Deployment Triggers ##
#################################

gcloud alpha builds triggers create pubsub \
--name=web-deploy-staging --topic="projects/${OPS_PROJECT}/topics/gcr" \
--repo=https://github.com/${repo_owner}/${repo_name} \
--branch=main --build-config=ops/deploy.cloudbuild.yaml \
--substitutions=_IMAGE_NAME='$(body.message.data.tag)',\
_REGION="$REGION",_REVISION='$(body.message.messageId)',\
_SERVICE=website,_TARGET_PROJECT="$STAGE_PROJECT",\
_ENV="staging",_ENV_VARS="$_ENV_VARS" \
 --filter='_IMAGE_NAME == "website"' \
 --project="${OPS_PROJECT}"

gcloud alpha builds triggers create pubsub \
--name=api-deploy-staging --topic="projects/${OPS_PROJECT}/topics/gcr" \
--repo=https://github.com/${repo_owner}/${repo_name} \
--branch=main --build-config=ops/deploy.cloudbuild.yaml \
--substitutions=_IMAGE_NAME='$(body.message.data.tag)',\
_REGION="$REGION",_REVISION='$(body.message.messageId)',\
_SERVICE=content-api,_TARGET_PROJECT="$STAGE_PROJECT",_ENV="staging" \
--filter='_IMAGE_NAME == "content-api"' \
--project="${OPS_PROJECT}" 

##############################
## Prod Deployment Triggers ##
##############################

gcloud alpha builds triggers create pubsub \
--name=web-deploy-prod --topic="projects/${OPS_PROJECT}/topics/deploy-prod" \
--repo=https://github.com/${repo_owner}/${repo_name} \
--branch=main --build-config=ops/deploy.cloudbuild.yaml \
--substitutions=_IMAGE_NAME='$(body.message.data.tag)',\
_REGION="$REGION",_REVISION='$(body.message.messageId)',\
_SERVICE=website,_TARGET_PROJECT="$PROD_PROJECT",\
_ENV="prod",_ENV_VARS="$_ENV_VARS" \
--filter='_IMAGE_NAME == "website"' \
--project="${OPS_PROJECT}" --require-approval 

gcloud alpha builds triggers create pubsub \
--name=api-deploy-prod --topic="projects/${OPS_PROJECT}/topics/deploy-prod" \
--repo=https://github.com/${repo_owner}/${repo_name} \
--branch=main --build-config=ops/deploy.cloudbuild.yaml \
--substitutions=_IMAGE_NAME='$(body.message.data.tag)',\
_REGION="$REGION",_REVISION='$(body.message.messageId)',\
_SERVICE=content-api,_TARGET_PROJECT="$PROD_PROJECT",_ENV="prod" \
--filter='IMAGE_NAME == "content-api"' \
--project="${OPS_PROJECT}" --require-approval 

# ##############################
# ### Canary Rollout Staging ###
# ##############################

gcloud alpha builds triggers create pubsub \
--name=api-canary-staging --topic="projects/${OPS_PROJECT}/topics/canary-staging" \
--repo=https://github.com/${repo_owner}/${repo_name} \
--branch=main --build-config=ops/canary.cloudbuild.yaml \
--substitutions=_IMAGE_NAME='$(body.message.attributes._IMAGE_NAME)',\
_REGION='$(body.message.attributes._REGION)',\
_REVISION='$(body.message.attributes._REVISION)',\
_SERVICE='$(body.message.attributes._SERVICE)',\
_TRAFFIC='$(body.message.attributes._TRAFFIC)',\
_ENV='$(body.message.attributes._ENV)'\
--filter='_SERVICE == "content-api" &&
_ENV == "staging"' \
--project="${OPS_PROJECT}" 

gcloud alpha builds triggers create pubsub \
--name=web-canary-staging --topic="projects/${OPS_PROJECT}/topics/canary-staging" \
--repo=https://github.com/${repo_owner}/${repo_name} \
--branch=main --build-config=ops/canary.cloudbuild.yaml \
--substitutions=_IMAGE_NAME='$(body.message.attributes._IMAGE_NAME)',\
_REGION='$(body.message.attributes._REGION)',\
_REVISION='$(body.message.attributes._REVISION)',\
_SERVICE='$(body.message.attributes._SERVICE)',\
_TRAFFIC='$(body.message.attributes._TRAFFIC)',\
_ENV='$(body.message.attributes._ENV)'\
--filter='_SERVICE == "website" && 
_ENV == "staging"' \
--project="${OPS_PROJECT}" 

# ###########################
# ### Canary Rollout Prod ###
# ###########################

gcloud alpha builds triggers create pubsub \
--name=api-canary-prod --topic="projects/${OPS_PROJECT}/topics/canary-prod" \
--repo=https://github.com/${repo_owner}/${repo_name} \
--branch=main --build-config=ops/canary.cloudbuild.yaml \
--substitutions=_IMAGE_NAME='$(body.message.attributes._IMAGE_NAME)',\
_REGION='$(body.message.attributes._REGION)',\
_REVISION='$(body.message.attributes._REVISION)',\
_SERVICE='$(body.message.attributes._SERVICE)',\
_TRAFFIC='$(body.message.attributes._TRAFFIC)',\
_ENV='$(body.message.attributes._ENV)'\
--filter='_SERVICE == "content-api" && 
_ENV == "prod"' \
--project="${OPS_PROJECT}" 

gcloud alpha builds triggers create pubsub \
--name=web-canary-prod --topic="projects/${OPS_PROJECT}/topics/canary-prod" \
--repo=https://github.com/${repo_owner}/${repo_name} \
--branch=main --build-config=ops/canary.cloudbuild.yaml \
--substitutions=_IMAGE_NAME='$(body.message.attributes._IMAGE_NAME)',\
_REGION='$(body.message.attributes._REGION)',\
_REVISION='$(body.message.attributes._REVISION)',\
_SERVICE='$(body.message.attributes._SERVICE)',\
_TRAFFIC='$(body.message.attributes._TRAFFIC)',\
_ENV='$(body.message.attributes._ENV)'\
--filter='_SERVICE == "website" && 
_ENV == "prod"' \
--project="${OPS_PROJECT}" 
