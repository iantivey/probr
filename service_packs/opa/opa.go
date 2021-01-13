package opautil

import (
	"context"
	"fmt"

	cnftoutput "github.com/open-policy-agent/conftest/output"
	cnftparser "github.com/open-policy-agent/conftest/parser"
	cnftpolicy "github.com/open-policy-agent/conftest/policy"
)

type ConfTestRunner struct {
	FileList    []string
	PolicyPaths []string
	cnftengine  *cnftpolicy.Engine
}

func (c *ConfTestRunner) LoadPolicies(ctx context.Context) error {
	var err error
	c.cnftengine, err = cnftpolicy.Load(ctx, c.PolicyPaths)
	if err != nil {
		return err
	}
	if len(c.cnftengine.Policies()) == 0 {
		return fmt.Errorf("No policies found")
	}
	return nil
	//fmt.Printf("Number of policies loaded = %v\n", len(cnftengine.Policies()))
}

func (c *ConfTestRunner) RunConfTest(ctx context.Context) ([]cnftoutput.CheckResult, error) {

	configs, err := cnftparser.ParseConfigurations(c.FileList)
	if err != nil {
		return nil, err
	}

	namespaces := c.cnftengine.Namespaces()

	var results []cnftoutput.CheckResult

	for _, namespace := range namespaces {
		result, err := c.cnftengine.Check(ctx, configs, namespace)
		if err != nil {
			return nil, err
		}
		results = append(results, result...)
	}

	return results, nil
}
