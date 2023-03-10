terraform {
  required_version = ">=1.3.0, <2.0"
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
      # source = "localdomain/provider/ibm" //"~/.terraform.d/plugins/localdomain/provider/ibm/1.45.0/darwin_arm64"
      version = "= 1.48.0"
    }
  }
}

provider "ibm" {

# Define Provider inputs manually
 ibmcloud_api_key = var.ibmcloud_api_key

# Define Provider inputs from given Terraform Variables

# Default Provider block parameters
  region = "us-south"
}
