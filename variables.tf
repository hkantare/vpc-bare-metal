variable "ibmcloud_api_key" {
  type = string
}

variable "mgmt_host_list" {
  description = "Host list and hostname prefix in management domain."
  default = ["000","001"]
  type = list(string)

}

variable "dns_servers" {
  description = "DNS servers."
  default = ["161.26.0.7", "161.26.0.8"]
  type = list(string)
}