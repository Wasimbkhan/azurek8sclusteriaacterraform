variable "rg_name" {
 default = "AZCICDIAACRG"
}

variable "environment" {
    default = "Dev"
}

variable "location" {
  default = "CentralIndia"
}

variable "aziaack8scluster_name" {
  default = "aziaack8sterraformtest"
}

variable "dns_prefix" {
  default = "azdevk8scluster"
}

variable "nodecount" {
  default = 3
}

variable client_id {}
variable client_secret {}
variable ssh_public_key {}

variable "myvnet" {
  default = "myazvnet"
  
}