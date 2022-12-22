variable "prefix" {
  description = "Your prefix for resource tagging"
  type = string
  default = ""
}
variable "tfstate_bucket" {
  description = "S3 bucket name for Terraform State file"
  type = string
  default = ""
}
