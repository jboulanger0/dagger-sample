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
	
	_source: source
	_packages: packages
	_test: #Test & {
		packages: _packages
		source: _source
		command: flags: _ & {
			"-coverprofile": _coverageOutputPath
		}
		export: {
			directories: (_coverageOutputFolder): dagger.#FS
		}
	}

	// Directory containing coverage output
	output: _test.export.directories[_coverageOutputFolder]
}