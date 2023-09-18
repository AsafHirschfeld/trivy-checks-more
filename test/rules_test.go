package test

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/stretchr/testify/require"

	"github.com/aquasecurity/defsec/pkg/framework"
	"github.com/aquasecurity/trivy-policies/internal/rules"
)

func TestAVDIDs(t *testing.T) {
	existing := make(map[string]struct{})
	for _, rule := range rules.GetFrameworkRules(framework.ALL) {
		t.Run(rule.GetRule().LongID(), func(t *testing.T) {
			if rule.GetRule().AVDID == "" {
				t.Errorf("Rule has no AVD ID: %#v", rule)
				return
			}
			if _, ok := existing[rule.GetRule().AVDID]; ok {
				t.Errorf("Rule detected with duplicate AVD ID: %s", rule.GetRule().AVDID)
			}
		})
		existing[rule.GetRule().AVDID] = struct{}{}
	}
}

func TestRulesAgainstExampleCode(t *testing.T) {
	for _, rule := range rules.GetFrameworkRules(framework.ALL) {
		testName := fmt.Sprintf("%s/%s", rule.GetRule().AVDID, rule.GetRule().LongID())
		t.Run(testName, func(t *testing.T) {
			rule := rule
			t.Parallel()

			t.Run("avd docs", func(t *testing.T) {
				provider := strings.ToLower(rule.GetRule().Provider.ConstName())
				service := strings.ToLower(strings.ReplaceAll(rule.GetRule().Service, "-", ""))
				_, err := os.Stat(filepath.Join("..", "avd_docs", provider, service, rule.GetRule().AVDID, "docs.md"))
				require.NoError(t, err)
			})
		})
	}
}
