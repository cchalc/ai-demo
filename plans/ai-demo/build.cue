package ml

import (
	"alpha.dagger.io/os"
	"alpha.dagger.io/dagger"
	"alpha.dagger.io/docker"
)

source: dagger.#Artifact @dagger(input)

image: os.#Container & {
	image: docker.#Pull & {
		from: "jupyter/scipy-notebook:2022-01-31"
	}
	dir: "/home/jovyan"
	copy: "/home/jovyan": from: source

	env: parameters.build.env

	shell: path: "/bin/bash"

	command: #"""
	        pip install -r requirements.txt
	        \#(parameters.build.run)
	        """#
}

push: docker.#Push & {
	source: image
	...
}
