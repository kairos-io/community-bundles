package bundles_test

import (
	"os"
	"path/filepath"

	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"
)

var _ = Describe("kairos-operator test", Label("kairos-operator"), func() {

	BeforeEach(func() {
		prepareBundle()
	})
	AfterEach(func() {
		cleanBundle()
	})

	It("deploys default kairos operator version", func() {
		err := os.WriteFile("/oem/foo.yaml", []byte(`#cloud-config
kairos-operator:
 k0s: true`), 0655)
		Expect(err).ToNot(HaveOccurred())
		runBundle()
		dat, err := os.ReadFile(filepath.Join("/var/lib/k0s/manifests/kairos-operator", "kairos-operator.yaml"))
		content := string(dat)
		Expect(err).ToNot(HaveOccurred())
		Expect(content).To(ContainSubstring("v0.0.1"))
	})

	It("Specific version", func() {
		err := os.WriteFile("/oem/foo.yaml", []byte(`#cloud-config
kairos-operator:
 version: v1.2.3
 k0s: true`), 0655)
		Expect(err).ToNot(HaveOccurred())
		runBundle()
		dat, err := os.ReadFile(filepath.Join("/var/lib/k0s/manifests/kairos-operator", "kairos-operator.yaml"))
		content := string(dat)
		Expect(err).ToNot(HaveOccurred())
		Expect(content).To(ContainSubstring("v1.2.3"))
	})
})
