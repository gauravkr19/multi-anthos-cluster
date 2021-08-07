#!/bin/bash 
export clusname=anthos-gke-app
export clusnamedb=anthos-gke-db
export region=us-east4

gcloud container clusters get-credentials ${clusname} --zone=${region}
kubectl delete ns config-management-monitoring config-management-system resource-group-system
gcloud container clusters get-credentials ${clusnamedb} --zone=${region}
kubectl delete ns config-management-monitoring config-management-system resource-group-system
echo add istio remote-secret too
