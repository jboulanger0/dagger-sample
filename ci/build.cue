package ci

import(
    "universe.dagger.io/go"
    "dagger.io/dagger"
)

// Forked from dagger universe.dagger.io/go
#Build: {
	// Source code
	source: dagger.#FS

	// Target packages to build
	packages: [...string] | *["."]

	// Target architecture
	arch?: string

	// Target OS
	os?: string

	// Build tags to use for building
	tags: *"" | string

	// LDFLAGS to use for linking
	ldflags: *"" | string

	env: [string]: string

	container: go.#Container & {
		"source": source
		"env": {
			env
			if os != _|_ {
				GOOS: os
			}
			if arch != _|_ {
				GOARCH: arch
			}
		}
		command: {
			name: "go"
			args: packages
			flags: {
				build:      true
				"-v":       true
				"-tags":    tags
				"-ldflags": ldflags
				"-o":       "/output/"
			}
		}
		export: directories: "/output": _
	}

	// Directory containing the output of the build
	output: container.export.directories."/output"
}
