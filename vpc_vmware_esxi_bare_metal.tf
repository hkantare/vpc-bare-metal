
data "ibm_is_image" "vmw_esx_image" {
  name = "ibm-esxi-7-0u3d-19482537-byol-amd64-1"
}

resource "ibm_is_vpc" "vmware_vpc" {
  name = "vmware"
}

resource "ibm_is_subnet" "vmware_subnet" {
  name            = "vmsubnet"
  vpc             = ibm_is_vpc.vmware_vpc.id
  zone            = "us-south-3"
  ipv4_cidr_block = "10.240.129.0/24"
}

locals {
  zone_clusters = {
      cluster_0 = {                              # Value must be "cluster_0" for the first cluster
      name = "mgmt"       
      domain = "mgmt"                          # Value must be "mgmt" for the first cluster
      host_list = var.mgmt_host_list           # Defines a hosts for this cluster.
    }
  }
}


module "zone_bare_metal_esxi" {
  source = "./vpc-bare-metal"
  for_each = local.zone_clusters

  vmw_host_list = each.value.host_list

  vmw_enable_vcf_mode = true
  vmw_resource_group_id = "aac37f57b20142dba1a435c70aeb12df"

  vmw_vpc = ibm_is_vpc.vmware_vpc.id
  vmw_vpc_zone = "us-south-3"
  vmw_esx_image = data.ibm_is_image.vmw_esx_image.id
  vmw_host_profile = "bx2-metal-192x768"
  #vmw_resources_prefix = local.resources_prefix
  vmw_resources_prefix = "test" ## need to add random here
  # vmw_resources_random = random_string.resource_code.result
  vmw_cluster_prefix = "mgmt"
  vmw_dns_servers = var.dns_servers
  vmw_host_subnet = ibm_is_subnet.vmware_subnet.id
}

locals {
 cluster_list = [ for cluster_key, cluster_value in local.zone_clusters: { cluster_key=cluster_key, name=cluster_value.name, domain=cluster_value.domain } ]
}

locals {
 zone_clusters_hosts_values = {
   clusters = {
     for k, v in local.cluster_list: v.name => {
         name = "${v.name}",
         hosts = [
          for host_k in local.zone_clusters[v.cluster_key].host_list : {
            key = host_k
            hostname = module.zone_bare_metal_esxi[v.cluster_key].ibm_is_bare_metal_server_hostname[host_k],
            username = "root",
            password = module.zone_bare_metal_esxi[v.cluster_key].ibm_is_bare_metal_server_initialization[host_k].user_accounts[0].password,
            id = module.zone_bare_metal_esxi[v.cluster_key].ibm_is_bare_metal_server_id[host_k],
          }
        ]
      }
    }
  }
}

output "test" {
  value = local.zone_clusters_hosts_values
}