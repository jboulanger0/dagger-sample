package gta

import (
	"strings"
	"dagger.io/dagger"
	"universe.dagger.io/go"
	"universe.dagger.io/docker"
)

#DiffFromMerge: "merge"
#DiffFromMain:  "main"
#DiffFrom:      #DiffFromMerge | #DiffFromMain

// Diff is based on gta is an application which finds Go packages that have deviated from their upstream source in git.
// https://github.com/digitalocean/gta
#Diff: {
	// Source code
	source: dagger.#FS

	// Gta image version
	gtaVersion: string | *"4d63958"

	from: string & #DiffFrom | *#DiffFromMain

	_mergeFlag: string | *""
	if from == #DiffFromMerge {
		_mergeFlag: "-merge true"
	}

	_image: docker.#Build & {
		steps: [
			go.#Image,
			docker.#Run & {
				command: {
					name: "go"
					args: [
						"install",
						"github.com/digitalocean/gta/cmd/gta@\(gtaVersion)",
					]
				}
			},
		]
	}

	_run: go.#Container & {
		"source": source
		image:    _image.output
		command: {
			name: "sh"
			flags: "-c": "gta \(_mergeFlag) -base origin/main > /output.txt"
		}

		export: files: "/output.txt": string
	}

	output: strings.Split(strings.TrimSpace(_run.export.files["/output.txt"]), " ")
}
