package bundles_test

import (
	"os"

	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"
)

var _ = Describe("k9s test", Label("k9s"), func() {

	BeforeEach(func() {
		prepareBundle()
	})
	AfterEach(func() {
		cleanBundle()
	})

	It("installs k9s binary correctly", func() {
		runBundle()

		// Check if k9s binary exists in /usr/local/bin (mutable path)
		info, err := os.Stat("/usr/local/bin/k9s")
		Expect(err).ToNot(HaveOccurred())

		// Check if the file is executable
		Expect(info.Mode()&0111).ToNot(BeZero(), "k9s binary should be executable")

		// Check file size to ensure it's not empty
		Expect(info.Size()).To(BeNumerically(">", 0), "k9s binary should not be empty")
	})
})
