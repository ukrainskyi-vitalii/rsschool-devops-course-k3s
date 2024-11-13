# ec2
variable "ami_id" {
  description = "AMI ID for eu-west-1"
  default     = "ami-00385a401487aefa4"
}

variable "ssh_key_name" {
  description = "SSH key name"
  default     = "rs-school"
}