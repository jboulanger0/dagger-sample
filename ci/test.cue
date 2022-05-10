package ci

import(
    "dagger.io/dagger"
    "universe.dagger.io/go"
)

#Test: {
	source: dagger.#FS

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