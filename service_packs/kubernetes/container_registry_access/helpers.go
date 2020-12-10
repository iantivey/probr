package container_registry_access

import (
	"strings"

	"github.com/citihub/probr/internal/config"
	"github.com/citihub/probr/internal/coreengine"
	"github.com/citihub/probr/internal/summary"
	"github.com/citihub/probr/service_packs/kubernetes"
	"github.com/cucumber/godog"
	apiv1 "k8s.io/api/core/v1"
)

const (
	caNamespace   = "probr-container-access-test-ns"
	caContainer   = "container-access-test"
	caPodNameBase = "ca-test"
)

// ContainerRegistryAccess interface defines the methods to support container registry access tests.
type ContainerRegistryAccess interface {
	ClusterIsDeployed() *bool
	SetupContainerAccessProbePod(r string, probe *summary.Probe) (*apiv1.Pod, *kubernetes.PodAudit, error)
	TeardownContainerAccessProbePod(p string, e string) error
}

// CRA implements the ContainerRegistryAccess interface.
type CRA struct {
	k kubernetes.Kubernetes
}

type scenarioState struct {
	name           string
	audit          *summary.ScenarioAudit
	probe          *summary.Probe
	httpStatusCode int
	podName        string
	podState       kubernetes.PodState
	useDefaultNS   bool
	wildcardRoles  interface{}
}

// NewCRA creates a new CRA with the supplied kubernetes instance.
func NewCRA(k kubernetes.Kubernetes) *CRA {
	c := &CRA{}
	c.k = k

	return c
}

// NewDefaultCRA creates a new CRA using the default kubernetes instance.
func NewDefaultCRA() *CRA {
	c := &CRA{}
	c.k = kubernetes.GetKubeInstance()

	return c
}

// ClusterIsDeployed verifies if a cluster is deployed.
func (c *CRA) ClusterIsDeployed() *bool {
	return c.k.ClusterIsDeployed()
}

//SetupContainerAccessProbePod creates a pod with characteristics required for testing container access.
func (c *CRA) SetupContainerAccessProbePod(r string, probe *summary.Probe) (*apiv1.Pod, *kubernetes.PodAudit, error) {
	//full image is the repository + the configured image
	i := r + "/" + config.Vars.ServicePacks.Kubernetes.ProbeImage
	pname := kubernetes.GenerateUniquePodName(caPodNameBase + "-" + strings.ReplaceAll(r, ".", "-"))
	ns, cname := caNamespace, caContainer
	// let caller handle result ...
	return c.k.CreatePod(pname, ns, cname, i, true, nil, probe)
}

//TeardownContainerAccessProbePod deletes the supplied test pod in the container registry access namespace.
func (c *CRA) TeardownContainerAccessProbePod(p string, e string) error {
	err := c.k.DeletePod(p, caNamespace, e) //don't worry about waiting
	return err
}

func beforeScenario(s *scenarioState, probeName string, gs *godog.Scenario) {
	s.name = gs.Name
	s.probe = summary.State.GetProbeLog(probeName)
	s.audit = summary.State.GetProbeLog(probeName).InitializeAuditor(gs.Name, gs.Tags)
	coreengine.LogScenarioStart(gs)
}
