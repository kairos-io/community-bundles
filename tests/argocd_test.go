package bundles_test

import (
	"os"
	"path/filepath"

	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"
)

var _ = Describe("argocd test", Label("argocd"), func() {

	BeforeEach(func() {
		prepareBundle()
	})
	AfterEach(func() {
		cleanBundle()
	})

	It("Deploy argocd with default version", func() {
		runBundle()
		dat, err := os.ReadFile(filepath.Join("/var/lib/rancher/k3s/server/manifests", "argocd.yaml"))
		content := string(dat)
		Expect(err).ToNot(HaveOccurred())
		Expect(content).To(MatchRegexp("version: \".*?\""))
	})

	It("Specifiy version for argocd", func() {
		err := os.WriteFile("/oem/foo.yaml", []byte(`#cloud-config
argocd:
 version: 1`), 0655)
		Expect(err).ToNot(HaveOccurred())

		runBundle()
		dat, err := os.ReadFile(filepath.Join("/var/lib/rancher/k3s/server/manifests", "argocd.yaml"))
		content := string(dat)
		Expect(err).ToNot(HaveOccurred())
		Expect(content).To(ContainSubstring("version: \"1\""))
	})

	It("Deploy argocd with default values", func() {
		runBundle()
		dat, err := os.ReadFile(filepath.Join("/var/lib/rancher/k3s/server/manifests", "argocd.yaml"))
		content := string(dat)
		Expect(err).ToNot(HaveOccurred())
		Expect(content).To(ContainSubstring("valuesContent: |-\n    {}"))
	})

	It("Specifiy installation values for argocd", func() {
		err := os.WriteFile("/oem/foo.yaml", []byte(`#cloud-config
argocd:
 values:
  installation:
   calicoNetwork:
    bgp: Disabled
`), 0655)
		Expect(err).ToNot(HaveOccurred())

		runBundle()
		dat, err := os.ReadFile(filepath.Join("/var/lib/rancher/k3s/server/manifests", "argocd.yaml"))
		content := string(dat)
		Expect(err).ToNot(HaveOccurred())
		Expect(content).To(ContainSubstring("valuesContent: |-\n    {\"installation\":{\"calicoNetwork\":{\"bgp\":\"Disabled\"}}}"))
	})
})
