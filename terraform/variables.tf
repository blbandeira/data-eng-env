variable "key_name" {
  description = "EC2 key name"
  type        = string
  default     = "de-key"
}

variable "instance_type" {
  description = "instance type for ec2"
  type        = string
  default     = "m4.xlarge"
}

variable "repo_url" {
  description = "repo url to clone"
  type        = string
  default     = "https://github.com/blbandeira/data-eng-env"
}

variable "alert_email" {
  description = "budget alert email"
  type        = string
  default     = "brunolbandeira@gmail.com"
}