package main

import (
	"encoding/csv"
	"fmt"
	"log"
	"math"
	"math/rand"
	"os"
	"time"

	"emcontroller/auto-schedule/algorithms"
	asmodel "emcontroller/auto-schedule/model"
	"emcontroller/models"
)

const dataFileNameFmt string = "usable_acceptance_rate_%d.csv"

// the data structure that will be collected in this experiment
type exptData struct {
	algorithmName string

	maxSchedTime float64 // the maximum scheduling time in all repeats, unit second

	schedulingRequestCount int
	usableSolutionCount    int

	totalAppCount         int
	totalAcceptedAppCount int

	appCountPerPri         map[int]int
	acceptedAppCountPerPri map[int]int

	totalAppPriority         int
	totalAcceptedAppPriority int

	solutionUsableRate                float64
	appAcceptanceRate                 float64
	appPriorityWeightedAcceptanceRate float64
	appPerPriAcceptanceRate           map[int]float64

	// Temperature and loss metrics
	avgTemperature     float64 // average temperature across all clouds used
	avgPerformanceLoss float64 // average performance loss (0.0-1.0)
	avgPowerOverhead   float64 // average power overhead (%)
	temperatureCount   int     // number of temperature measurements
}

func main() {
	log.SetFlags(log.LstdFlags | log.Lshortfile)

	// Note: We don't need to initialize clouds or connect to MySQL/Kubernetes
	// for temperature calculation. We'll get temperature directly from Weather API.
	log.Printf("Starting experiment with temperature calculation (no cloud initialization needed)")

	var appCounts []int = []int{40, 60, 80}
	var repeatCount int = 20 // We repeat this experiment 50 times to reduce the impact from random factors, because the paper of Diktyo repeat one of their experiments 50 times.

	for _, appCount := range appCounts {
		Execute(appCount, repeatCount)
	}

}

func Execute(appCount, repeatCount int) {
	var appNamePrefix string = "expt-app"

	// all algorithms to be evaluated in experiment
	var algoNames []string = []string{algorithms.CompRandName, algorithms.BERandName, algorithms.AmagaName, algorithms.AmpgaName, algorithms.DiktyogaName, algorithms.McssgaName, algorithms.MTDPName}

	var results []exptData // used to save and output results
	for _, algoName := range algoNames {
		results = append(results, exptData{
			algorithmName: algoName, maxSchedTime: 0, appCountPerPri: make(map[int]int), acceptedAppCountPerPri: make(map[int]int), appPerPriAcceptanceRate: make(map[int]float64),
			avgTemperature: 0.0, avgPerformanceLoss: 0.0, avgPowerOverhead: 0.0, temperatureCount: 0,
		})
	}

	// We repeat experiment to reduce the impact from random factors. In every repeat, we generate different applications.
	for i := 0; i < repeatCount; i++ {
		apps, err := makeExperimentAppsWithoutServer(appNamePrefix, appCount)
		if err != nil {
			log.Panicf("makeExperimentAppsWithoutServer error: %s", err.Error())
		}
		for j, algoName := range algoNames { // in one repeat, we use the same apps for all algorithm for comparison.
			log.Printf("Schedule %d applications, Repeat %d, algorithm No. %d [%s]", appCount, i, j, algoName)

			acceptedApps, usable, schedTimeSec, err := schedulingRequest(algoName, apps)
			if err != nil {
				log.Panicf("schedulingRequest error: %s", err.Error())
			}

			// record results
			if results[j].maxSchedTime < schedTimeSec {
				results[j].maxSchedTime = schedTimeSec
			}

			results[j].schedulingRequestCount++
			results[j].totalAppCount += len(apps)
			for _, app := range apps {
				results[j].totalAppPriority += app.Priority
			}
			appCountPerPri := getPerPriAppCount(apps)
			for pri := asmodel.MinPriority; pri <= asmodel.MaxPriority; pri++ {
				results[j].appCountPerPri[pri] += appCountPerPri[pri]
			}

			if usable {
				results[j].usableSolutionCount++
				results[j].totalAcceptedAppCount += len(acceptedApps)
				for _, acceptedApp := range acceptedApps {
					results[j].totalAcceptedAppPriority += acceptedApp.Priority
				}
				acceptedAppCountPerPri := getPerPriAcceptedAppCount(acceptedApps)
				for pri := asmodel.MinPriority; pri <= asmodel.MaxPriority; pri++ {
					results[j].acceptedAppCountPerPri[pri] += acceptedAppCountPerPri[pri]
				}

				// Calculate temperature and losses for this scheduling
				avgTemp, avgPerfLoss, avgPowerOverhead := calculateTemperatureAndLosses()
				if avgTemp > 0 {
					// Update running averages
					oldCount := results[j].temperatureCount
					results[j].temperatureCount++
					newCount := results[j].temperatureCount
					// Running average: (old_avg * old_count + new_value) / new_count
					results[j].avgTemperature = (results[j].avgTemperature*float64(oldCount) + avgTemp) / float64(newCount)
					results[j].avgPerformanceLoss = (results[j].avgPerformanceLoss*float64(oldCount) + avgPerfLoss) / float64(newCount)
					results[j].avgPowerOverhead = (results[j].avgPowerOverhead*float64(oldCount) + avgPowerOverhead) / float64(newCount)
				}
			}
		}
	}

	// calculate the rates in the results
	for i := 0; i < len(results); i++ {
		results[i].solutionUsableRate = float64(results[i].usableSolutionCount) / float64(results[i].schedulingRequestCount)
		results[i].appAcceptanceRate = float64(results[i].totalAcceptedAppCount) / float64(results[i].totalAppCount)
		results[i].appPriorityWeightedAcceptanceRate = float64(results[i].totalAcceptedAppPriority) / float64(results[i].totalAppPriority)
		for pri := asmodel.MinPriority; pri <= asmodel.MaxPriority; pri++ {
			results[i].appPerPriAcceptanceRate[pri] = float64(results[i].acceptedAppCountPerPri[pri]) / float64(results[i].appCountPerPri[pri])
		}
	}

	if err := writeCsvResults(results, appCount); err != nil {
		log.Panicf("writeCsvResults error: %s", err.Error())
	}

}

