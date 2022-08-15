package cue

import (
	"dagger.io/dagger"

	"universe.dagger.io/alpine"
	"universe.dagger.io/docker"
	"universe.dagger.io/bash"
)

#Lint: {
	source: dagger.#FS

	// Cue version
	cueVersion: string | *"0.4.3"

	docker.#Build & {
		steps: [
			alpine.#Build & {
				packages: bash: _
				packages: curl: _
				packages: git:  _
				packages: tar:  _
			},

			// Install CUE
			bash.#Run & {
				env: CUE_VERSION: "v\(cueVersion)"
				script: contents: #"""
					export CUE_TARBALL="cue_${CUE_VERSION}_linux_amd64.tar.gz"
					echo "Installing cue version $CUE_VERSION"
					curl -L "https://github.com/cue-lang/cue/releases/download/${CUE_VERSION}/${CUE_TARBALL}" | tar zxf - -C /usr/local/bin
					cue version
					"""#
			},

			// CACHE: copy only *.cue files
			docker.#Copy & {
				contents: source
				include: [".git", "*.cue", "**/*.cue"]
				dest: "/cue"
			},

			// LINT
			bash.#Run & {
				workdir: "/cue"
				script: contents: #"""
					find . -name '*.cue' -not -path '*/cue.mod/*' -print | time xargs -n 1 -P 8 cue fmt -s
					# Show modified files
					git diff -- "*.cue"
					modified="$(git status -s . | grep -e "^ M"  | grep "\.cue" | cut -d ' ' -f3 || true)"
					test -z "$modified" || (echo -e "linting error in:\n${modified}" > /dev/stderr ; false)
					"""#
			},
		]
	}
}
