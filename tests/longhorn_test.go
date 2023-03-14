package bundles_test

import (
	"os"
	"path/filepath"

	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"
)

var _ = Describe("longhorn test", Label("longhorn"), func() {

	BeforeEach(func() {
		prepareBundle()
	})
	AfterEach(func() {
		cleanBundle()
	})

	It("Deploy longhorn with default version", func() {
		runBundle()
		dat, err := os.ReadFile(filepath.Join("/var/lib/rancher/k3s/server/manifests", "longhorn.yaml"))
		content := string(dat)
		Expect(err).ToNot(HaveOccurred())
		// renovate: depName=longhorn repoUrl=https://charts.longhorn.io
		Expect(content).To(ContainSubstring("version: 1.4.0"))
	})

	It("Specifiy version for longhorn", func() {
		err := os.WriteFile("/oem/foo.yaml", []byte(`#cloud-config
longhorn:
 version: 1`), 0655)
		Expect(err).ToNot(HaveOccurred())

		runBundle()
		dat, err := os.ReadFile(filepath.Join("/var/lib/rancher/k3s/server/manifests", "longhorn.yaml"))
		content := string(dat)
		Expect(err).ToNot(HaveOccurred())
		Expect(content).To(ContainSubstring("version: 1"))
	})

	It("Deploy longhorn with default values", func() {
		runBundle()
		dat, err := os.ReadFile(filepath.Join("/var/lib/rancher/k3s/server/manifests", "longhorn.yaml"))
		content := string(dat)
		Expect(err).ToNot(HaveOccurred())
		Expect(content).To(ContainSubstring("valuesContent: |-\n    {}"))
	})

	It("Specifiy installation values for longhorn", func() {
		err := os.WriteFile("/oem/foo.yaml", []byte(`#cloud-config
longhorn:
 values:
  defaultSettings:
   backupstorePollInterval: 600
`), 0655)
		Expect(err).ToNot(HaveOccurred())

		runBundle()
		dat, err := os.ReadFile(filepath.Join("/var/lib/rancher/k3s/server/manifests", "longhorn.yaml"))
		content := string(dat)
		Expect(err).ToNot(HaveOccurred())
		Expect(content).To(ContainSubstring("valuesContent: |-\n    {\"defaultSettings\":{\"backupstorePollInterval\":600}}"))
	})
})
