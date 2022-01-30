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

generateResource: [ApiVersion=_]: [Kind=_]: [Namespace=_]: [Name=_]: {
	apiVersion: ApiVersion
	kind:       Kind
	metadata: {
		name:      Name
		namespace: Namespace
		labels: {
			app: Name
			...
		}
		...
	}
	...
}

generateResource: "apps/v1": Deployment: "\(parameters.metadata.namespace)": "\(parameters.metadata.name)": {
	metadata: annotations: "dev.nocalhost": """
name: \(parameters.metadata.name)
serviceType: deployment
containers:
- name: \(parameters.metadata.name)
  dev:
    image: \(push.ref)
"""
	spec: {
		replicas: 1
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
						memory: "256Mi"
						cpu:    "250m"
					}
					limits: {
						memory: "512Mi"
						cpu:    "500m"
					}
				}
			}]
		}
	}
}

generateResource: v1: Service: "\(parameters.metadata.namespace)": "\(parameters.metadata.name)": spec: {
	type: "ClusterIP"
	ports: [{
		port:       parameters.deploy.port
		targetPort: parameters.deploy.port
	}]
	selector: app: parameters.metadata.name
}

generateResource: "networking.k8s.io/v1": Ingress: "\(parameters.metadata.namespace)": "\(parameters.metadata.name)": {
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
	for _, v1 in generateResource {
		for _, v2 in v1 {
			for _, v3 in v2 {
				for _, v4 in v3 {
					v4
				}
			}
		}
	},
]
