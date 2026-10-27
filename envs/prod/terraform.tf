terraform {
  cloud {
    organization = "PonsagonPlayGround"
    workspaces {
      name = "slipplus-prod"
    }
  }

  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }

  required_version = ">= 1.5"
}

provider "digitalocean" {
  # Token is read from DIGITALOCEAN_TOKEN env var set in HCP Terraform
}
