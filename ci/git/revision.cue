package git

import (
	"dagger.io/dagger"
	"universe.dagger.io/alpine"
	"universe.dagger.io/bash"
)

#Revision: {
	// Source code
	source: dagger.#FS

	_image: alpine.#Build & {
		packages: bash: _
		packages: git:  _
	}
	_run: bash.#Run & {
		input:   _image.output
		workdir: "/src"
		mounts: "source": {
			dest:     "/src"
			contents: source
		}
		script: contents: #"""
			printf "$(git rev-parse --short HEAD)" > /revision
			"""#
		export: files: "/revision": string
	}
	output: _run.export.files["/revision"]
}
