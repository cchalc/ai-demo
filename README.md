# AI App Cloud Native Best Practice 

This contains the deployment code that builds and deploy an [AI application](https://github.com/hongchaodeng/ai-demo-source).

## Quickstart

Run the following command to set up a Dagger environment:

```
dagger init
dagger new test -p plans/ai-demo
```

Then input user values:

> NOTE: You need to specify $KUBECONFIG, your own docker image name and credentials.

```
dagger input yaml parameters -f app.yaml
dagger input text kubeconfig -f ${KUBECONFIG}
dagger input text push.target ghcr.io/hongchaodeng/ai-demo
dagger input text push.auth.username hongchaodeng
dagger input secret push.auth.secret ${GITHUB_TOKEN}
```

Then it runs the following command to build and deploy the app to k8s:

```
dagger up
```

Output:

```
[✔] image
[✔] push.source
[✔] push.push
[✔] applyResources."1"
[✔] applyResources."0"
[✔] applyResources."2"
[✔] applyResources."3"
[✔] patchGrafana
```


## Add a new capability

The [autoscaling.cue](./plans/ai-demo/autoscaling.cue) is an example to add a new capability to existing definitions:

```
package ml

// Dynamically adds a capability and exposes the parameters to the app.
parameters: #deploy: scaling:
	{
		auto: {
			min:        int
			max:        int
			cpuPercent: int
		}
	} | {
		manual: replicas: int
	}

if parameters.deploy.scaling.auto != _|_ {
	generateResource: "autoscaling/v1:HorizontalPodAutoscaler:\(parameters.metadata.namespace):\(parameters.metadata.name)": {
		apiVersion: "autoscaling/v1"
		kind:       "HorizontalPodAutoscaler"
		...
	}
}

if parameters.deploy.scaling.manual != _|_ {
  // directly updates the deployment resource's replicas
	generateResource: "apps/v1:Deployment:\(parameters.metadata.namespace):\(parameters.metadata.name)": spec: replicas: parameters.deploy.scaling.manual.replicas
}
```
