variable "owner" {
  type        = string
  description = "Owner tag to which the artifacts belong"
  default     = "rp"
}
variable "boundary_version" {
  type = string
  description = "Three digit Boundary version to work with"
  default = "0.11.0+hcp"
}
variable "aws_region" {
  type        = string
  description = "AWS Region for image"
  default     = "ap-southeast-1"
}
variable "aws_instance_type" {
  type        = string
  description = "Instance Type for Image"
  default     = "t2.small"
}
