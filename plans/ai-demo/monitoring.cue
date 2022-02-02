package ml

import (
	"encoding/json"

	"alpha.dagger.io/dagger/op"
	"alpha.dagger.io/kubernetes"
)

patchGrafana: {
	#code: #"""
		    kubectl -n monitoring patch deployment grafana --patch-file /source
		"""#

	#up: [
		op.#Load & {
			from: kubernetes.#Kubectl & {
				version: "v1.23.3"
			}
		},
		op.#WriteFile & {
			dest:    "/entrypoint.sh"
			content: #code
		},
		op.#WriteFile & {
			dest:    "/source"
			content: """
spec:
  template:
    spec:
      containers:
      - name: grafana
        volumeMounts:
        - mountPath: /grafana-dashboard-definitions/0/app-\(parameters.metadata.name)
          name: grafana-dashboard-app-\(parameters.metadata.name)
      volumes:
      - configMap:
          name: grafana-dashboard-app-\(parameters.metadata.name)
        name: grafana-dashboard-app-\(parameters.metadata.name)
"""
		},
		op.#WriteFile & {
			dest:    "/kubeconfig"
			content: kubeconfig
			mode:    0o600
		},
		op.#Exec & {
			always: true
			args: [
				"/bin/bash",
				"--noprofile",
				"--norc",
				"-eo",
				"pipefail",
				"/entrypoint.sh",
			]
			env: KUBECONFIG: "/kubeconfig"
		},
	]
}

generateResource: "v1:ConfigMap:monitoring:grafana-dashboard-app-\(parameters.metadata.name)": {
	apiVersion: "v1"
	kind:       "ConfigMap"
	metadata: {
		name:      "grafana-dashboard-app-\(parameters.metadata.name)"
		namespace: "monitoring"
		labels: "app.kubernetes.io/name": "grafana-dashboard-app-\(parameters.metadata.name)"
	}
	data: "dashboard.json": json.Marshal({
		"__inputs": []
		"__requires": []
		annotations: list: []
		editable:     false
		gnetId:       null
		graphTooltip: 1
		hideControls: false
		id:           null
		links: []
		refresh: "30s"
		panels: [{
			datasource: {
				type: "prometheus"
				uid:  "$datasource"
			}
			fieldConfig: {
				defaults: {
					color: mode: "palette-classic"
					custom: {
						axisLabel:     ""
						axisPlacement: "auto"
						barAlignment:  0
						drawStyle:     "line"
						fillOpacity:   0
						gradientMode:  "none"
						hideFrom: {
							legend:  false
							tooltip: false
							viz:     false
						}
						lineInterpolation: "linear"
						lineWidth:         1
						pointSize:         5
						scaleDistribution: type: "linear"
						showPoints: "auto"
						spanNulls:  false
						stacking: {
							group: "A"
							mode:  "none"
						}
						thresholdsStyle: mode: "off"
					}
					mappings: []
					thresholds: {
						mode: "absolute"
						steps: [{
							color: "green"
							value: null
						}, {
							color: "semi-dark-red"
							value: 80
						}]
					}
					unit: "percentunit"
				}
				overrides: []
			}
			gridPos: {
				h: 10
				w: 24
				x: 0
				y: 0
			}
			id: 123125
			options: {
				legend: {
					calcs: []
					displayMode: "list"
					placement:   "bottom"
				}
				tooltip: mode: "single"
			}
			targets: [{
				datasource: {
					type: "prometheus"
					uid:  "$datasource"
				}
				exemplar:     true
				expr:         "sum(rate(container_cpu_usage_seconds_total{container=\"\(parameters.metadata.name)\"}[1m])) by (container)"
				format:       "time_series"
				instant:      false
				interval:     ""
				legendFormat: ""
				refId:        "A"
			}]
			title: "CPU Usage"
			type:  "timeseries"
		}, {
			datasource: {
				type: "prometheus"
				uid:  "$datasource"
			}
			fieldConfig: {
				defaults: {
					color: mode: "palette-classic"
					custom: {
						axisLabel:     "MB"
						axisPlacement: "auto"
						barAlignment:  0
						drawStyle:     "line"
						fillOpacity:   0
						gradientMode:  "none"
						hideFrom: {
							legend:  false
							tooltip: false
							viz:     false
						}
						lineInterpolation: "linear"
						lineWidth:         1
						pointSize:         5
						scaleDistribution: type: "linear"
						showPoints: "auto"
						spanNulls:  false
						stacking: {
							group: "A"
							mode:  "none"
						}
						thresholdsStyle: mode: "off"
					}
					mappings: []
					thresholds: {
						mode: "absolute"
						steps: [{
							color: "green"
							value: null
						}, {
							color: "red"
							value: 80
						}]
					}
					unit: "none"
				}
				overrides: [{
					"__systemRef": "hideSeriesFrom"
					matcher: {
						id: "byNames"
						options: {
							mode: "exclude"
							names: ["{container=\"\(parameters.metadata.name)\"}"]
							prefix:   "All except:"
							readOnly: true
						}
					}
					properties: [{
						id: "custom.hideFrom"
						value: {
							legend:  false
							tooltip: false
							viz:     true
						}
					}]
				}]
			}
			gridPos: {
				h: 10
				w: 24
				x: 0
				y: 10
			}
			id: 123127
			options: {
				legend: {
					calcs: []
					displayMode: "list"
					placement:   "bottom"
				}
				tooltip: mode: "single"
			}
			targets: [{
				datasource: {
					type: "prometheus"
					uid:  "$datasource"
				}
				exemplar:     true
				expr:         "sum(container_memory_working_set_bytes{container=\"\(parameters.metadata.name)\"}) by (container) / 1048576"
				format:       "time_series"
				instant:      false
				interval:     ""
				legendFormat: ""
				refId:        "A"
			}]
			title: "Memory Usage"
			type:  "timeseries"
		}]
		schemaVersion: 34
		style:         "dark"
		tags: [
			"app",
		]
		templating: list: [{
			current: {
				selected: false
				text:     "prometheus"
				value:    "prometheus"
			}
			hide:       0
			includeAll: false
			label:      "Data Source"
			multi:      false
			name:       "datasource"
			options: []
			query:       "prometheus"
			refresh:     1
			regex:       ""
			skipUrlSync: false
			type:        "datasource"
		}]
		time: {
			from: "now-1h"
			to:   "now"
		}
		timepicker: {
			refresh_intervals: ["5s", "10s", "30s", "1m", "5m", "15m", "30m", "1h", "2h", "1d"]
			time_options: ["5m", "15m", "1h", "6h", "12h", "24h", "2d", "7d", "30d"]
		}
		timezone: "utc"
		title:    "Application / \(parameters.metadata.name)"
		uid:      parameters.metadata.name
		version:  0
	})
}
