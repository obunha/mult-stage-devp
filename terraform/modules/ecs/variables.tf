variable "env" {
  type = string
}

variable "region" {
  type = string
}

variable "image_url" {
  type = string
}

variable "subnets" {
  type = list(string)
}

variable "security_group_id" {
  type = string
}
