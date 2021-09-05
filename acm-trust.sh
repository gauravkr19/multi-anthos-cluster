#!/bin/bash

opt=$1
CLUSNAME_APP=$2
REGION=$3
CLUSNAME_DB=$4
PROJECT_ID=$5

CLUSTER_1_CTX="gke_${PROJECT_ID}_${REGION}_${CLUSNAME_APP}"
CLUSTER_2_CTX="gke_${PROJECT_ID}_${REGION}_${CLUSNAME_DB}"

create_resources() {
  set -e
    gcloud alpha container hub config-management enable
    gsutil cp gs://config-management-release/released/latest/config-management-operator.yaml config-management-operator.yaml
    gcloud container clusters get-credentials "${CLUSNAME_APP}" --zone="${REGION}"; sleep 9s
    istioctl x create-remote-secret --context="${CLUSTER_2_CTX}" --name="${CLUSNAME_DB}" | kubectl apply -f -    
    kubectl apply -f config-management-operator.yaml

    gcloud container clusters get-credentials "${CLUSNAME_DB}" --zone="${REGION}"; sleep 9s
    istioctl x create-remote-secret --context="${CLUSTER_1_CTX}" --name="${CLUSNAME_APP}" | kubectl apply -f -
    kubectl apply -f config-management-operator.yaml
    sleep 9s
    }

delete_resources() {
    gcloud container clusters get-credentials "${CLUSNAME_APP}" --zone="${REGION}"
    kubectl delete ns config-management-monitoring config-management-system
    kubectl delete secret istio-remote-secret-"${CLUSNAME_DB}"  -n istio-system

    gcloud container clusters get-credentials "${CLUSNAME_DB}" --zone="${REGION}"
    kubectl delete ns config-management-monitoring config-management-system
    kubectl delete secret istio-remote-secret-"${CLUSNAME_APP}" -n istio-system
    }

case $opt in
  create)
    create_resources ;;
    
  delete)
    delete_resources ;;
    
esac


















# delete_resources

# ####
#  provisioner "local-exec" {
#     command = "${path.module}/mgt-user.sh create '${var.server_fqdn}' '${var.server_admin_user}' '${var.db_name}' '${var.db_user_pass}'"
#   }

#   provisioner "local-exec" {
#     when    = destroy
#     command = "./mgt-user.sh destroy '${var.server_fqdn}' '${var.server_admin_user}' '${var.db_name}' '${var.db_user_pass}'"
#     working_dir = path.module
#   }
# }



# resource "local_file" "config" {
#   # Output vars to config
#   filename = "config.json"
#   content  = "..."

#   # Deploy using config
#   provisioner "local-exec" {
#     command     = "deploy"
#   }

#   # Delete on_destroy
#   provisioner "local-exec" {
#         when        = "destroy"
#         command     = "delete"
#   }
# }