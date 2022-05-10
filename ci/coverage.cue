package ci

import(
    "universe.dagger.io/go"
)

#GoTestWithCoverage: {
	packages: [...string] | *[..."."]
    
    coverageOutput?: string | "coverage.out"

	go.#Container & {
		command: {
			name: "go"
			args: packages
			flags: {
				test: true
				"-v": true
                if coverageOutput != _|_ {
                    "-coverprofile": coverageOutput
                }
			}
		}
	}
}