locals {
  network_acls = var.network_acls != null ? {
    bypass         = var.network_acls.bypass
    default_action = var.network_acls.default_action
    ipRules        = var.network_acls.ip_rules
    virtualNetworkRules = [for vnr in var.network_acls.virtual_network_rules : {
      id = vnr.id
    }]
  } : null
}
