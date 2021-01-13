package main

azurerm_kubernetes_clusters := [resource |
    resource := input.resource_changes[_]
    resource.type == "azurerm_kubernetes_cluster"
]

deny[msg] {
    expected := 0

    actual := count([res |
       res := azurerm_kubernetes_clusters[_]
       object.get(res.change.after.addon_profile[0], "kube_dashboard", [])[0].enabled
    ])

    expected != actual
    msg := "kubernetes dashboard should be disabled"
}
