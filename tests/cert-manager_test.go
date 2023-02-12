package bundles_test

import (
	"os"
	"path/filepath"

	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"
)

var _ = Describe("cert-manager test", Label("cert-manager"), func() {

	BeforeEach(func() {
		prepareBundle()
	})
	AfterEach(func() {
		cleanBundle()
	})

	It("deploys cert-manager operator version", func() {
		runBundle()
		dat, err := os.ReadFile(filepath.Join("/var/lib/rancher/k3s/server/manifests", "cert-manager.yaml"))
		content := string(dat)
		Expect(err).ToNot(HaveOccurred())
		Expect(content).To(ContainSubstring("clusterissuers.cert-manager.io"))
	})

	It("Specify version for cert-manager", func() {
		err := os.WriteFile("/oem/foo.yaml", []byte(`#cloud-config
certManager:
 version: v1.11.0`), 0655)
		Expect(err).ToNot(HaveOccurred())
		runBundle()
		dat, err := os.ReadFile(filepath.Join("/var/lib/rancher/k3s/server/manifests", "cert-manager.yaml"))
		content := string(dat)
		Expect(err).ToNot(HaveOccurred())
		Expect(content).To(ContainSubstring("clusterissuers.cert-manager.io"))
	})
})
