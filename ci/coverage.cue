package ci

import(
    "dagger.io/dagger"
)

#Coverage: {
	source: dagger.#FS

	packages: [...string] | *["."]

	_coverageOutputFolder: "/tmp"
    _coverageOutputFilename: "coverage.out"
	_coverageOutputPath: _coverageOutputFolder + "/" + _coverageOutputFilename
	
	_source: source
	_packages: packages
	_test: #Test & {
		packages: _packages
		source: _source
		command: flags: _ & {
			"-coverprofile": _coverageOutputPath
		}
		export: {
			directories: "\(_coverageOutputFolder)": dagger.#FS
		}
	}

	output: _test.export.directories[_coverageOutputFolder]
}