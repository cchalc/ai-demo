package ml

import (
	"encoding/json"

	"alpha.dagger.io/kubernetes"
)

// set with `dagger input text kubeconfig -f "$HOME"/.kube/config -e kube`
kubeconfig: {string} @dagger(input)

applyResources: {
	for i, resource in resources {
		"\(i)": kubernetes.#Resources & {
			"kubeconfig": kubeconfig
			version:      "v1.23.3"
			namespace:    resource.metadata.namespace
			manifest:     json.Marshal(resource)
		}
	}
}
