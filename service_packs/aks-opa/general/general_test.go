package main

import (
	"context"
	"fmt"
	"github.com/cucumber/godog"
	cnftoutput "github.com/open-policy-agent/conftest/output"
	"os"
)

func iHaveAManifestForDeployingAKS() error {
	//load all of the test files into memory and check that they contain AKS deployments
	ctx = context.TODO()

	return nil
}

func iHaveARegoPolicy() error {
	conftestRunner.PolicyPaths = []string{os.Getenv("CNFT_POLICY_PATH")}

	return conftestRunner.LoadPolicies(ctx)
}

func runConfTest() ([]cnftoutput.CheckResult, error) {
	conftestresults, err := conftestRunner.RunConfTest(ctx)
	if err != nil {
		return nil, err
	}

	resultcount := 0

	for _, result := range conftestresults {
		resultcount = resultcount + result.Successes + len(result.Failures) + len(result.Exceptions) + len(result.Warnings)
	}

	if resultcount == 0 {
		return nil, fmt.Errorf("Conftest total result count was nil - nothing evaluated")
	}

	return conftestresults, nil
}

func theCreationOfTheAKSClusterShouldBeAllowed() error {

	successcount := 0
	for _, result := range results {
		if len(result.Failures) > 0 {
			return fmt.Errorf("Conftest failures detected")
		}
		successcount = successcount + result.Successes
	}

	if successcount == 0 {
		return fmt.Errorf("No successes were detected")
	}

	return nil
}

func theCreationOfTheAKSClusterShouldBeDenied() error {
	failurecount := 0
	for _, result := range results {
		if result.Successes > 0 {
			return fmt.Errorf("Conftest successes detected")
		}
		failurecount = failurecount + len(result.Failures)
	}

	if failurecount == 0 {
		return fmt.Errorf("No successes were detected")
	}

	return nil
}

func theKubernetesWebUIIsDisabledInTheManifest() error {
	conftestRunner.FileList = []string{os.Getenv("CNFT_TFPLAN_DISABLED")}
	var err error
	results, err = runConfTest()
	return err
}

func theKubernetesWebUIIsEnabledInTheManifest() error {
	conftestRunner.FileList = []string{os.Getenv("CNFT_TFPLAN_ENABLED")}
	var err error
	results, err = runConfTest()
	return err
}

func theKubernetesWebUIIsUnspecifiedInTheManifest() error {
	return godog.ErrPending
}

func FeatureContext(s *godog.Suite) {
	s.Step(`^I have a manifest for deploying AKS$`, iHaveAManifestForDeployingAKS)
	s.Step(`^I have a policy that checks for the presence of the AKS dashboard$`, iHaveARegoPolicy)
	s.Step(`^the creation of the AKS cluster should be allowed$`, theCreationOfTheAKSClusterShouldBeAllowed)
	s.Step(`^the creation of the AKS cluster should be denied$`, theCreationOfTheAKSClusterShouldBeDenied)
	s.Step(`^the Kubernetes Web UI is disabled in the manifest$`, theKubernetesWebUIIsDisabledInTheManifest)
	s.Step(`^the Kubernetes Web UI is enabled in the manifest$`, theKubernetesWebUIIsEnabledInTheManifest)
	s.Step(`^the Kubernetes Web UI is unspecified in the manifest$`, theKubernetesWebUIIsUnspecifiedInTheManifest)
}
