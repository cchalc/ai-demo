# AI 应用云原生最佳实践

这个案例包含了 [训练任务](train.py) 和 [推理服务](api.py) 两个应用。

对于 AI 应用开发者来说，操作流程如下：

- 写业务逻辑代码，即 src/ 里的文件
- 配置 [app.yaml](./app.yaml)
- 剩下的一键 `dagger up` 即可，包括
  - build & deploy orchestration
  - infrastructure resources rendering


## Prerequisite

Install [derrick](https://github.com/hongchaodeng/derrick):

```
```

## Quickstart

Generate deployment manifest scaffolds by detecting the code framework:

```
derrick gen
```

Just git commit these new changes and trigger Github actions to run CICD:

```
git add .
git commit -m "ship it"
git push
```

### Behind the scene

It first sets up a Dagger environment:

```
dagger init
dagger new test -p plans/ai-demo
```

Then it inputs parameter values:

```
dagger input text kubeconfig -f ${KUBECONFIG}
dagger input yaml parameters -f app.yaml
dagger input dir source ./src/
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
[✔] source
[✔] image
[✔] push.source
[+] push.push
[✔] applyResources."1"
[✔] applyResources."0"
[✔] applyResources."2"
[✔] applyResources."3"
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
	generateResource: "autoscaling/v2beta1": HorizontalPodAutoscaler: "\(parameters.metadata.namespace)": "\(parameters.metadata.name)": spec: {
		...
	}
}

if parameters.deploy.scaling.manual != _|_ {
	generateResource: "apps/v1": Deployment: "\(parameters.metadata.namespace)": "\(parameters.metadata.name)": spec: replicas: parameters.deploy.scaling.manual.replicas
}
```

