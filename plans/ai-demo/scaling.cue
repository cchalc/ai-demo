package ml

// Dynamically adds a capability and exposes the parameters to the app.
parameters: #deploy: scaling: {
	{
		auto: {
			min: int
			max: int
		}
	} | {
		manual: replicas: int
	}
}

if parameters.deploy.scaling.auto != _|_ {
	generateResource: "autoscaling/v1:HorizontalPodAutoscaler:\(parameters.metadata.namespace):\(parameters.metadata.name)": {
		apiVersion: "autoscaling/v1"
		kind:       "HorizontalPodAutoscaler"
		metadata: {
			name:      parameters.metadata.name
			namespace: parameters.metadata.namespace
			labels: "app.kubernetes.io/name": parameters.metadata.name
		}
		spec: {
			scaleTargetRef: {
				apiVersion: "apps/v1"
				kind:       "Deployment"
				name:       parameters.metadata.name
			}
			minReplicas: parameters.deploy.scaling.auto.min
			maxReplicas: parameters.deploy.scaling.auto.max
		}
	}
}

if parameters.deploy.scaling.manual != _|_ {
	// directly updates the deployment resource's replicas
	generateResource: "apps/v1:Deployment:\(parameters.metadata.namespace):\(parameters.metadata.name)": spec: replicas: parameters.deploy.scaling.manual.replicas
}
