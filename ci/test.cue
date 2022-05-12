package ci

import(
	//"encoding/json"
	"dagger.io/dagger"
	//"dagger.io/dagger/core"
    "universe.dagger.io/go"
)

#Test: {
	// Source code
	source: dagger.#FS

	// Target packages to test
	packages: [...string] | *["."]
	
	go.#Container & {
		"source": source
		command: {
			name: "go"
			args: packages
			flags: {
				test: true
				"-v": true
			}
		}
	}
}