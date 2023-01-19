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

variable "alert_email" {
  description = "budget alert email"
  type        = string
  default     = "brunolbandeira@gmail.com"
}

variable "repo_url" {
  description = "git repo url for cloning"
  type = string
  default = "https://github.com/blbandeira/data-eng-env.git"
}

variable "repo_name" {
  description = "git repo url for cloning"
  type = string
  default = "data-eng-env"
}

variable "my_ip" {
  description = "personal ip"
  type = string
  default = "0.0.0.0/0"
}