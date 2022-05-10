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
    source: dagger.#FS
    
    package?: string

    gtaVersion: string | *"latest"

    _outputFolder: "/tmp"
    _outputFilename: "packages.json"
    _outputPath: _outputFolder + "/" + _outputFilename
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
            directories: "\(_outputFolder)": dagger.#FS
            files: "\(_outputPath)": _
        }
    }

    _raw_json: _run.export.files[_outputPath]
    packages: {[string]: {[string]: [...string]} | [...string]} & json.Unmarshal(_raw_json)  
    
    allChanges: packages["all_changes"]
    dependencies: packages["dependencies"]
    changes: packages["changes"]

    output: _run.export.directories[_outputFolder]
}