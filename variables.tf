# ec2
variable "ami_id" {
  description = "AMI ID for eu-west-1"
  default     = "ami-0d64bb532e0502c46"
}

variable "ssh_key_name" {
  description = "SSH key name"
  default     = "rs-school"
}