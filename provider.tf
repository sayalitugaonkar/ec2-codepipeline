terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.43.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.2"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.0"
    }
    template = {
      source  = "hashicorp/template"
      version = "2.2.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.4.2"
    }
    external = {
      source  = "hashicorp/external"
      version = "2.3.3"
    }
    github = {
      source  = "integrations/github"
      version = "6.2.1"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region                   = "ap-south-1"
  shared_credentials_files = ["/home/sayali/.credentials"]
  profile                  = "testing"
}

provider "null" {}
provider "random" {}
provider "template" {}
provider "external" {}