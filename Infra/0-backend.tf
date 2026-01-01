terraform {
  backend "s3" {
    bucket         = "terraformstatefile-cisco"
    key            = "devops-master/infra/terraform.tfstate"
    region         = "us-east-1"
    # dynamodb_table = "terraform-locks"
     use_lockfile  = true
    encrypt        = true
  }
}