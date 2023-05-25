#### after cluster is created input re license file into cluster

resource "local_file" "license_file" {
    content  = templatefile("${path.module}/licenses/license.tpl", {
      license_file        = file("./re-license/re-license.txt")
    })
    filename = "${path.module}/licenses/license"
}

#### Sleeper, after cluster is created sleep for 30s 
#### to make sure its up and running before attempting to add the license file
resource "time_sleep" "wait_60_seconds_license_file" {
  create_duration = "60s"
}

######################
# Run ansible-playbook to create cluster
resource "null_resource" "ansible-update-re-license" {
  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=\"False\" ansible-playbook ${path.module}/redislabs-update-license.yaml --private-key ${var.ssh_key_path} -i ${path.module}/inventories/${var.vpc_name}_inventory.ini -e @${path.module}/extra_vars/${var.vpc_name}_inventory.yaml -e @${path.module}/group_vars/all/main.yaml" 
    }
    depends_on = [local_file.dynamic_inventory_ini, 
                  time_sleep.wait_30_seconds,
                  time_sleep.wait_60_seconds_license_file, 
                  local_file.extra_vars,
                  local_file.license_file]
}

