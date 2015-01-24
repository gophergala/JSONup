package main

import (
	"flag"
	"log"
	"net/http"
)

var listenAddr = flag.String("listenAddr", ":8080", "Web server listen address")

func main() {
	flag.Parse()
	log.Println("Web server Listening on " + *listenAddr)
	http.ListenAndServe(*listenAddr, http.FileServer(http.Dir("./public")))
}
