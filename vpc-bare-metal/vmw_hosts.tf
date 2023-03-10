
##############################################################
# Create reserved subnet IP for VCF vmk1
##############################################################


resource "ibm_is_ssh_key" "example" {
  name       = "example-ssh"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCKVmnMOlHKcZK8tpt3MP1lqOLAcqcJzhsvJcjscgVERRN7/9484SOBJ3HSKxxNG5JN8owAjy5f9yYwcUg+JaUVuytn5Pv3aeYROHGGg+5G346xaq3DAwX6Y5ykr2fvjObgncQBnuU5KHWCECO/4h8uWuwh/kfniXPVjFToc+gnkqA+3RKpAecZhFXwfalQ9mMuYGFxn+fwn8cYEApsJbsEmb0iJwPiZ5hjFC8wREuiTlhPHDgkBLOiycd20op2nXzDbHfCHInquEe/gYxEitALONxm0swBOwJZwlTDOB7C6y2dzlrtxr1L59m7pCkWI4EtTRLvleehBoj3u7jB4usR"
}

data "ibm_is_subnet" "vmw_host_subnet" {
  identifier = var.vmw_host_subnet
}


resource "ibm_is_bare_metal_server" "esx_host" {
    for_each = toset(var.vmw_host_list)
   
    profile = var.vmw_host_profile
    name = "baremetal-test-${format(each.key)}"
    resource_group  = var.vmw_resource_group_id
    image = var.vmw_esx_image
    zone = var.vmw_vpc_zone
    keys = [ibm_is_ssh_key.example.id]
    primary_network_interface {
      # pci 1
      subnet = var.vmw_host_subnet
      name = "pci-nic-vmnic0-uplink1"
      enable_infrastructure_nat = true
    }

    vpc = var.vmw_vpc
    timeouts {
      create = "60m"
      update = "30m"
      delete = "30m"
    }

    lifecycle {
      ignore_changes = [image]
    }
}


##############################################################
# Get host root passwords
##############################################################

data "ibm_is_bare_metal_server_initialization" "esx_host_init_values" {
    for_each = toset(var.vmw_host_list)
    bare_metal_server = ibm_is_bare_metal_server.esx_host[each.key].id
}

output "ibm_is_bare_metal_server_initialization" {
  value = { for k in var.vmw_host_list : k => data.ibm_is_bare_metal_server_initialization.esx_host_init_values[k] }
}

output "ibm_is_bare_metal_server_hostname" {
  value = { for k in var.vmw_host_list : k => ibm_is_bare_metal_server.esx_host[k].name }
}

output "ibm_is_bare_metal_server_id" {
  value = { for k in var.vmw_host_list : k => ibm_is_bare_metal_server.esx_host[k].id }
}