package ci

import(
    "encoding/json"
    "dagger.io/dagger"
    "universe.dagger.io/docker"
	"universe.dagger.io/alpine"
)

#ListFile: {
    input: dagger.#FS

    _image: alpine.#Build & {
        packages: {
            jq: _
        }
    }

    _sourceFolder: "/src"
    _ouputPath: "/tmp/ls.json"
    _exec: docker.#Run & {
        "input":  _image.output,
        command: {
            name: "sh"
            flags: "-c": "ls \(_sourceFolder) | jq -Rs 'split(\"\n\")[:-1]' >> \(_ouputPath)"
        }
        mounts: {
            "source": {
                dest: _sourceFolder
                contents: input
            }
        }
        export: files: (_ouputPath): _
    }

    files: [...string] & json.Unmarshal(_exec.export.files[_ouputPath]) 
}