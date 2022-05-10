package main 

import(
    "strings"
    "dagger.io/dagger"
    "dagger.io/dagger/core"
    "github.com/jboulanger0/dagger-sample/ci"
)

dagger.#Plan & {
    client: {
        filesystem: {
            ".": read: {
                contents: dagger.#FS 
                exclude: [
                    "out"
                ]
            }
            "./out/coverage": write: contents: actions.coverage.copy.output
            "./out/build": write: contents: actions.build.run.output
            "./out/packages": write: contents: actions.diff.output
        }

        commands: {
            moduleName: {
                name: "go"
                args: ["list", "-m"]
            }
        } 
    }
    
    actions: {  
        diff: ci.#Diff & {
            source: client.filesystem.".".read.contents
        }

        build: {
            run: ci.#Build & {
                source: client.filesystem.".".read.contents
                packages: diff.packages
            }
        }
        
        test: {
            run: ci.#GoTestWithCoverage & {
                source: client.filesystem.".".read.contents
                packages: diff.packages
            }
        }

        coverage: {
            run: ci.#GoTestWithCoverage & {
                source: client.filesystem.".".read.contents
                packages: diff.packages
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
                packages: [
                    for _, value in diff.packages { 
                        strings.TrimPrefix(value, strings.TrimSpace(client.commands.moduleName.stdout)+"/")
                    }
                ]
            }
        }
    }
}