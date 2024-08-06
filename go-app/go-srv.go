package main

import (
	"fmt"
	"net/http"
	"os"
)

func main() {
	http.HandleFunc("/", HelloServer)
	http.ListenAndServe(":8080", nil)
}

func HelloServer(w http.ResponseWriter, r *http.Request) {
	scr := os.Getenv("SCR_STR")
	fmt.Fprintf(w, "%s, world!", scr)
}
