package bundles_test

import (
	"os"
	"path/filepath"

	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"
)

var _ = Describe("localai test", Label("LocalAI"), func() {

	BeforeEach(func() {
		prepareBundle()
	})
	AfterEach(func() {
		cleanBundle()
	})

	It("sets default version", func() {
		runBundle()
		dat, err := os.ReadFile(filepath.Join("/var/lib/rancher/k3s/server/manifests", "localai.yaml"))
		content := string(dat)
		Expect(err).ToNot(HaveOccurred())
		// renovate: depName=local-ai repoUrl=https://go-skynet.github.io/helm-charts/
		Expect(content).To(MatchRegexp("version: \".*?\""))
	})

	It("sets the service type", func() {
		err := os.WriteFile("/oem/foo.yaml", []byte(`#cloud-config
localai:
  serviceType: LoadBalancer`), 0655)
		Expect(err).ToNot(HaveOccurred())

		runBundle()
		dat, err := os.ReadFile(filepath.Join("/var/lib/rancher/k3s/server/manifests", "localai.yaml"))
		content := string(dat)
		Expect(err).ToNot(HaveOccurred())
		Expect(content).To(ContainSubstring("type: \"LoadBalancer\""))
	})
})
