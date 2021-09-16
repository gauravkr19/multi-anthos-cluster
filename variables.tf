variable "project_id" {
  description = "The project id to deploy Jenkins on GKE"
}

variable "tfstate_gcs_backend" {
  description = "Name of the GCS bucket to use as a backend for Terraform State"
  default     = "TFSTATE_GCS_BACKEND"
}

variable "region" {
  description = "The GCP region to deploy instances into"
  default     = "us-east4"
}

variable "zones" {
  description = "The GCP zone to deploy gke into"
  type        = string
  default     = "us-east4-a"
}

variable "anthos_k8s_config" {
  description = "Name for the k8s secret required to configure k8s executers on Jenkins"
  default     = "anthos-k8s-config"
}

# variable "github_username" {
#   description = "Github user/organization name where the terraform repo resides."
# }

# variable "github_token" {
#   description = "Github token to access repo."
# }

# variable "github_repo" {
#   description = "Github repo name."
#   default     = "tf-anthos-apps"
# }

variable "network" {
  description = "The name of the network to run the cluster"
  default     = "anthos-vpc"
}

# variable "subnetwork" {
#   description = "The name of the subnet to run the cluster"
#   default     = "anthos-subnet"
# }

variable "ip_range_pods" {
  description = "The secondary range name for the pods"
  default     = "pod-cidr-name"
}

variable "ip_range_services" {
  description = "The secondary range name for the services"
  default     = "service-cidr-name"
}

variable "ip_range_pods_db" {
  description = "The secondary range name for the pods"
  default     = "pod-cidr-name-db"
}

variable "ip_range_services_db" {
  description = "The secondary range name for the services"
  default     = "service-cidr-name-db"
}

variable clusname {
  default     = "anthos-gke-app"
  description = "GKE cluster name"
}

 variable "service_account_name" {
   default = "jenkins-hub-sa"
 }

variable "acm_repo_location" {
  description = "The location of the git repo ACM will sync to"
}
variable "acm_branch" {
  description = "The git branch ACM will sync to"
}
variable "acm_dir" {
  description = "The directory in git ACM will sync to"
}

variable "asm_version" {
  type        = string
  default     = "1.10"
  description = "description"
}

variable "name" {
  type = string
  default = "anthos-gke"
  description = "suffix for anthos cluster na-sa"
}

variable "gke_hub_sa_name" {
  type        = string
  default     = "hub-svc-account"
  description = "sa for hub reg"
}

variable "ip_cidr_subnet_pods" {
  description = "The secondary ip range to use for pods"
  default     = "172.8.0.0/14"
}

variable "ip_cidr_subnet_services" {
  description = "The secondary ip range to use for pods"
  default     = "10.12.0.0/20"
}

variable "subnet_cidr" {
  default     = "10.8.0.0/14"
  description = "subnet cidr range"
}

variable "ip_cidr_subnet_pods_db" {
  type        = string
  default     = "172.16.0.0/14"
}

variable "ip_cidr_subnet_services_db" {
  type        = string
  default     = "10.12.16.0/20"
}

variable "subnet_cidr_db" {
  default     = "10.16.0.0/14"
  description = "subnet cidr range"
}

variable "clusnamedb" {
  default     = "anthos-gke-db"
  description = "Cluster hosting database"
}

variable "wi_ksa" {
  default     = "tekton-triggers-example-sa"
  description = "KSA mapped to GSA for WI"
}
variable "wi_gsa" {
  default     = "boa-sa-wi"
  description = "GSA mapped to KSA for WI"
}
variable "wi_namespace" {
  default     = "default"
  description = "Namespace hosting the application"
}
