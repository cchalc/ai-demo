package ml

import (
	"path"

	"alpha.dagger.io/os"
	"alpha.dagger.io/docker"
)

image: os.#Container & {
	image: docker.#Pull & {
		from: "jupyter/scipy-notebook:2022-01-31"
	}
	dir: "/home/jovyan"

	env: parameters.build.env

	shell: path: "/bin/bash"

	let codedir = path.Base(parameters.build.git)

	command: #"""
git clone \#(parameters.build.git)
cd \#(codedir)
pip install -r requirements.txt
\#(parameters.build.run)
"""#
}

push: docker.#Push & {
	source: image
	...
}
