
package ci

import(
    "dagger.io/dagger"
    "universe.dagger.io/go"
    "universe.dagger.io/docker"
)

#Lint: {
    version: string | *"1.45.2"

	source: dagger.#FS

    packages: [...string] | *["."]

    _image: docker.#Pull & {
        source: "golangci/golangci-lint:v\(version)"
    }

    go.#Container & {
        input: _image.output
        source: source
        command: {
			name: "golangci-lint"
			args: packages
			flags: {
                "run": true
            }
		}
    }
}