package golangci

import (
	"strings"
	"dagger.io/dagger"

	"universe.dagger.io/docker"
	"universe.dagger.io/go"
	"universe.dagger.io/alpha/go/golangci"
)

// Gomodule retrives go module name
#Gomodule: {
	// Source code
	source: dagger.#FS

	_run: go.#Container & {
		"source": source
		command: {
			name: "sh"
			flags: "-c": "go list -m > /output.txt"
		}
		export: files: "/output.txt": string
	}
	output: _run.export.files["/output.txt"]
}

// Lint using golangci-lint
#Lint: {
	// Source code
	source: dagger.#FS

	packages: [...string]

	// golangci-lint version
	version: *"1.45" | string

	// timeout
	timeout: *"5m" | string

	_gomodule: #Gomodule & {"source": source}

	_packages: [
		for _, value in packages {
			strings.Replace(strings.Replace(value, strings.TrimSpace(_gomodule.output), "./", 1), "//", "/", 1)
		},
	]

	_image: docker.#Pull & {
		source: "golangci/golangci-lint:v\(version)"
	}

	_run: golangci.#Lint & {
		"source": source
		command: args: _packages
	}

	output: _run.output
}
