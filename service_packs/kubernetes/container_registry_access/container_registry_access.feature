@kubernetes
@container_registry_access
@CIS-6.1
Feature: Protect image container registries
  As a Security Auditor
  I want to ensure that containers image registries are secured in my organisation's Kubernetes clusters
  So that only approved software can be run in our cluster in order to prevent malicious attacks on my organization

  #Rule: CHC2-APPDEV135 - Ensure software release and deployment is managed through a formal, controlled process

  Background:
    Given a Kubernetes cluster is deployed


  @preventative @CIS-6.1.3
  # TODO not applicable to AKS?
  # TODO unimplemented
  Scenario: Ensure the cluster service account has read only access to the container registry
    When I attempt to push to the container registry using the cluster identity
    Then the push request is rejected due to authorization


  @preventative @CIS-6.1.4
  Scenario: Ensure deployment from an authorised container registry is allowed
    When a user attempts to deploy a container from an authorised registry
    Then the deployment attempt is allowed


  @preventative @CIS-6.1.5
  Scenario: Ensure deployment from an unauthorised container registry is denied
    When a user attempts to deploy a container from an unauthorised registry
    Then the deployment attempt is denied
