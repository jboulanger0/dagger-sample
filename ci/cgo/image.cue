package cgo

import (
	"dagger.io/dagger"
	"universe.dagger.io/docker"
)

#Image: {
	platform: string & "linux/amd64" | "darwin/amd64" | "windows/amd64"

	docker.#Build & {
		steps: [
			docker.#Dockerfile & {
				source: dagger.#Scratch
				dockerfile: contents: """
						FROM ghcr.io/crazy-max/goxx:1.18
						COPY --from=crazymax/osxcross:latest /osxcross /osxcross
					"""
			},
			docker.#Run & {
				env: TARGETPLATFORM: platform
				command: {
					name: "goxx-apt-get"
					args: ["install", "binutils", "gcc", "g++", "pkg-config"]
					flags: {
						"-y":                      true
						"--no-install-recommends": true
					}
				}
			},
		]
	}
}
