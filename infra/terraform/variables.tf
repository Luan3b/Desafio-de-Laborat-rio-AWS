variable "ami_id" {
  description = "AMI a ser usada nas instâncias"
  type        = string
}

variable "instance_type" {
  description = "Tipo das instâncias"
  type        = string
  default     = "t3.micro"
}

variable "ssh_key_name" {
  description = "Nome da chave SSH existente na AWS"
  type        = string
}
