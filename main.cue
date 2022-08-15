package main

import (
	"strings"
	"dagger.io/dagger"
	"universe.dagger.io/go"
	"universe.dagger.io/docker"
	"universe.dagger.io/docker/cli"

	"github.com/jboulanger0/dagger-sample/ci/cue"
	"github.com/jboulanger0/dagger-sample/ci/git"
	"github.com/jboulanger0/dagger-sample/ci/coverage"
	"github.com/jboulanger0/dagger-sample/ci/gta"
	"github.com/jboulanger0/dagger-sample/ci/golangci"
)

dagger.#Plan & {
	client: network: "unix:///var/run/docker.sock": connect: dagger.#Socket
	client: filesystem: ".": read: contents: dagger.#FS
	client: env: {
		DOCKER_PASSWORD: dagger.#Secret
		DOCKER_USERNAME: string | *""
		ENV:             string | *"dev"
	}

	actions: {
		params: useDiffFrom?: gta.#DiffFrom
		_useDiffFrom: params.useDiffFrom

		_source: client.filesystem["."].read.contents

		diff: {
			from: *gta.#DiffFromMain | gta.#DiffFrom
			if _useDiffFrom != _|_ {
				from: _useDiffFrom
			}

			_op: gta.#Diff & {
				source: _source
				"from": from
			}
			output:  _op.output
			results: strings.Join(output, ",")
		}

		checks: {
			_packages: *["./..."] | [...string]
			if _useDiffFrom != _|_ {
				_packages: diff.output
			}

			test: go.#Test & {
				source:   _source
				packages: _packages
				command: flags: "-race": true
			}

			lint: {
				go: golangci.#Lint & {
					source:   _source
					packages: _packages
				}
				"cue": cue.#Lint & {
					source: _source
				}
			}

			build: go.#Build & {
				source:   _source
				packages: _packages
			}

			cover: coverage.#Coverage & {
				source:   _source
				packages: _packages
			}
		}

		version: {
			_revision: git.#Revision & {
				source: _source
			}
			output: "\(_revision.output)-\(client.env.ENV)"
		}

		application: {
			[appName=string]: {
				packages: [...string]
				build: {
					binary: go.#Build & {
						source:     _source
						binaryName: appName
						os:         "linux"
						arch:       client.platform.arch
						ldflags:    "-X main.Version=\(version.output)"
						"packages": packages
					}

					image: {
						docker.#Build & {
							steps: [
								docker.#Copy & {
									input:    docker.#Scratch
									contents: binary.output
								},
								docker.#Set & {
									config: entrypoint: ["./\(appName)"]
								},
							]
						}
					}
				}

				release: {
					local: cli.#Load & {
						image: build.image.output
						host:  client.network."unix:///var/run/docker.sock".connect
						tag:   "\(appName):\(version.output)"
					}

					remote: docker.#Push & {
						dest: "\(client.env.DOCKER_USERNAME)/\(appName):\(version.output)"
						auth: {
							username: client.env.DOCKER_USERNAME
							secret:   client.env.DOCKER_PASSWORD
						}
						image: build.image.output
					}
				}

				run: local: cli.#Run & {
					input: release.local.image
					host:  client.network."unix:///var/run/docker.sock".connect
				}
			}
			api:   _ & {packages: ["./cmd/api"]}
			"cli": _ & {packages: ["./cmd/cli"]}
		}
	}
}
