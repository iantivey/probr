package main

azurerm_kubernetes_clusters := [resource |
    resource := input.resource_changes[_]
    resource.type == "azurerm_kubernetes_cluster"
]

deny[msg] {
    expected := count(azurerm_kubernetes_clusters)

    actual := count([res |
       res := azurerm_kubernetes_clusters[_]
       object.get(res.change.after.addon_profile[0], "kube_dashboard", [])[0].enabled == false
    ])

    expected != actual
    msg := sprintf("kubernetes dashboard should be explicitly disabled - expected %v, actual %v", [expected, actual])
}
