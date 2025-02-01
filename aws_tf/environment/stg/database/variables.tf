variable "db_identifier" {
  type    = string
  
}

variable "db_name" {
  type    = string
}

variable "db_username" {
  type      = string
  sensitive = true
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "db_port" {
  type    = string
  default = "3306"
}

variable "multi_az" {
  type    = bool
  default = false
}
