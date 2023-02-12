package bundles_test

import (
	"os"
	"path/filepath"

	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"
)

var _ = Describe("metallb test", Label("metallb"), func() {

	BeforeEach(func() {
		prepareBundle()
	})
	AfterEach(func() {
		cleanBundle()
	})

	It("sets default version", func() {
		runBundle()
		dat, err := os.ReadFile(filepath.Join("/var/lib/rancher/k3s/server/manifests", "metallb.yaml"))
		content := string(dat)
		Expect(err).ToNot(HaveOccurred())
		Expect(content).To(ContainSubstring("https://github.com/metallb/metallb/releases/download/metallb-chart-0.13.7/metallb-0.13.7.tgz"))
		dat, err = os.ReadFile(filepath.Join("/var/lib/rancher/k3s/server/manifests", "addresspool.yaml"))
		content = string(dat)
		Expect(err).ToNot(HaveOccurred())
		Expect(content).To(ContainSubstring("- 192.168.1.10-192.168.1.20"))
	})

	It("set version", func() {
		err := os.WriteFile("/oem/foo.yaml", []byte(`#cloud-config
metallb:
 version: 1`), 0655)
		Expect(err).ToNot(HaveOccurred())

		runBundle()
		dat, err := os.ReadFile(filepath.Join("/var/lib/rancher/k3s/server/manifests", "metallb.yaml"))
		content := string(dat)
		Expect(err).ToNot(HaveOccurred())
		Expect(content).To(ContainSubstring("https://github.com/metallb/metallb/releases/download/metallb-chart-1/metallb-1.tgz"))
	})
})
