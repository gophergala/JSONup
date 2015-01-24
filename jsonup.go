package main

import (
	"encoding/json"
	"flag"
	"log"
	"net/http"

	"github.com/gorilla/mux"
)

// JSONUp represents one row of posted or collected json.
type JSONUp struct {
	Name   string `json:"name"`
	Status string `json:"status"`
	Value  uint   `json:"value"`
}

type jsonUpRecord struct {
	JSONUp
	UserID string `json:"UserId"`
}

var listenAddr = flag.String("listenAddr", ":11111", "Web server listen address")

func pushEndpoint(w http.ResponseWriter, req *http.Request) {
	var jsonCollection []JSONUp

	decoder := json.NewDecoder(req.Body)
	err := decoder.Decode(&jsonCollection)

	if err != nil {
		log.Println(err)
		w.WriteHeader(500)
		return
	}

	log.Println(jsonCollection)

	w.WriteHeader(200)
}

func main() {
	flag.Parse()

	router := mux.NewRouter()

	// Push endpoint
	router.HandleFunc("/push/{userId}", pushEndpoint).Methods("POST")

	// Static public files
	publicFiles := http.FileServer(http.Dir("public"))
	router.Handle("/", publicFiles)

	// This is really dumb. #TODO, use strip prefix or something.
	router.Handle("/js/app.js", publicFiles)
	router.Handle("/css/app.css", publicFiles)

	// Start Web Server
	http.Handle("/", router)
	log.Println("Web server Listening on " + *listenAddr)
	http.ListenAndServe(*listenAddr, nil)
}
