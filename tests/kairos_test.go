package bundles_test

import (
	"os"
	"path/filepath"

	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"
)

var _ = Describe("kairos test", Label("kairos"), func() {

	BeforeEach(func() {
		prepareBundle()
	})
	AfterEach(func() {
		cleanBundle()
	})

	It("Deploy kairos crds with default version", func() {
		runBundle()
		dat, err := os.ReadFile(filepath.Join("/var/lib/rancher/k3s/server/manifests", "kairos-crds.yaml"))
		content := string(dat)
		Expect(err).ToNot(HaveOccurred())
		Expect(content).To(ContainSubstring("version: \"0.0.13\""))
	})

	It("Specifiy version for calico", func() {
		err := os.WriteFile("/oem/foo.yaml", []byte(`#cloud-config
kairos:
 crds:
  version: "magrathea"
 osbuilder:
  enable: true
  version: "foobar"
 entangle:
  enable: true
  version: "baz"
 entangleProxy:
  enable: true
  version: "42.1.1"
`), 0655)
		Expect(err).ToNot(HaveOccurred())
		runBundle()
		dat, err := os.ReadFile(filepath.Join("/var/lib/rancher/k3s/server/manifests", "kairos-crds.yaml"))
		content := string(dat)
		Expect(err).ToNot(HaveOccurred())
		Expect(content).To(ContainSubstring("version: \"magrathea\""))

		dat, err = os.ReadFile(filepath.Join("/var/lib/rancher/k3s/server/manifests", "kairos-osbuilder.yaml"))
		content = string(dat)
		Expect(err).ToNot(HaveOccurred())
		Expect(content).To(ContainSubstring("version: \"foobar\""), content)

		dat, err = os.ReadFile(filepath.Join("/var/lib/rancher/k3s/server/manifests", "kairos-entangle.yaml"))
		content = string(dat)
		Expect(err).ToNot(HaveOccurred())
		Expect(content).To(ContainSubstring("version: \"baz\""), content)

		dat, err = os.ReadFile(filepath.Join("/var/lib/rancher/k3s/server/manifests", "kairos-entangle-proxy.yaml"))
		content = string(dat)
		Expect(err).ToNot(HaveOccurred())
		Expect(content).To(ContainSubstring("version: \"42.1.1\""), content)
	})
})
