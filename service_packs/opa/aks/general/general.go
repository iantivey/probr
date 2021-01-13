package general

import (
	"context"
	"fmt"
	"os"

	"github.com/citihub/probr/internal/coreengine"
	"github.com/citihub/probr/internal/summary"
	opautil "github.com/citihub/probr/service_packs/opa"
	"github.com/cucumber/godog"
	cnftoutput "github.com/open-policy-agent/conftest/output"
)

const (
	envPolicyPath     = "CNFT_POLICY_PATH"
	envTfplanDisabled = "CNFT_TFPLAN_DISABLED"
	envTfplanEnabled  = "CNFT_TFPLAN_ENABLED"
)

var conftestRunner opautil.ConfTestRunner
var ctx context.Context
var results []cnftoutput.CheckResult

type ProbeStruct struct {
	state scenarioState
}

var Probe ProbeStruct

type scenarioState struct {
	name  string
	audit *summary.ScenarioAudit
	probe *summary.Probe
}

func (p ProbeStruct) Name() string {
	return "general"
}

func (p ProbeStruct) Path() string {
	return coreengine.GetFeaturePath("service_packs", "opa", "aks", p.Name())
}

func (p ProbeStruct) ProbeInitialize(ctx *godog.TestSuiteContext) {
	ctx.BeforeSuite(func() {}) //nothing for now
}

func (p ProbeStruct) ScenarioInitialize(ctx *godog.ScenarioContext) {
	p.state = scenarioState{}

	ctx.Step(`^I have a manifest for deploying cloud resources$`, p.iHaveAManifest)
	ctx.Step(`^I have a policy that checks for the presence of the AKS dashboard$`, p.iHaveARegoPolicy)
	ctx.Step(`^the manifest includes Azure Kubernetes Service resources$`, p.manifestIncludesAKS)
	ctx.Step(`^the creation of the AKS cluster should be allowed$`, p.theCreationOfTheAKSClusterShouldBeAllowed)
	ctx.Step(`^the creation of the AKS cluster should be denied$`, p.theCreationOfTheAKSClusterShouldBeDenied)
	ctx.Step(`^the Kubernetes Web UI is disabled in the manifest$`, p.theKubernetesWebUIIsDisabledInTheManifest)
	ctx.Step(`^the Kubernetes Web UI is enabled in the manifest$`, p.theKubernetesWebUIIsEnabledInTheManifest)
	ctx.Step(`^the Kubernetes Web UI is unspecified in the manifest$`, p.theKubernetesWebUIIsUnspecifiedInTheManifest)
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

func (p ProbeStruct) iHaveAManifest() error {
	//check that
	ctx = context.TODO()

	if os.Getenv(envTfplanDisabled) == "" {
		return fmt.Errorf("Missing environment variable %s", envTfplanDisabled)
	}

	if os.Getenv(envTfplanEnabled) == "" {
		return fmt.Errorf("Missing environment variable %s", envTfplanEnabled)
	}

	return nil
}

func (p ProbeStruct) iHaveARegoPolicy() error {
	conftestRunner.PolicyPaths = []string{os.Getenv(envPolicyPath)}

	return conftestRunner.LoadPolicies(ctx)
}

func (p ProbeStruct) manifestIncludesAKS() error {
	//set up a separate conftestRunner here
	//we can probably achieve this with namespace
	return nil
}

func (p ProbeStruct) theCreationOfTheAKSClusterShouldBeAllowed() error {

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

func (p ProbeStruct) theCreationOfTheAKSClusterShouldBeDenied() error {
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

func (p ProbeStruct) theKubernetesWebUIIsDisabledInTheManifest() error {
	conftestRunner.FileList = []string{os.Getenv(envTfplanDisabled)}
	var err error
	results, err = runConfTest()
	return err
}

func (p ProbeStruct) theKubernetesWebUIIsEnabledInTheManifest() error {
	conftestRunner.FileList = []string{os.Getenv(envTfplanEnabled)}
	var err error
	results, err = runConfTest()
	return err
}

func (p ProbeStruct) theKubernetesWebUIIsUnspecifiedInTheManifest() error {
	return godog.ErrPending
}
