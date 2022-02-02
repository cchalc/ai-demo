package ml

parameters: {
	metadata: {
		name:      string
		namespace: string | *"default"
		stack:     string
	}

	build:  #build
	deploy: #deploy
}

#build: {
	env: [string]: string
	run: string
	...
}

#deploy: {
	cmd: [...string]
	port: int
	...
}

generateResource: "apps/v1:Deployment:\(parameters.metadata.namespace):\(parameters.metadata.name)": {
	apiVersion: "apps/v1"
	kind:       "Deployment"
	metadata: {
		name:      parameters.metadata.name
		namespace: parameters.metadata.namespace
		labels: "app.kubernetes.io/name": parameters.metadata.name
		annotations: "dev.nocalhost":     """
name: \(parameters.metadata.name)
serviceType: deployment
containers:
- name: \(parameters.metadata.name)
  dev:
    image: \(push.ref)
"""
	}

	spec: {
		selector: matchLabels: app: parameters.metadata.name
		template: {
			metadata: labels: app: parameters.metadata.name
			spec: containers: [{
				image:   push.ref
				name:    parameters.metadata.name
				command: parameters.deploy.cmd
				env: [ for k, v in parameters.build.env {
					name:  k
					value: v
				}]
				ports: [{
					containerPort: parameters.deploy.port
					protocol:      "TCP"
				}]
				resources: {
					requests: {
						memory: "1Gi"
						cpu:    "500m"
					}
					limits: {
						memory: "2Gi"
						cpu:    "1000m"
					}
				}
				livenessProbe: {
					httpGet: {
						path: "/healthz"
						port: parameters.deploy.port
					}
					initialDelaySeconds: 3
					periodSeconds:       3
				}
			}]
		}
	}
}

generateResource: "v1:Service:\(parameters.metadata.namespace):\(parameters.metadata.name)": {
	apiVersion: "v1"
	kind:       "Service"
	metadata: {
		name:      parameters.metadata.name
		namespace: parameters.metadata.namespace
		labels: "app.kubernetes.io/name": parameters.metadata.name
	}
	spec: {
		type: "ClusterIP"
		ports: [{
			port:       parameters.deploy.port
			targetPort: parameters.deploy.port
		}]
		selector: app: parameters.metadata.name
	}
}

generateResource: "networking.k8s.io/v1:Ingress:\(parameters.metadata.namespace):\(parameters.metadata.name)": {
	apiVersion: "networking.k8s.io/v1"
	kind:       "Ingress"
	metadata: {
		name:      parameters.metadata.name
		namespace: parameters.metadata.namespace
		labels: "app.kubernetes.io/name": parameters.metadata.name
	}
	metadata: annotations: "nginx.ingress.kubernetes.io/rewrite-target": "/"
	spec: rules: [{
		http: paths: [{
			path:     "/\(parameters.metadata.name)"
			pathType: "Prefix"
			backend: service: {
				name: parameters.metadata.name
				port: number: parameters.deploy.port
			}
		}]
	}]
}

resources: [
	for _, v in generateResource {
		v
	},
]