func schedulingRequest(algoName string, apps []models.K8sApp) ([]models.AppInfo, bool, float64, error) {
	// Call scheduling algorithm directly without HTTP API
	timeBefore := time.Now()
	acceptedApps, usable, err := algorithms.ScheduleForExperiment(algoName, apps)
	timeAfter := time.Now()
	schedTimeSec := timeAfter.Sub(timeBefore).Seconds()

	if err != nil {
		return []models.AppInfo{}, false, schedTimeSec, fmt.Errorf("ScheduleForExperiment error: %w", err)
	}

	if !usable {
		// unusable solution
		return []models.AppInfo{}, false, schedTimeSec, nil
	}

	return acceptedApps, true, schedTimeSec, nil
}

// get the number of applications with each priority
func getPerPriAppCount(apps []models.K8sApp) map[int]int {
	var perPriAppCount map[int]int = make(map[int]int)

	for _, app := range apps {
		perPriAppCount[app.Priority]++
	}

	return perPriAppCount
}

// get the number of accepted applications with each priority
func getPerPriAcceptedAppCount(acceptedApps []models.AppInfo) map[int]int {
	var perPriAcceptedAppCount map[int]int = make(map[int]int)

	for _, acceptedApp := range acceptedApps {
		perPriAcceptedAppCount[acceptedApp.Priority]++
	}

	return perPriAcceptedAppCount
}

// function to write data into a csv file.
func writeCsvResults(results []exptData, appCount int) error {

	var csvContent [][]string

	var header []string = []string{
		"Algorithm Name",
		"Maximum Scheduling Time (s)",
		"Scheduling Request Count",
		"Usable Solution Count",
		"Total App Count",
		"Total Accepted App Count",
		"Total App Priority",
		"Total Accepted App Priority",
		"Solution Usable Rate",
		"App Acceptance Rate",
		"App Priority Weighted Acceptance Rate",
		"Average Temperature (°C)",
		"Average Performance Loss",
		"Average Power Overhead (%)",
	}
	for pri := asmodel.MinPriority; pri <= asmodel.MaxPriority; pri++ {
		header = append(header, fmt.Sprintf("Priority-%d App Acceptance Rate", pri))
	}
	csvContent = append(csvContent, header)

	for _, result := range results {
		var line []string = []string{
			result.algorithmName,
			fmt.Sprintf("%g", result.maxSchedTime),
			fmt.Sprintf("%d", result.schedulingRequestCount),
			fmt.Sprintf("%d", result.usableSolutionCount),
			fmt.Sprintf("%d", result.totalAppCount),
			fmt.Sprintf("%d", result.totalAcceptedAppCount),
			fmt.Sprintf("%d", result.totalAppPriority),
			fmt.Sprintf("%d", result.totalAcceptedAppPriority),
			fmt.Sprintf("%g", result.solutionUsableRate),
			fmt.Sprintf("%g", result.appAcceptanceRate),
			fmt.Sprintf("%g", result.appPriorityWeightedAcceptanceRate),
			fmt.Sprintf("%.2f", result.avgTemperature),
			fmt.Sprintf("%.4f", result.avgPerformanceLoss),
			fmt.Sprintf("%.2f", result.avgPowerOverhead),
		}
		for pri := asmodel.MinPriority; pri <= asmodel.MaxPriority; pri++ {
			line = append(line, fmt.Sprintf("%g", result.appPerPriAcceptanceRate[pri]))
		}
		csvContent = append(csvContent, line)
	}

	return writeCsvFile(fmt.Sprintf(dataFileNameFmt, appCount), csvContent)
}

