package bundles_test

import (
	"encoding/json"
	"fmt"
	"os"

	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"
	"gopkg.in/yaml.v3"
)

var _ = Describe("multus test", Label("multus"), func() {

	BeforeEach(func() {
		prepareBundle()
		SH("apk add openssl jq")
		SH("mkdir -p /opt/cni/bin")
		SH("mkdir -p /var/lib/rancher/k3s/data/current/bin")
		SH("mkdir -p /var/lib/rancher/k3s/agent/etc/cni/net.d/multus.d")
		SH("mkdir -p /var/lib/rancher/k3s/server/tls")
		SH(`
cd /var/lib/rancher/k3s/server/tls/ &&
openssl genrsa -out server-ca.key 4096 &&
openssl genrsa -out client-ca.key 4096 &&
openssl req -x509 -new -nodes -sha256 -days 1 -subj /CN=server-ca -key server-ca.key -out server-ca.crt &&
openssl req -x509 -new -nodes -sha256 -days 1 -subj /CN=client-ca -key client-ca.key -out client-ca.crt`)

		err := os.WriteFile("/var/lib/rancher/k3s/agent/etc/cni/net.d/foo.conflist", []byte(`{
 "name": "cbr0",
 "cniVersion": "1.0.0",
 "plugins": [
  { "type": "portmap", "capabilities": { "portMappings": true } },
  { "type": "bandwidth", "capabilities": { "bandwidth": true } }
 ]
}`), 0655)
		Expect(err).ToNot(HaveOccurred())
	})
	AfterEach(func() {
		cleanBundle()
		SH("rm -rfv /opt/cni")
		SH("rm -rfv /var/lib/rancher/k3s/data/current/bin")
		SH("rm -rfv /var/lib/rancher/k3s/agent/etc/cni")
		SH("rm -rfv /var/lib/rancher/k3s/server/tls")
	})

	It("installs multus", func() {
		runBundle()
		Expect("/var/lib/rancher/k3s/data/current/bin/multus").To(BeARegularFile())
	})

	It("installs specified plugins", func() {
		err := os.WriteFile("/oem/multus.yaml", []byte(`#cloud-config
multus:
 cni_plugins:
  - portmap
  - macvlan`), 0655)
		Expect(err).ToNot(HaveOccurred())

		cfg, _ := SH("kairos-agent config get multus")
		fmt.Println(cfg)
		runBundle()
		Expect("/opt/cni/bin/portmap").To(BeARegularFile())
		Expect("/opt/cni/bin/macvlan").To(BeARegularFile())
		Expect("/opt/cni/bin/dhcp").ToNot(BeARegularFile())
	})

	It("creates manifests", func() {
		runBundle()
		dat, err := os.ReadFile("/var/lib/rancher/k3s/server/manifests/multus.yaml")
		content := string(dat)
		Expect(err).ToNot(HaveOccurred())
		Expect(content).To(MatchRegexp("(?m)^kind: CustomResourceDefinition$"))
		Expect(content).To(MatchRegexp("(?m)^kind: ClusterRole$"))
		Expect(content).To(MatchRegexp("(?m)^kind: ClusterRoleBinding$"))
	})

	It("creates a kubeconfig", func() {
		runBundle()
		dat, err := os.ReadFile("/var/lib/rancher/k3s/agent/etc/cni/net.d/multus.d/multus.kubeconfig")
		Expect(err).ToNot(HaveOccurred())
		err = yaml.Unmarshal(dat, struct{}{})
		Expect(err).ToNot(HaveOccurred())
	})

	It("wraps an existing config", func() {
		runBundle()
		dat, err := os.ReadFile("/var/lib/rancher/k3s/agent/etc/cni/net.d/00-multus.conflist")
		Expect(err).ToNot(HaveOccurred())

		config := &struct {
			CniVersion string
			Plugins    []struct {
				Capabilities map[string]bool
				Delegates    []struct{ Name string }
			}
		}{}

		json.Unmarshal(dat, &config)
		Expect(config.CniVersion).To(Equal("1.0.0"))
		Expect(config.Plugins[0].Capabilities).To(Equal(map[string]bool{
			"portMappings": true,
			"bandwidth":    true,
		}))
	})
})
