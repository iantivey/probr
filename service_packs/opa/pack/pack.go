package storage_pack

import (
	"github.com/citihub/probr/internal/config"
	"github.com/citihub/probr/internal/coreengine"
	aks_general "github.com/citihub/probr/service_packs/opa/aks/general"
)

func GetProbes() []coreengine.Probe {
	if config.Vars.ServicePacks.OPA.IsExcluded() {
		return nil
	}
	switch config.Vars.ServicePacks.OPA.Provider {
	case "Azure":
		return []coreengine.Probe{
			aks_general.Probe,
		}
	default:
		return nil
	}
}