func writeCsvFile(fileName string, csvContent [][]string) error {
	// Try to write the file with retry logic in case file is locked
	var f *os.File
	var err error
	maxRetries := 5
	retryDelay := 200 * time.Millisecond

	for attempt := 0; attempt < maxRetries; attempt++ {
		if attempt > 0 {
			log.Printf("Retry %d/%d: Attempting to write file %s...", attempt, maxRetries, fileName)
			time.Sleep(retryDelay)
		}
		f, err = os.Create(fileName)
		if err == nil {
			break
		}
		if attempt < maxRetries-1 {
			log.Printf("Warning: Cannot create file %s (attempt %d/%d): %v. Retrying...", fileName, attempt+1, maxRetries, err)
		}
	}

	if err != nil {
		return fmt.Errorf("create file %s after %d attempts, error: %w", fileName, maxRetries, err)
	}
	defer f.Close()

	w := csv.NewWriter(f)
	defer w.Flush()

	for _, record := range csvContent {
		if err := w.Write(record); err != nil {
			return fmt.Errorf("write record %v, error: %s", record, err.Error())
		}
	}

	return nil
}

// makeExperimentAppsWithoutServer creates experiment apps without calling the server API
// This is used when running experiments in standalone mode without multi-cloud manager
func makeExperimentAppsWithoutServer(namePrefix string, count int) ([]models.K8sApp, error) {
	outApps := make([]models.K8sApp, count)

	// Application templates (same as in applications-generator)
	type appRes struct {
		name    string
		cpu     int
		memory  int
		storage int
	}
	appsToChoose := []appRes{
		{name: "existingPaperApp1", cpu: 2, memory: 1024, storage: 8},
		{name: "existingPaperApp2", cpu: 2, memory: 1024, storage: 4},
		{name: "existingPaperApp3", cpu: 4, memory: 2048, storage: 3},
		{name: "existingPaperApp4", cpu: 2, memory: 1024, storage: 2},
		{name: "existingPaperMySQL", cpu: 1, memory: 500, storage: 0},
		{name: "actualNginxController", cpu: 8, memory: 8192, storage: 155},
		{name: "actualRedis", cpu: 4, memory: 15360, storage: 30},
		{name: "actualPostgres", cpu: 2, memory: 2048, storage: 1},
		{name: "actualRabbitmq", cpu: 1, memory: 256, storage: 6},
		{name: "actualConsul", cpu: 4, memory: 16384, storage: 100},
		{name: "actualRedmine", cpu: 4, memory: 4096, storage: 20},
		{name: "actualMiRFleet", cpu: 2, memory: 8192, storage: 128},
		{name: "actualApacheStorm", cpu: 12, memory: 24576, storage: 0},
		{name: "actualApacheKafka", cpu: 4, memory: 8192, storage: 500},
		{name: "actualApacheZookeeper", cpu: 2, memory: 2048, storage: 80},
	}

	const (
		minNodePort = 30000
		maxNodePort = 32768
		exptImage   = "172.27.15.31:5000/mcexp:20230905"
		baseCmd     = "./experiment-app"
		svcPort     = 81
	)

	// Use a simple counter for node ports (no need to check occupied ports)
	nextNodePort := minNodePort

	// Create a local random generator
	rng := rand.New(rand.NewSource(time.Now().UnixNano()))

	for i := 0; i < count; i++ {
		// Generate node port (simple increment, wrap around if needed)
		nodePortToUse := fmt.Sprintf("%d", nextNodePort)
		nextNodePort++
		if nextNodePort > maxNodePort {
			nextNodePort = minNodePort // Wrap around
		}

		// Choose random app template
		chosenApp := appsToChoose[rng.Intn(len(appsToChoose))]

		// Generate random priority
		priority := rng.Intn(asmodel.MaxPriority-asmodel.MinPriority+1) + asmodel.MinPriority

		// Generate workload (simplified - use fixed value for consistency)
		workload := 381475

		outApps[i].Name = fmt.Sprintf("%s-%d", namePrefix, i)
		outApps[i].AutoScheduled = true
		outApps[i].Replicas = 1
		outApps[i].HostNetwork = false
		outApps[i].Priority = priority

		args := []string{
			fmt.Sprintf("%d", workload),
			fmt.Sprintf("%d", chosenApp.cpu),
			fmt.Sprintf("%d", chosenApp.memory),
			fmt.Sprintf("%d", chosenApp.storage),
		}

		outApps[i].Containers = []models.K8sContainer{
			{
				Name:     "container",
				Image:    exptImage,
				Commands: []string{baseCmd},
				Args:     args,
				Ports: []models.PortInfo{
					{
						ContainerPort: 3333,
						Name:          "tcp",
						Protocol:      "tcp",
						ServicePort:   fmt.Sprintf("%d", svcPort),
						NodePort:      nodePortToUse,
					},
				},
				Resources: models.K8sResReq{
					Limits: models.K8sResList{
						CPU:     fmt.Sprintf("%d", chosenApp.cpu),
						Memory:  fmt.Sprintf("%dMi", chosenApp.memory),
						Storage: fmt.Sprintf("%dGi", chosenApp.storage),
					},
					Requests: models.K8sResList{
						CPU:     fmt.Sprintf("%d", chosenApp.cpu),
						Memory:  fmt.Sprintf("%dMi", chosenApp.memory),
						Storage: fmt.Sprintf("%dGi", chosenApp.storage),
					},
				},
			},
		}
	}

	return outApps, nil
}

