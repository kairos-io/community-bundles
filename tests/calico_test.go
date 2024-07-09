package bundles_test

import (
	"os"
	"path/filepath"

	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"
)

var _ = Describe("calico test", Label("calico"), func() {

	BeforeEach(func() {
		prepareBundle()
	})
	AfterEach(func() {
		cleanBundle()
	})

	It("Deploy calico with default version", func() {
		runBundle()
		dat, err := os.ReadFile(filepath.Join("/var/lib/rancher/k3s/server/manifests", "calico.yaml"))
		content := string(dat)
		Expect(err).ToNot(HaveOccurred())
		// renovate: depName=tigera-operator repoUrl=https://docs.tigera.io/calico/charts
		Expect(content).To(ContainSubstring("version: \"v3.28.0\""))
	})

	It("Specifiy major version for calico", func() {
		err := os.WriteFile("/oem/foo.yaml", []byte(`#cloud-config
calico:
 version: 1`), 0655)
		Expect(err).ToNot(HaveOccurred())

		runBundle()
		dat, err := os.ReadFile(filepath.Join("/var/lib/rancher/k3s/server/manifests", "calico.yaml"))
		content := string(dat)
		Expect(err).ToNot(HaveOccurred())
		Expect(content).To(ContainSubstring("version: \"1\""))
	})

	It("Specifiy full version for calico", func() {
		err := os.WriteFile("/oem/foo.yaml", []byte(`#cloud-config
calico:
 version: 1.2.3`), 0655)
		Expect(err).ToNot(HaveOccurred())

		runBundle()
		dat, err := os.ReadFile(filepath.Join("/var/lib/rancher/k3s/server/manifests", "calico.yaml"))
		content := string(dat)
		Expect(err).ToNot(HaveOccurred())
		Expect(content).To(ContainSubstring("version: \"1.2.3\""))
	})

	It("Deploy calico with default values", func() {
		runBundle()
		dat, err := os.ReadFile(filepath.Join("/var/lib/rancher/k3s/server/manifests", "calico.yaml"))
		content := string(dat)
		Expect(err).ToNot(HaveOccurred())
		Expect(content).To(ContainSubstring("valuesContent: |-\n    {}"))
	})

	It("Specifiy installation values for calico", func() {
		err := os.WriteFile("/oem/foo.yaml", []byte(`#cloud-config
calico:
 values:
  installation:
   calicoNetwork:
    bgp: Disabled
`), 0655)
		Expect(err).ToNot(HaveOccurred())

		runBundle()
		dat, err := os.ReadFile(filepath.Join("/var/lib/rancher/k3s/server/manifests", "calico.yaml"))
		content := string(dat)
		Expect(err).ToNot(HaveOccurred())
		Expect(content).To(ContainSubstring("valuesContent: |-\n    {\"installation\":{\"calicoNetwork\":{\"bgp\":\"Disabled\"}}}"))
	})
})
