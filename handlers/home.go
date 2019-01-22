package handlers

import (
	"fmt"
	"html/template"
	"log"
	"net/http"
	"net/http/httputil"
	"time"

	"github.com/mchmarny/knative-gitops-using-cloud-build/utils"
)

var (
	templates *template.Template
	release   = utils.MustGetEnv("RELEASE", "")
)

// InitHandlers initializes all handlers
func InitHandlers(mux *http.ServeMux) {

	log.Printf("Init Release: %s", release)

	// templates
	tmpls, err := template.ParseGlob("templates/*.html")
	if err != nil {
		log.Fatalf("Error while parsing templates: %v", err)
	}
	templates = tmpls

	// static
	mux.Handle("/static/", http.StripPrefix("/static/",
		http.FileServer(http.Dir("static"))))

	// routes
	mux.HandleFunc("/", withLog(homeHandler))

	// health (Istio and other)
	mux.HandleFunc("/_healthz", func(w http.ResponseWriter, _ *http.Request) {
		fmt.Fprint(w, "ok")
	})

}

// withLog is a simple midleware to dump each request into log
func withLog(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {

		reqDump, err := httputil.DumpRequest(r, true)
		if err != nil {
			log.Println(err)
		} else {
			log.Println(string(reqDump))
		}

		next.ServeHTTP(w, r)
	}
}

func homeHandler(w http.ResponseWriter, r *http.Request) {

	data := map[string]string{
		"on":      time.Now().String(),
		"release": release,
	}

	if err := templates.ExecuteTemplate(w, "home", data); err != nil {
		log.Printf("Error in home template: %s", err)
	}

}
