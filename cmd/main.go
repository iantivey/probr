package main

import (
	"fmt"
	"log"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/briandowns/spinner"

	"github.com/citihub/probr"
	"github.com/citihub/probr/audit"
	cliflags "github.com/citihub/probr/cmd/cli_flags"
	"github.com/citihub/probr/config"
)

func main() {

	// Setup for handling SIGTERM (Ctrl+C)
	setupCloseHandler()

	err := config.Init("") // Create default config
	if err != nil {
		log.Printf("[ERROR] error returned from config.Init: %v", err)
		exit(2)
	}

	if len(os.Args[1:]) > 0 {
		log.Printf("[DEBUG] Checking for CLI options or flags")
		cliflags.HandleRequestForRequiredVars()
		cliflags.HandlePackOption()
		// TODO: Find a way to get loglevel handling to work ABOVE this point,
		// or to move the Options handlers below the flags handler
		// Currently only ERROR will print prior to HandleFlags()
		cliflags.HandleFlags()
	}

	config.LogConfigState()

	if showIndicator() {
		// At this loglevel, Probr is often silent for long periods. Add a visual runtime indicator.
		config.Spinner = spinner.New(spinner.CharSets[42], 500*time.Millisecond)
		config.Spinner.Start()
	}

	s, ts, err := probr.RunAllProbes()
	if err != nil {
		log.Printf("[ERROR] Error executing tests %v", err)
		exit(2) // Exit 2+ is for logic/functional errors
	}
	log.Printf("[INFO] Overall test completion status: %v", s)
	audit.State.SetProbrStatus()

	out := probr.GetAllProbeResults(ts)
	if out == nil || len(out) == 0 {
		audit.State.Meta["no probes completed"] = fmt.Sprintf(
			"Probe results not written to file, possibly due to all being excluded or permissions on the specified output directory: %s",
			config.Vars.CucumberDir(),
		)
	}
	audit.State.PrintSummary()
	exit(s)
}

// --silent disables, and otherwise only shows on ERROR/WARN
func showIndicator() bool {
	return (config.Vars.LogLevel == "ERROR" || config.Vars.LogLevel == "WARN") && !config.Vars.Silent
}

func exit(status int) {
	if showIndicator() {
		config.Spinner.Stop()
	}
	os.Exit(status)
}

// setupCloseHandler creates a 'listener' on a new goroutine which will notify the
// program if it receives an interrupt from the OS. We then handle this by calling
// our clean up procedure and exiting the program.
// Ref: https://golangcode.com/handle-ctrl-c-exit-in-terminal/
func setupCloseHandler() {
	c := make(chan os.Signal)
	signal.Notify(c, os.Interrupt, syscall.SIGTERM)
	go func() {
		<-c
		log.Printf("Execution aborted - %v", "SIGTERM")
		probr.CleanupTmp()
		// TODO: Additional cleanup may be needed. For instance, any pods created during tests are not being dropped if aborted.
		os.Exit(0)
	}()
}
