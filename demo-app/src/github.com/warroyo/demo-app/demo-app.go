package main

import (
	"encoding/json"
	"html/template"
	"log"
	"net/http"
	"os"
	"path/filepath"

	cfenv "github.com/cloudfoundry-community/go-cfenv"
)

const (
	DEFAULT_PORT = "9000"
)

var requests = 0

func main() {
	fs := http.FileServer(http.Dir("static"))
	http.Handle("/static/", http.StripPrefix("/static/", fs))
	http.HandleFunc("/", serveTemplate)
	http.HandleFunc("/version", version)

	var port string
	if port = os.Getenv("PORT"); len(port) == 0 {
		log.Printf("Warning, PORT not set. Defaulting to %+vn", DEFAULT_PORT)
		port = DEFAULT_PORT
	}

	log.Println("Listening...")
	http.ListenAndServe(":"+port, nil)
}

func serveTemplate(w http.ResponseWriter, r *http.Request) {
	requests++
	appEnv, _ := cfenv.Current()
	var variables struct {
		Requests int
		AppEnv   *cfenv.App
	}
	variables.AppEnv = appEnv
	variables.Requests = requests
	log.Println("rendering content")
	lp := filepath.Join("templates", "index.html")

	tmpl, err := template.ParseFiles(lp)
	if err != nil {
		// Log the detailed error
		log.Println(err.Error())
		// Return a generic "Internal Server Error" message
		http.Error(w, http.StatusText(500), 500)
		return
	}

	if err := tmpl.ExecuteTemplate(w, "index", variables); err != nil {
		log.Println(err.Error())
		http.Error(w, http.StatusText(500), 500)
	}
}

func version(w http.ResponseWriter, r *http.Request) {
	appEnv, _ := cfenv.Current()
	var data struct {
		Name     string
		Instance int
		Version  string
	}
	version := os.Getenv("VERSION")

	data.Name = appEnv.Name
	data.Instance = appEnv.Index
	data.Version = version
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(data)
}
