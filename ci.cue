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
            "./out/build": write: contents: actions.build.output
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
        diff: {
            _op: ci.#Diff & {
                source: client.filesystem.".".read.contents
            }

            packages: _op.packages
            output: _op.output
            results: strings.Join(packages, ",")
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
            _op: ci.#Build & {
                source: client.filesystem.".".read.contents
                packages: diff.packages
            }

            _binaries: ci.#ListFile & {
                input: _op.output  
            }

            output: _op.output
            results: strings.Join(_binaries.files, ",")
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