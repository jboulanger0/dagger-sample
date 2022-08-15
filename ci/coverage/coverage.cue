package coverage

import (
	"dagger.io/dagger"

	"universe.dagger.io/go"
)

#Coverage: {
	// Source code
	source: dagger.#FS

	// Target packages to evaluate coverage
	packages: [...string]

	_run: go.#Test & {
		"source":   source
		"packages": packages
		command: flags: _ & {"-coverprofile": "/coverage.out"}
		export: files: "/coverage.out": _
	}

	// Directory containing coverage output
	output: _run.export.files["/coverage.out"]
}
