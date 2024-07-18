package bundles_test

import (
	"os"
	"path/filepath"

	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"
)

const (
	manifestDir  = "/var/lib/rancher/k3s/server/manifests"
	manifestFile = "ingress-nginx.yaml"
)

var _ = Describe("nginx test", Label("nginx"), func() {

	BeforeEach(func() {
		prepareBundle()
	})
	AfterEach(func() {
		cleanBundle()
	})

	It("sets default version", func() {
		runBundle()
		dat, err := os.ReadFile(filepath.Join(manifestDir, manifestFile))
		content := string(dat)
		Expect(err).ToNot(HaveOccurred())
		// renovate: depName=ingress-nginx repoUrl=https://kubernetes.github.io/ingress-nginx
		Expect(content).To(ContainSubstring("version: \"4.11.1\""))
	})

	It("set major version", func() {
		err := os.WriteFile("/oem/foo.yaml", []byte(`#cloud-config
nginx:
 version: 1`), 0655)
		Expect(err).ToNot(HaveOccurred())

		runBundle()
		dat, err := os.ReadFile(filepath.Join(manifestDir, manifestFile))
		content := string(dat)
		Expect(err).ToNot(HaveOccurred())
		Expect(content).To(ContainSubstring("version: \"1\""))
	})

	It("set full version", func() {
		err := os.WriteFile("/oem/foo.yaml", []byte(`#cloud-config
nginx:
 version: 1.2.3`), 0655)
		Expect(err).ToNot(HaveOccurred())

		runBundle()
		dat, err := os.ReadFile(filepath.Join(manifestDir, manifestFile))
		content := string(dat)
		Expect(err).ToNot(HaveOccurred())
		Expect(content).To(ContainSubstring("version: \"1.2.3\""))
	})

	It("deploy with default values", func() {
		runBundle()
		dat, err := os.ReadFile(filepath.Join(manifestDir, manifestFile))
		content := string(dat)
		Expect(err).ToNot(HaveOccurred())
		Expect(content).To(ContainSubstring("valuesContent: |-\n    {}"))
	})

	It("specifiy values", func() {
		err := os.WriteFile("/oem/foo.yaml", []byte(`#cloud-config
nginx:
 values:
  commonLabels:
   myLabel: abc123`), 0655)
		Expect(err).ToNot(HaveOccurred())

		runBundle()
		dat, err := os.ReadFile(filepath.Join(manifestDir, manifestFile))
		content := string(dat)
		Expect(err).ToNot(HaveOccurred())
		Expect(content).To(ContainSubstring("valuesContent: |-\n    {\"commonLabels\":{\"myLabel\":\"abc123\"}}"))
	})
})
