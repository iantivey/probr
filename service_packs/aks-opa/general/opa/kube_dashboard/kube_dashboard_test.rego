package main

empty(value) {
  count(value) == 0
}

no_violations {
  empty(deny)
}

test_enabled_kube_dashboard {
  deny["kubernetes dashboard should be disabled"]
  with input as
    {
      "resource_changes": [
        {
          "type": "azurerm_kubernetes_cluster",
          "change": {
            "after": {
              "add_on_profile": [
                {
                  "aci_connector_linux": [],
                  "azure_policy": [
                    {
                      "enabled": true
                    }
                  ],
                  "http_application_routing": [
                    {
                      "enabled": false
                    }
                  ],
                  "kube_dashboard": [
                    {
                      "enabled": true
                    }
                  ],
                  "oms_agent": [
                    {
                      "enabled": false,
                      "log_analytics_workspace_id": null
                    }
                  ]
                }
              ]
            }
          }
        }
      ]
    }
}

test_disabled_kube_dashboard {
  no_violations
  with input as
    {
      "resource_changes": [
        {
          "type": "azurerm_kubernetes_cluster",
          "change": {
            "after": {
              "add_on_profile": [
                {
                  "aci_connector_linux": [],
                  "azure_policy": [
                    {
                      "enabled": true
                    }
                  ],
                  "http_application_routing": [
                    {
                      "enabled": false
                    }
                  ],
                  "kube_dashboard": [
                    {
                      "enabled": false
                    }
                  ],
                  "oms_agent": [
                    {
                      "enabled": false,
                      "log_analytics_workspace_id": null
                    }
                  ]
                }
              ]
            }
          }
        }
      ]
    }
}
