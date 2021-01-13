package main

empty(value) {
  count(value) == 0
}

no_violations {
  empty(deny)
}

test_aks_not_present {
  deny["No AKS resources found"]
  with input as
    {
      "resource_changes": [
        {
          "type": "azurerm_storage_account"
        }
      ]
    }
}

test_aks_present {
  no_violations
  with input as
    {
      "resource_changes": [
        {
          "type": "azurerm_kubernetes_cluster"
        },
        {
          "type": "azurerm_storage_account"
        }
      ]
    }
}

test_several_aks_present {
  no_violations
  with input as
    {
      "resource_changes": [
        {
          "type": "azurerm_kubernetes_cluster"
        },
        {
          "type": "azurerm_storage_account"
        },
        {
          "type": "azurerm_kubernetes_cluster"
        },
        {
          "type": "azurerm_kubernetes_cluster"
        }
      ]
    }
}
