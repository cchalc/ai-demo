package ml

// Dynamically adds a capability to the app by adding a new code file.
generateResource: "monitoring.coreos.com/v1": ServiceMonitor: "\(parameters.metadata.namespace)": "\(parameters.metadata.name)": spec: {
	selector: matchLabels: app: parameters.metadata.name
	endpoints: [{
		targetPort: parameters.deploy.port
	}]
}
