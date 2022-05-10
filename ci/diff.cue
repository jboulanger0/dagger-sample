package ci

import(
    "encoding/json"
    "dagger.io/dagger"
    "universe.dagger.io/go"
    "universe.dagger.io/docker"
)


// Diff is based on gta is an application which finds Go packages that have deviated from their upstream source in git.
// https://github.com/digitalocean/gta
#Diff: {
    // Source code
    source: dagger.#FS

    // Gta image version
    gtaVersion: string | *"latest"

    _outputFolder: "/tmp"
    _outputPath: _outputFolder + "/packages.json"
    _image: docker.#Build & {
        steps:[
            go.#Image & {
                packages: _ & {
                    jq : _
                }
            },
            docker.#Run & { 
                command: {
                    name: "go"
                    args: [
                        "install",
                        "github.com/digitalocean/gta/cmd/gta@\(gtaVersion)",
                    ]
                }
            }
        ]

    }
    
    _source: source
    _run: go.#Container & {
        source: _source
        input: _image.output
        command: {
			name: "sh"
            flags: {
                "-c": "gta -json --buildable-only=false -base origin/main >> \(_outputPath)"
            }
		}
        export: {
            directories: (_outputFolder): dagger.#FS
            files: (_outputPath): _
        }
    }
    
    _packages: {[string]: {[string]: [...string]} | [...string]} & json.Unmarshal(_run.export.files[_outputPath])  
    
    // Go packages impacted by diff
    packages: _packages["all_changes"] | _|_

    // Directory containing gta output 
    output: _run.export.directories[_outputFolder]
}