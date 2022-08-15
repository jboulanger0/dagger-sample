package printer

import "log"

func Println(in string) {
	log.Printf("%#v", in)
}
