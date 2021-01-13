@probes/kubernetes
@probes/kubernetes/general
@standard/cis
@standard/cis/gke
@csp/azure
Feature: General Cluster Security Configurations
    As a Security Auditor
    I want to ensure that Kubernetes clusters have general security configurations in place
    So that no general cluster vulnerabilities can be exploited

    @probes/kubernetes/general/1.2 @control_type/inspection @standard/cis/gke/6.10.1 @standard/citihub/CHC2-ITS115
    Scenario: Ensure Kubernetes Web UI is disabled
        Given I have a manifest for deploying cloud resources
        And I have a policy that checks for the presence of the AKS dashboard
        When the manifest includes Azure Kubernetes Service resources
        And the Kubernetes Web UI is <FLAG> in the manifest
        Then the creation of the AKS cluster should be <RESULT>

        Examples:
            | FLAG            | RESULT        |
            | enabled         | denied        |
            | disabled        | allowed       |
            | unspecified     | denied        |