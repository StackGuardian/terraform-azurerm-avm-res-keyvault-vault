moved {
  from = azurerm_key_vault.this
  to   = azapi_resource.key_vault
}

resource "azapi_resource" "key_vault" {
  count     = var.existing_resource_id != null ? 0 : 1
  type      = "Microsoft.KeyVault/vaults@2023-07-01"
  location  = var.location
  parent_id = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}"
  body = jsonencode({
    properties = {
      createMode                   = "default"
      enableRbacAuthorization      = var.rbac_authorization_enabled
      enableSoftDelete             = true
      enabledForDeployment         = var.enabled_for_deployment
      enabledForDiskEncryption     = var.enabled_for_disk_encryption
      enabledForTemplateDeployment = var.enabled_for_template_deployment
      publicNetworkAccess          = var.public_network_access_enabled
      networkAcls                  = local.network_acls
      sku = {
        family = "A"
        name   = lower(var.sku_name)
      }
      softDeleteRetentionInDays = var.soft_delete_retention_days
      tenantId                  = var.tenant_id
      enablePurgeProtection     = var.purge_protection_enabled
    }
  })
  tags = var.tags
}

resource "azapi_resource" "key_vault_role_assignments" {
  for_each  = var.role_assignments
  type      = "Microsoft.Authorization/roleAssignments@2022-04-01"
  parent_id = azapi_resource.key_vault[0].id
  body = jsonencode({
    properties = {
      principalId      = each.value.principal_id
      roleDefinitionId = each.value.role_definition_id_or_name
    }
  })

}

resource "azapi_data_plane_resource" "key_vault_certificate_contacts" {
  count     = var.contacts != null ? 1 : 0
  type      = "Microsoft.KeyVault/vaults/certificates/contacts@2023-07-01"
  parent_id = azapi_resource.key_vault[0].id
  name      = "contacts"
  body = jsonencode({
    contactList = [for _, contact in var.contacts : {
      emailAddress = contact.email
      name         = contact.name
      phone        = contact.phone
    }]
  })
}
