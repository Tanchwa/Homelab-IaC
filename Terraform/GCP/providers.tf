terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}

provider "google" {
  project = "cks-practice-438406"
  region  = "us-central1"
  zone    = "us-central1-f"
}
