package kubemedia_test

import (
	"os"
	"path/filepath"

	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"
)

var _ = Describe("kubevirt test", Label("kubevirt"), func() {

	BeforeEach(func() {
		prepareBundle()
	})
	AfterEach(func() {
		cleanBundle()
	})

	It("deploys kubevirt operator version", func() {
		runBundle()
		dat, err := os.ReadFile(filepath.Join("/var/lib/rancher/k3s/server/manifests", "kubevirt-operator.yaml"))
		content := string(dat)
		Expect(err).ToNot(HaveOccurred())
		Expect(content).To(ContainSubstring("quay.io/kubevirt/virt-operator"))
		_, err = os.ReadFile(filepath.Join("/var/lib/rancher/k3s/server/manifests", "kubevirt-manager-ns.yaml"))
		Expect(err).To(HaveOccurred())
	})

	It("Add manager", func() {
		err := os.WriteFile("/oem/foo.yaml", []byte(`#cloud-config
kubevirt:
 manager: true`), 0655)
		Expect(err).ToNot(HaveOccurred())
		runBundle()
		dat, err := os.ReadFile(filepath.Join("/var/lib/rancher/k3s/server/manifests", "kubevirt-manager-ns.yaml"))
		content := string(dat)
		Expect(err).ToNot(HaveOccurred())
		Expect(content).To(ContainSubstring("kubevirt-manager.io/version: 1.1.2"))
	})
})
