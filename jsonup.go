package main

import (
	"encoding/json"
	"flag"
	"log"
	"net/http"
	"time"

	"github.com/garyburd/redigo/redis"

	"github.com/gorilla/mux"
)

var (
	listenAddr    = flag.String("listenAddr", ":11111", "Web server listen address")
	redisProtocol = flag.String("redisProtocol", "tcp", "Redis server protocol")
	redisAddress  = flag.String("redisAddress", "localhost:6379", "Redis server address")

	pool *redis.Pool
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

func pushEndpoint(w http.ResponseWriter, req *http.Request) {
	var jsonCollection []JSONUp

	decoder := json.NewDecoder(req.Body)
	err := decoder.Decode(&jsonCollection)

	if err != nil {
		log.Println(err)
		w.WriteHeader(500)
		return
	}

	for _, jsonRecord := range jsonCollection {
		r := jsonUpRecord{JSONUp: jsonRecord, UserID: "Foo"}
		pushToRedis(&r)
	}
	log.Println(jsonCollection)

	w.WriteHeader(200)
}

func getRedisConn() redis.Conn {
	return pool.Get()
}

func pushToRedis(up *jsonUpRecord) {
	conn := getRedisConn()
	defer conn.Close()
	data, _ := json.Marshal(up.JSONUp)
	_, err := conn.Do("PUBLISH", up.UserID, data)
	if err != nil {
		log.Printf("Redis Push Error %s", err)
	}
}

func newPool() *redis.Pool {
	return &redis.Pool{
		MaxIdle:     3,
		IdleTimeout: 240 * time.Second,
		Dial: func() (redis.Conn, error) {
			c, err := redis.Dial(*redisProtocol, *redisAddress)
			if err != nil {
				return nil, err
			}
			return c, err
		},
		TestOnBorrow: func(c redis.Conn, t time.Time) error {
			_, err := c.Do("PING")
			return err
		},
	}
}

func main() {
	flag.Parse()

	pool = newPool()

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
