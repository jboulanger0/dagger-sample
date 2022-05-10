package ci

import(
    "dagger.io/dagger"
    "universe.dagger.io/go"
)

#Test: {
	// Source code
	source: dagger.#FS

	// Target packages to test
	packages: [...string] | *["."]
    
	go.#Container & {
		source: source
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