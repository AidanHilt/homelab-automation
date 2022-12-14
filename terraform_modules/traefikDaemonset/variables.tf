variable nginx-version {
  type        = string
  default     = ""
  description = "The version of the nginx container to use"
}

variable namespace{
  type        = string
  default     = ""
  description = "The name of the namespace to bring up this new PVC in."
}