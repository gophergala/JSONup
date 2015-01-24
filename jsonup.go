package main

import (
	"flag"
	"log"
	"net/http"

	"github.com/gorilla/mux"
)

var listenAddr = flag.String("listenAddr", ":8080", "Web server listen address")

//
// func pushEndpoint(http.ResponseWriter, *http.Request) {
//
// }

func main() {
	flag.Parse()

	router := mux.NewRouter()

	// Push endpoint
	// router.HandleFunc("/push/{userId}", pushEndpoint).Methods("POST")

	// Static public files
	publicFiles := http.FileServer(http.Dir("public"))
	router.Handle("/", publicFiles)

	// Start Web Server
	http.Handle("/", router)
	log.Println("Web server Listening on " + *listenAddr)
	http.ListenAndServe(*listenAddr, nil)
}