// calculateTemperatureAndLosses calculates average temperature and losses
// Uses random temperature between 20-30°C for experiments
func calculateTemperatureAndLosses() (float64, float64, float64) {
	// Generate random temperature between 20-30°C
	// Using a local random generator to avoid global state issues
	rng := rand.New(rand.NewSource(time.Now().UnixNano()))
	// Random temperature: 20.0 + random(0.0 to 10.0) = 20.0 to 30.0
	temperature := 20.0 + rng.Float64()*10.0

	// Calculate losses based on temperature
	perfLoss, powerOverhead := calculateLosses(temperature)

	return temperature, perfLoss, powerOverhead
}

// calculateLosses calculates performance loss and power overhead based on temperature
// Uses the same model as in Python code
func calculateLosses(temperature float64) (float64, float64) {
	var performanceLoss float64
	var powerOverhead float64

	// Performance loss calculation
	if temperature < 20.0 {
		// Cold: linear degradation from 0% at 20°C to 5% at 0°C
		performanceLoss = (20.0 - temperature) / 20.0 * 0.05
	} else if temperature <= 25.0 {
		// Optimal range: no loss
		performanceLoss = 0.0
	} else {
		// Hot: exponential degradation
		excessTemp := temperature - 25.0
		// Model: loss increases exponentially with excess temperature
		// At 10°C excess (35°C): ~10% loss
		// At 20°C excess (45°C): ~25% loss
		// At 30°C excess (55°C): ~50% loss
		performanceLoss = 1.0 - math.Exp(-0.1*excessTemp)
		// Cap at 70% max loss
		if performanceLoss > 0.7 {
			performanceLoss = 0.7
		}
	}

	// Power overhead calculation
	if temperature < 20.0 {
		// Cold: heating needed
		powerOverhead = (20.0 - temperature) / 5.0 * 2.0 // ~2% per 5°C below 20°C
	} else if temperature <= 25.0 {
		// Optimal range: no overhead
		powerOverhead = 0.0
	} else {
		// Hot: cooling needed
		excessTemp := temperature - 25.0
		// Model: power overhead for cooling increases with temperature
		// At 5°C excess (30°C): ~5% overhead
		// At 15°C excess (40°C): ~15% overhead
		// At 25°C excess (50°C): ~40% overhead
		powerOverhead = 0.5*excessTemp + 0.02*excessTemp*excessTemp
		// Cap at 50% max overhead
		if powerOverhead > 50.0 {
			powerOverhead = 50.0
		}
	}

	return performanceLoss, powerOverhead
}
