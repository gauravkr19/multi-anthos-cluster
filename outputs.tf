
output "kubernetes_endpoint" {
  description = "The cluster endpoint"
  sensitive   = true
  value       = module.anthos-gke.endpoint
}

output "client_token" {
  description = "The bearer token for auth"
  sensitive   = true
  value       = base64encode(data.google_client_config.anthos.access_token)
}

output "ca_certificate" {
  description = "The cluster ca certificate (base64 encoded)"
  value       = module.anthos-gke.ca_certificate
  sensitive   = true
}

output "service_account" {
  description = "The default service account used for running nodes."
  value       = module.anthos-gke.service_account
}

output "cluster_name" {
  description = "Cluster name"
  value       = module.anthos-gke.name
}

# output "k8s_service_account_name" {
#   description = "Name of k8s service account."
#   value       = module.workload_identity.k8s_service_account_name
# }

# output "gcp_service_account_email" {
#   description = "Email address of GCP service account."
#   value       = module.workload_identity.gcp_service_account_email
# }

output "zone" {
  description = "Zone of GKE cluster"
  value       =  var.zones            #for converting list to string: join(",", var.zones)
}

output "project" {
  value = data.google_client_config.anthos.project
}

output "location" {
  value = module.anthos-gke.location
}

