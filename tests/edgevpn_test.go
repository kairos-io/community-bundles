package bundles_test

import (
	"os"

	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"
)

var _ = Describe("edgevpn test", Label("edgevpn"), func() {

	BeforeEach(func() {
		prepareBundle()
	})
	AfterEach(func() {
		cleanBundle()
	})

	It("installs edgevpn binary", func() {
		runBundle()
		// Check that the edgevpn binary is installed and executable
		binPath := "/usr/local/bin/edgevpn"
		Expect(binPath).To(BeAnExistingFile())

		// Check that the binary is executable
		info, err := os.Stat(binPath)
		Expect(err).ToNot(HaveOccurred())
		Expect(info.Mode() & 0111).ToNot(BeZero()) // Check if executable bit is set
	})

	It("installs service file for detected init system", func() {
		runBundle()

		// Check for systemd service file
		systemdServicePath := "/etc/systemd/system/edgevpn.service"
		openrcServicePath := "/etc/init.d/edgevpn"

		// Determine which init system is being used
		if _, err := SH("systemctl --version"); err == nil {
			// Systemd is available, check for systemd service
			Expect(systemdServicePath).To(BeAnExistingFile())

			// Read and verify systemd service file content
			dat, err := os.ReadFile(systemdServicePath)
			Expect(err).ToNot(HaveOccurred())
			content := string(dat)

			// Check for expected systemd service configuration
			Expect(content).To(ContainSubstring("Description=EdgeVPN"))
			Expect(content).To(ContainSubstring("EnvironmentFile=/etc/systemd/system.conf.d/edgevpn-kairos.env"))
			Expect(content).To(ContainSubstring("ExecStart=edgevpn --api --dhcp"))
			Expect(content).To(ContainSubstring("Restart=always"))
			Expect(content).To(ContainSubstring("WantedBy=multi-user.target"))
		} else if _, err := SH("rc-update --version"); err == nil {
			// OpenRC is available, check for openrc service
			Expect(openrcServicePath).To(BeAnExistingFile())

			// Read and verify openrc service file content
			dat, err := os.ReadFile(openrcServicePath)
			Expect(err).ToNot(HaveOccurred())
			content := string(dat)

			// Check for expected openrc service configuration
			Expect(content).To(ContainSubstring("description=\"EdgeVPN service\""))
			Expect(content).To(ContainSubstring("command=\"/usr/local/bin/edgevpn\""))
			Expect(content).To(ContainSubstring("command_args=\"--api --dhcp\""))
		} else {
			// Neither systemd nor openrc detected, skip service file check
			Skip("Neither systemd nor openrc detected")
		}
	})

	It("creates environment configuration for detected init system", func() {
		runBundle()

		// Check for systemd environment configuration
		systemdEnvPath := "/etc/systemd/system.conf.d/edgevpn-kairos.env"
		openrcEnvPath := "/etc/conf.d/edgevpn"

		// Determine which init system is being used
		if _, err := SH("systemctl --version"); err == nil {
			// Systemd is available, check for systemd environment
			Expect(systemdEnvPath).To(BeAnExistingFile())

			// Read and verify systemd environment file content
			dat, err := os.ReadFile(systemdEnvPath)
			Expect(err).ToNot(HaveOccurred())
			content := string(dat)

			// Check that the file contains the TOKEN variable definition
			Expect(content).To(ContainSubstring("EDGEVPNTOKEN="))
		} else if _, err := SH("rc-update --version"); err == nil {
			// OpenRC is available, check for openrc environment
			Expect(openrcEnvPath).To(BeAnExistingFile())

			// Read and verify openrc environment file content
			dat, err := os.ReadFile(openrcEnvPath)
			Expect(err).ToNot(HaveOccurred())
			content := string(dat)

			// Check that the file contains the TOKEN variable definition
			Expect(content).To(ContainSubstring("EDGEVPNTOKEN="))
		} else {
			// Neither systemd nor openrc detected, skip environment check
			Skip("Neither systemd nor openrc detected")
		}
	})

	It("enables and starts edgevpn service for detected init system", func() {
		runBundle()

		// Determine which init system is being used
		if _, err := SH("systemctl --version"); err == nil {
			// Systemd is available, check for systemd service enablement
			symlinkPath := "/etc/systemd/system/multi-user.target.wants/edgevpn.service"
			Expect(symlinkPath).To(BeAnExistingFile())

			// Verify the symlink points to the correct service file
			targetPath := "/etc/systemd/system/edgevpn.service"
			Expect(targetPath).To(BeAnExistingFile())

			// Check that the symlink is valid
			linkInfo, err := os.Readlink(symlinkPath)
			Expect(err).ToNot(HaveOccurred())
			Expect(linkInfo).To(Equal(targetPath))

			// Check service status if systemd is available
			out, err := SH("systemctl is-active edgevpn")
			if err == nil {
				Expect(string(out)).To(ContainSubstring("active"))
			}
		} else if _, err := SH("rc-update --version"); err == nil {
			// OpenRC is available, check for openrc service enablement
			// Check if service is enabled in default runlevel
			out, err := SH("rc-update show default")
			Expect(err).ToNot(HaveOccurred(), out)
			Expect(string(out)).To(ContainSubstring("edgevpn"))

			// Check service status if openrc is available
			out, err = SH("rc-service edgevpn status")
			if err == nil {
				Expect(string(out)).To(ContainSubstring("started"))
			}
		} else {
			// Neither systemd nor openrc detected, skip service check
			Skip("Neither systemd nor openrc detected")
		}
	})

})
