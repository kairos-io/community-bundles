package bundles_test

import (
	"os"
	"path/filepath"

	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"
)

var _ = Describe("kairos-operator test", Label("kairos-operator"), func() {

	BeforeEach(func() {
		prepareBundle()
	})
	AfterEach(func() {
		cleanBundle()
	})

	It("it uses the default k0s directory", func() {
		err := os.WriteFile("/oem/foo.yaml", []byte(`#cloud-config
k0s:
 enabled: true`), 0655)
		Expect(err).ToNot(HaveOccurred())
		runBundle()
		Expect(filepath.Join("/var/lib/k0s/manifests/kairos-operator", "kairos-operator.yaml")).To(BeARegularFile())
	})

	It("it uses the default k3s directory", func() {
		err := os.WriteFile("/oem/foo.yaml", []byte(`#cloud-config
k3s:
 enabled: true`), 0655)
		Expect(err).ToNot(HaveOccurred())
		runBundle()
		Expect(filepath.Join("/var/lib/rancher/k3s/server/manifests", "kairos-operator.yaml")).To(BeARegularFile())
	})

	It("it uses the custom directory", func() {
		err := os.WriteFile("/oem/foo.yaml", []byte(`#cloud-config
kairosOperator:
 manifest_dir: /foobar`), 0655)
		Expect(err).ToNot(HaveOccurred())
		runBundle()
		Expect(filepath.Join("/foobar", "kairos-operator.yaml")).To(BeARegularFile())
	})
})
