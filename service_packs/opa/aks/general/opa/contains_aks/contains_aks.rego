package probr_aks

azurerm_kubernetes_clusters := [resource |
  resource := input.resource_changes[_]
  resource.type == "azurerm_kubernetes_cluster"
]

deny[msg] {
  actual := count(azurerm_kubernetes_clusters)

  actual == 0
  msg := "No AKS resources found"
}
