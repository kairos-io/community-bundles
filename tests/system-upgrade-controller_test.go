package bundles_test

import (
	"os"
	"path/filepath"

	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"
)

var _ = Describe("system-upgrade-controller test", Label("system-upgrade-controller"), func() {

	BeforeEach(func() {
		prepareBundle()
	})
	AfterEach(func() {
		cleanBundle()
	})

	It("deploys default suc operator version", func() {
		runBundle()
		dat, err := os.ReadFile(filepath.Join("/var/lib/rancher/k3s/server/manifests", "system-upgrade-controller.yaml"))
		content := string(dat)
		Expect(err).ToNot(HaveOccurred())
		Expect(content).To(ContainSubstring("rancher/system-upgrade-controller"))
	})

	It("Specific version", func() {
		err := os.WriteFile("/oem/foo.yaml", []byte(`#cloud-config
suc:
 version: foobar`), 0655)
		Expect(err).ToNot(HaveOccurred())
		runBundle()
		dat, err := os.ReadFile(filepath.Join("/var/lib/rancher/k3s/server/manifests", "system-upgrade-controller.yaml"))
		content := string(dat)
		Expect(err).ToNot(HaveOccurred())
		Expect(content).To(ContainSubstring("rancher/system-upgrade-controller:foobar"))
	})
})
