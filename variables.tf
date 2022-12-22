variable "region" {
  description = "AWS region"
  type        = string
  default     = ""
}
variable "eks_version" {
  description = "EKS Version"
  type        = number
  default     = 1.23
}
variable "access_key" {
  description = "AWS access key"
  type        = string
  default     = ""
}
variable "secret_key" {
  description = "AWS access secret key"
  type        = string
  default     = ""
}
variable "prefix" {
  description = "Your prefix for resource tagging"
  type        = string
  default     = ""
}
variable "tfstate_bucket" {
  description = "S3 bucket name for Terraform State file"
  type        = string
  default     = ""
}
variable "tfstate_path" {
  description = "Path of Terraform State file"
  type        = string
  default     = "tfstate/dev.tfstate"
}
