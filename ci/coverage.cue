package ci

import(
    "dagger.io/dagger"
)

#Coverage: {
	// Source code
	source: dagger.#FS

	// Target packages to evaluate coverage
	packages: [...string] | *["."]

	_coverageOutputFolder: "/tmp"
	_coverageOutputPath: _coverageOutputFolder + "/coverage.out"
	
	_test: #Test & {
		"source": source
		"packages": packages
		command: flags: _ & {"-coverprofile": _coverageOutputPath}
		export: directories: (_coverageOutputFolder): dagger.#FS
	}

	// Directory containing coverage output
	output: _test.export.directories[_coverageOutputFolder]
}