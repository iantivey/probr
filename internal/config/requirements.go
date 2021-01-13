package config

var Requirements = map[string][]string{
	"Storage":    []string{"Provider"},
	"OPA":        []string{"Provider"},
	"Kubernetes": []string{"AuthorisedContainerRegistry", "UnauthorisedContainerRegistry"},
}
