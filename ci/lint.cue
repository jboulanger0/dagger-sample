
package ci

import(
    "dagger.io/dagger"
    "universe.dagger.io/docker"
)

#GoLint: {
    version: string | *"v1.45.2"

	source: dagger.#FS

    packages: [...string] | *["."]

    _sourcePath:     "/src"

    _image: docker.#Build & {
		steps: [
            docker.#Pull & {
                source: "golangci/golangci-lint:\(version)"
            }
		]
	}

    container: docker.#Run   & {
        input: *_image.output | docker.#Image
        workdir: _sourcePath
        mounts: {
            "source": {
				dest:     _sourcePath
				contents: source
			}
        }
        command: {
			name: "golangci-lint"
			args: packages
			flags: {
                "run": true
            }
		}
    }
}