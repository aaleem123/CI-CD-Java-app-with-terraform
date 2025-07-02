variable "key_name" {
  description = "SSH key name configured in AWS"
  default     = "localkey" 
}

variable "private_key_path" {
  description = "Path to private SSH key"
  default     = "/root/.ssh/localkey.pem"
}
