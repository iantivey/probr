This is the start of a service pack which checks OPA for a Terraform plan output that includes `azurerm_kubernetes_cluster` resources.

It is designed to test that the OPA meets the behaviour criteria, using conftest.

This can be run just as any other service pack, and will soon be expanded to use flag and config vars.

To run it, set the following environment variables

1. `$CNFT_POLICY_PATH` - set to `$(pwd)/opa/kube_dashboard`
1. `$CNFT_TFPLAN_DISABLED` - set to `$(pwd)/json/kube_dashboard/disabled.json`
1. `$CNFT_TFPLAN_ENABLED` - set to `$(pwd)/json/kube_dashboard/enabled.json`
1. `$CNFT_TFPLAN_NOTPRESENT` - set to `$(pwd)/json/kube_dashboard/not_present.json`
