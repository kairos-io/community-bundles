package bundles_test

import (
	"os"

	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"
)

var _ = Describe("qemu-guest-agent test", Label("qemu-guest-agent"), func() {

	BeforeEach(func() {
		prepareBundle()
	})
	AfterEach(func() {
		cleanBundle()
	})

	It("installs qemu-guest-agent binary", func() {
		runBundle()
		// Check that the qemu-ga binary is installed and executable
		binPath := "/usr/local/bin/qemu-ga"
		Expect(binPath).To(BeAnExistingFile())

		// Check that the binary is executable
		info, err := os.Stat(binPath)
		Expect(err).ToNot(HaveOccurred())
		Expect(info.Mode() & 0111).ToNot(BeZero()) // Check if executable bit is set
	})

	It("installs service file for detected init system", func() {
		runBundle()

		// Check for systemd service file
		systemdServicePath := "/etc/systemd/system/qemu-guest-agent.service"

		// Determine which init system is being used
		if _, err := SH("systemctl --version"); err == nil {
			// Systemd is available, check for systemd service
			Expect(systemdServicePath).To(BeAnExistingFile())

			// Read and verify systemd service file content
			dat, err := os.ReadFile(systemdServicePath)
			Expect(err).ToNot(HaveOccurred())
			content := string(dat)

			// Check for expected systemd service configuration
			Expect(content).To(ContainSubstring("Description=QEMU Guest Agent"))
			Expect(content).To(ContainSubstring("ExecStart=-/usr/local/bin/qemu-ga"))
			Expect(content).To(ContainSubstring("Restart=always"))
			Expect(content).To(ContainSubstring("WantedBy=multi-user.target"))
			Expect(content).To(ContainSubstring("BindTo=dev-virtio\\x2dports-org.qemu.guest_agent.0.device"))
		} else {
			// systemd not detected, skip service file check
			Skip("systemd not detected")
		}
	})

	It("enables and starts qemu-guest-agent service for detected init system", func() {
		runBundle()

		// Determine which init system is being used
		if _, err := SH("systemctl --version"); err == nil {
			// Systemd is available, check for systemd service enablement
			symlinkPath := "/etc/systemd/system/multi-user.target.wants/qemu-guest-agent.service"
			Expect(symlinkPath).To(BeAnExistingFile())

			// Verify the symlink points to the correct service file
			targetPath := "/etc/systemd/system/qemu-guest-agent.service"
			Expect(targetPath).To(BeAnExistingFile())

			// Check that the symlink is valid
			linkInfo, err := os.Readlink(symlinkPath)
			Expect(err).ToNot(HaveOccurred())
			Expect(linkInfo).To(Equal(targetPath))

			// Check service status if systemd is available
			out, err := SH("systemctl is-active qemu-guest-agent")
			if err == nil {
				Expect(string(out)).To(ContainSubstring("active"))
			}
		} else {
			// systemd not detected, skip service check
			Skip("systemd not detected")
		}
	})

})
