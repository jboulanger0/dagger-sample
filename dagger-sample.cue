package main 

import(
    "dagger.io/dagger"
    "dagger.io/dagger/core"
    "universe.dagger.io/go"
    "github.com/jboulanger0/dagger-sample/ci"
)

dagger.#Plan & {
    client: {
        filesystem: {
            ".": read: contents: dagger.#FS 
            "./out/coverage": write: contents: actions.coverage.copy.output
            "./out/build": write: contents: actions.build.run.output
        }
    }
    
    actions: {
        build: {
            run: go.#Build & {
                source: client.filesystem.".".read.contents
                package: "./..."
            }
        }
        
        test: {
            run: ci.#GoTestWithCoverage & {
                source: client.filesystem.".".read.contents
                package: "./..."
            }
        }

        coverage: {
            run: ci.#GoTestWithCoverage & {
                source: client.filesystem.".".read.contents
                package: "./..."
                coverageOutput: "/tmp/coverage.out"
            }

            copy: core.#Copy & {
                input:    dagger.#Scratch
                contents: run.output.rootfs
				source:   "/tmp/coverage.out"
				dest:     "/"
			}
        }

        lint: {
            run: ci.#GoLint & {
                source: client.filesystem.".".read.contents
                package: "./..."
            }
        }
    }
}