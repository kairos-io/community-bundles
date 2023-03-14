package bundles_test

import (
	"os"
	"path/filepath"

	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"
)

var _ = Describe("kyverno test", Label("kyverno"), func() {

	BeforeEach(func() {
		prepareBundle()
	})
	AfterEach(func() {
		cleanBundle()
	})

	It("Deploy kyverno with default version", func() {
		runBundle()
		dat, err := os.ReadFile(filepath.Join("/var/lib/rancher/k3s/server/manifests", "kyverno.yaml"))
		content := string(dat)
		Expect(err).ToNot(HaveOccurred())
		Expect(content).To(MatchRegexp("version: \".*?\""))
	})

	It("Specifiy version for kyverno", func() {
		err := os.WriteFile("/oem/foo.yaml", []byte(`#cloud-config
kyverno:
 version: 1`), 0655)
		Expect(err).ToNot(HaveOccurred())

		runBundle()
		dat, err := os.ReadFile(filepath.Join("/var/lib/rancher/k3s/server/manifests", "kyverno.yaml"))
		content := string(dat)
		Expect(err).ToNot(HaveOccurred())
		Expect(content).To(ContainSubstring("version: \"1\""))
	})

	It("Deploy kyverno with default values", func() {
		runBundle()
		dat, err := os.ReadFile(filepath.Join("/var/lib/rancher/k3s/server/manifests", "kyverno.yaml"))
		content := string(dat)
		Expect(err).ToNot(HaveOccurred())
		Expect(content).To(ContainSubstring("valuesContent: |-\n    {}"))
	})

	It("Specifiy installation values for kyverno", func() {
		err := os.WriteFile("/oem/foo.yaml", []byte(`#cloud-config
kyverno:
 values:
  installation:
   calicoNetwork:
    bgp: Disabled
`), 0655)
		Expect(err).ToNot(HaveOccurred())

		runBundle()
		dat, err := os.ReadFile(filepath.Join("/var/lib/rancher/k3s/server/manifests", "kyverno.yaml"))
		content := string(dat)
		Expect(err).ToNot(HaveOccurred())
		Expect(content).To(ContainSubstring("valuesContent: |-\n    {\"installation\":{\"calicoNetwork\":{\"bgp\":\"Disabled\"}}}"))
	})
})
