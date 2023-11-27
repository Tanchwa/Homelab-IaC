variable "resource_group" {
  description = "Name of the resource group to deploy cognative services account"
  type        = string
}

variable "location" {
  description = "location of the defualt account"
  type        = string
}

variable "cog_service_kind" {
  description = "Kind of Cognative Service to be Deployed"
  type        = string
  default     = "OpenAI"
}

variable "cog_account_name" {
  description = "Name of the Cognative Service account"
  type        = string
}

variable "cog_deployment" {
  description = "Values for the cognative deployment"
  type = object({
    name = string
    model = {
      format     = string
      model_name = string
      version    = string
    }
  })
}

variable "deployment_size" {
  description = "Pre-set names for size maps"
  type        = string
  validation {
    condition     = contains(var.deployment_size, "Standard") || contains(var.deployment_size, "Premium")
    error_message = "Deployment Size Must be either Standard or Premium"
  }
}

variable "tokens_per_minute" {
  description = "Capacity in the Model Deployment in Tokens Per Minute"
  type        = number
}

variable "tags" {
  description = "Resource Tags for all resources in the module"
  type        = map(string)
  default = {
    "Last Name"  = "Greatest"
    "First Name" = "Ever"
  }
}

variable "private_networking" {
  description = "Values for existing vNets and subnets"
  type = object({
    enabled   = bool
    subnet_id = string
  })
}
