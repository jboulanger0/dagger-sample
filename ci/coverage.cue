package ci

import(
    "universe.dagger.io/go"
)

#GoTestWithCoverage: {
	package: *"." | string
    
    coverageOutput?: string | "coverage.out"

	go.#Container & {
		command: {
			name: "go"
			args: [package]
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