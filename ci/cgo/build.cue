package cgo

import (
	"dagger.io/dagger"
	"universe.dagger.io/go"
)

#Build: {
	// Source code
	source: dagger.#FS

	// Target package to build
	packages: [...string]

	// Target architecture
	arch: string

	// Target OS
	os: *"" | string

	// Build tags to use for building
	tags: *"" | string

	// LDFLAGS to use for linking
	ldflags: *"" | string

	_ldflags: *ldflags | string
	if os == "linux" {
		_ldflags: "-w -extldflags \"-static\" \(ldflags)"
	}

	env: [string]: string

	_targetPlatform: "\(os)/\(arch)"
	image:           #Image & {
		platform: _targetPlatform
	}

	// Custom binary name
	binaryName: *"" | string

	container: go.#Container & {
		"source": source
		"image":  image.output
		"env": {
			env
			TARGETPLATFORM: _targetPlatform
			CGO_ENABLED:    "1"
		}
		command: {
			name: "goxx-go"
			args: packages
			flags: {
				build:      true
				"-v":       true
				"-tags":    tags
				"-ldflags": _ldflags
				"-o":       "/output/\(binaryName)"
			}
		}
		export: directories: "/output": _
	}

	output: container.export.directories."/output"
}
