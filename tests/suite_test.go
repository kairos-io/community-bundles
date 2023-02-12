package bundles_test

import (
	"fmt"
	"os"
	"os/exec"
	"testing"

	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"
)

func SH(c string) (string, error) {
	cmd := exec.Command("/bin/sh", "-c", c)
	cmd.Env = os.Environ()
	o, err := cmd.CombinedOutput()
	return string(o), err
}

func TestSuite(t *testing.T) {
	RegisterFailHandler(Fail)
	RunSpecs(t, "Kubemedia Test Suite")
}

func runBundle() {
	out, err := SH("cd /bundle && ./run.sh")
	fmt.Println(out)
	ExpectWithOffset(1, err).ToNot(HaveOccurred(), out)
}

func prepareBundle() {
	SH("cp -rf /bundle /bundle.bak")
	SH("mkdir /oem")
}

func cleanBundle() {
	SH("rm -rfv /oem")
	SH("rm -rfv /var/lib/rancher/k3s/server/manifests/")
	SH("rm -rf /bundle")
	SH("cp -rf /bundle.bak /bundle")
}
