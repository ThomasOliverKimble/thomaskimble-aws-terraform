variable "hosted_zone" {
  description = "Hosted zone for the app."
  type        = string
}

variable "yaml_file_path" {
  description = "Path to the YAML file"
  type        = string
  default     = "./storage/file_structure/file_structure.yaml"
}

variable "color_list" {
  description = "List of colors"
  type        = list(string)
  default     = ["blue", "red", "green", "orange", "purple"]
}
