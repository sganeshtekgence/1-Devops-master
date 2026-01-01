############################################
# Variables
############################################

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "image_tag" {
  description = "Docker image tag pushed to ECR (provided by CI/CD)"
  type        = string
  default     = "bootstrap"
}
