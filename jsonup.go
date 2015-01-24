package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"log"
	"net/http"
	"strings"
	"time"

	"code.google.com/p/go.net/websocket"
	"github.com/garyburd/redigo/redis"
	"github.com/gorilla/mux"
)

var (
	listenAddr    = flag.String("listenAddr", ":11111", "Web server listen address")
	wsListenAddr  = flag.String("wsListenAddr", ":11112", "Websocket server listen address")
	redisProtocol = flag.String("redisProtocol", "tcp", "Redis server protocol")
	redisAddress  = flag.String("redisAddress", "localhost:6379", "Redis server address")

	pool *redis.Pool

	wsClients = make(map[wsConn]int)
)

// websocket connection
type wsConn struct {
	websocket *websocket.Conn
	clientIP  string
}

// JSONUp represents one row of POSTed or collected JSON.
type JSONUp struct {
	Name   string `json:"name"`
	Status string `json:"status"`
	Value  uint   `json:"value"`
}

// jsonUpRecord is internal
type jsonUpRecord struct {
	UserID string `json:"UserId"`
	JSONUp
	ValueHistory []uint `json:"sparkline"`
}

func redisSubscribeJSON(userID string) chan string {
	c := make(chan string)
	pubSubConn := redis.PubSubConn{Conn: pool.Get()}
	pubSubConn.Subscribe(userID)

	go func() {
		for {
			switch v := pubSubConn.Receive().(type) {
			case redis.Message:
				c <- string(v.Data)
			case redis.Subscription:
			case error:
				fmt.Printf("ERROR\n %s", v)
				return
			}
		}
	}()

	return c
}

func wsServer(ws *websocket.Conn) {
	defer ws.Close()
	client := ws.Request().RemoteAddr

	sockID := wsConn{ws, client}
	wsClients[sockID] = 0

	log.Println("Client connected:", client)
	log.Println("for address:", ws.Request().URL.Path)
	log.Println("Websocket connections", len(wsClients))

	// TODO, add a closer channel so can unsubscribe
	// from redis when websocket dies
	c := redisSubscribeJSON(ws.Request().URL.Path)

	for {
		requestJSON := <-c
		for cs := range wsClients {
			err := websocket.Message.Send(cs.websocket, requestJSON)
			if err != nil {
				log.Println("Could not send to client, removing")
				delete(wsClients, sockID)
			}
		}
	}
}

func startWsServer(port string) {
	log.Println("Websocket server Listening on " + port)
	err := http.ListenAndServe(port, websocket.Handler(wsServer))
	if err != nil {
		panic(err)
	}
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

	idx := strings.LastIndex(req.URL.Path, "/")
	userID := req.URL.Path[idx:]

	// TODO check userid

	for _, jsonRecord := range jsonCollection {
		r := jsonUpRecord{JSONUp: jsonRecord, UserID: userID}
		go pushToRedis(&r)
	}

	w.WriteHeader(200)
}

func pushToRedis(up *jsonUpRecord) {
	conn := pool.Get()
	defer conn.Close()
	data, _ := json.Marshal(up)
	_, err := conn.Do("PUBLISH", up.UserID, data)
	if err != nil {
		log.Printf("Redis Push Error %s", err)
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

	go startWsServer(*wsListenAddr)

	log.Println("Web server Listening on " + *listenAddr)
	err := http.ListenAndServe(*listenAddr, nil)
	if err != nil {
		panic(err)
	}
}

func newPool() *redis.Pool {
	return &redis.Pool{
		MaxIdle:     5,
		IdleTimeout: 60 * time.Second,
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
