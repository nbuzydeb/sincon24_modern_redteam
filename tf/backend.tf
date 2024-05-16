# Some values here are duplicated from variables.tf due to how early the backend data is processed

terraform {
  backend "s3" {
    profile = "sincon2024"
    bucket  = "" # WARNING: Create this bucket manually before using this Terraform project and change the value appropriately!
    key     = "mythicv3"
    region  = "ap-southeast-1"
  }
}