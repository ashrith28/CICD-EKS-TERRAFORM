terraform {
  backend "s3" {
    bucket = "ashrith-s3-demo-xyz" # change this
    key    = "eks/terraform.tfstate"
    region = "ap-south-1"
  }
}