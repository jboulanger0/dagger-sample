package main 

import(
    "strings"
    "dagger.io/dagger"
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
            "./out/coverage": write: contents: actions.coverage.output
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

        coverage: ci.#Coverage & {
            source: client.filesystem.".".read.contents
            packages: diff.packages
        }

        test: ci.#Test & {
            source: client.filesystem.".".read.contents
            packages: diff.packages
        }

        build: {
            run: ci.#Build & {
                source: client.filesystem.".".read.contents
                packages: diff.packages
            }
        }
        

        lint: ci.#Lint & {
            source: client.filesystem.".".read.contents
            packages: [
                for _, value in diff.packages { 
                    strings.TrimPrefix(value, strings.TrimSpace(client.commands.moduleName.stdout)+"/")
                }
            ]
        }
    }
}