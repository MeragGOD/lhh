package algorithms

import (
	"fmt"
	"log"
	"math"
	"net/http"
	"strconv"
	"sync"

	"github.com/KeepTheBeats/routing-algorithms/random"
	"github.com/astaxie/beego"
	chart "github.com/wcharczuk/go-chart"

	asmodel "emcontroller/auto-schedule/model"
)

/*
MTDP – Minimizing Total Data Center Power
(Cài lại bám sát ý tưởng paper ISLPED’09, không dùng priority trong fitness)

Mục tiêu:
  - Minimize P_DC = P_server + P_cooling + penalty_reject
  - GA vẫn giống các thuật toán khác (population, crossover, mutation, selection)
*/

// Minimizing Total Data Center Power (MTDP)
type Mtdp struct {
	ChromosomesCount     int
	IterationCount       int
	CrossoverProbability float64
	MutationProbability  float64

	StopNoUpdateIteration int
	CurNoUpdateIteration  int

	// Nhiệt độ trung bình data center (dùng nếu cloud không có TemperatureC)
	AvgTemperature float64

	// Ghi lại best solution qua các iteration
	BestFitnessRecords   []float64
	BestSolnRecords      []asmodel.Solution
	BestFitnessEachIter  []float64
}

// Constructor
func NewMtdp(chromosomesCount int, iterationCount int,
	crossoverProbability float64, mutationProbability float64,
	stopNoUpdateIteration int) *Mtdp {

	return &Mtdp{
		ChromosomesCount:      chromosomesCount,
		IterationCount:        iterationCount,
		CrossoverProbability:  crossoverProbability,
		MutationProbability:   mutationProbability,
		StopNoUpdateIteration: stopNoUpdateIteration,
		CurNoUpdateIteration:  0,
		AvgTemperature:        25.0,
		BestFitnessRecords:    nil,
		BestSolnRecords:       nil,
		BestFitnessEachIter:   nil,
	}
}

// ====================== GA KHUNG CHUNG ======================

func (m *Mtdp) Schedule(clouds map[string]asmodel.Cloud,
	apps map[string]asmodel.Application,
	appsOrder []string) (asmodel.Solution, error) {

	beego.Info("Using scheduling algorithm:", MTDPName)

	m.calculateAvgTemperature(clouds)
	beego.Info("AvgTemperature for MTDP:", m.AvgTemperature, "°C")

	// khởi tạo population ban đầu (giống CmpRandomAcceptMostSolution)
	initPopulation := m.initialize(clouds, apps, appsOrder)

	// iteration 0
	currentPopulation := m.selectionOperator(clouds, apps, initPopulation)

	// các iteration tiếp theo
	for iter := 1; iter <= m.IterationCount; iter++ {

		currentPopulation = m.crossoverOperator(clouds, apps, appsOrder, currentPopulation)
		currentPopulation = m.mutationOperator(clouds, apps, appsOrder, currentPopulation)
		currentPopulation = m.selectionOperator(clouds, apps, currentPopulation)

		if m.CurNoUpdateIteration > m.StopNoUpdateIteration {
			break
		}
	}

	beego.Info("Best fitness in each iteration:", m.BestFitnessEachIter)
	beego.Info("Final BestFitnessRecords:", m.BestFitnessRecords)
	beego.Info("Total iteration number (the following 2 should be equal):",
		len(m.BestFitnessRecords), len(m.BestSolnRecords))

	if len(m.BestSolnRecords) == 0 {
		return asmodel.GenEmptySoln(), fmt.Errorf("MTDP: no solution recorded")
	}
	return m.BestSolnRecords[len(m.BestSolnRecords)-1], nil
}

// ====================== HELPER: NHIỆT ĐỘ ======================

func (m *Mtdp) calculateAvgTemperature(clouds map[string]asmodel.Cloud) {
	if len(clouds) == 0 {
		m.AvgTemperature = 25.0
		return
	}
	var sum float64
	var cnt int
	for _, c := range clouds {
		t := c.TemperatureC
		if t <= 0 {
			continue
		}
		sum += t
		cnt++
	}
	if cnt == 0 {
		m.AvgTemperature = 25.0
	} else {
		m.AvgTemperature = sum / float64(cnt)
	}
}

// ====================== INIT POPULATION ======================

func (m *Mtdp) initialize(clouds map[string]asmodel.Cloud,
	apps map[string]asmodel.Application,
	appsOrder []string) []asmodel.Solution {

	pop := make([]asmodel.Solution, 0, m.ChromosomesCount)
	for i := 0; i < m.ChromosomesCount; i++ {
		s := CmpRandomAcceptMostSolution(clouds, apps, appsOrder)
		pop = append(pop, s)
	}
	return pop
}

// ====================== SELECTION ======================

func (m *Mtdp) selectionOperator(clouds map[string]asmodel.Cloud,
	apps map[string]asmodel.Application,
	population []asmodel.Solution) []asmodel.Solution {

	fitnesses := make([]float64, len(population))

	var mu sync.Mutex
	var wg sync.WaitGroup

	for i := 0; i < len(population); i++ {
		wg.Add(1)
		go func(idx int) {
			defer wg.Done()
			f := m.Fitness(clouds, apps, population[idx])
			mu.Lock()
			fitnesses[idx] = f
			mu.Unlock()
		}(i)
	}
	wg.Wait()

	beego.Info("MTDP fitness this iteration:", fitnesses)

	newPopulation := make([]asmodel.Solution, 0, m.ChromosomesCount)
	pickHelper := make([]int, len(fitnesses))

	bestFitThisIter := -math.MaxFloat64
	bestFitThisIterIdx := 0

	for i := 0; i < m.ChromosomesCount; i++ {
		// binary tournament
		picked := random.RandomPickN(pickHelper, 2)
		selIdx := picked[0]
		if fitnesses[picked[1]] > fitnesses[picked[0]] {
			selIdx = picked[1]
		}

		newChrom := asmodel.SolutionCopy(population[selIdx])
		newPopulation = append(newPopulation, newChrom)

		if fitnesses[selIdx] > bestFitThisIter {
			bestFitThisIter = fitnesses[selIdx]
			bestFitThisIterIdx = selIdx
		}
	}

	// update global-best
	if len(m.BestFitnessRecords) != len(m.BestSolnRecords) {
		panic(fmt.Sprintf("MTDP: len(BestFitnessRecords)=%d != len(BestSolnRecords)=%d",
			len(m.BestFitnessRecords), len(m.BestSolnRecords)))
	}

	var bestFitAll float64
	var bestSolnAll asmodel.Solution

	if len(m.BestFitnessRecords) == 0 {
		bestFitAll = bestFitThisIter
		bestSolnAll = population[bestFitThisIterIdx]
		m.CurNoUpdateIteration = 0
	} else {
		bestFitAll = m.BestFitnessRecords[len(m.BestFitnessRecords)-1]
		bestSolnAll = m.BestSolnRecords[len(m.BestSolnRecords)-1]
		if bestFitThisIter > bestFitAll {
			bestFitAll = bestFitThisIter
			bestSolnAll = population[bestFitThisIterIdx]
			m.CurNoUpdateIteration = 0
		} else {
			m.CurNoUpdateIteration++
		}
	}

	m.BestFitnessEachIter = append(m.BestFitnessEachIter, bestFitThisIter)
	m.BestFitnessRecords = append(m.BestFitnessRecords, bestFitAll)
	m.BestSolnRecords = append(m.BestSolnRecords, asmodel.SolutionCopy(bestSolnAll))

	return newPopulation
}

// ====================== FITNESS: BASED ON POWER ======================

func (m *Mtdp) Fitness(clouds map[string]asmodel.Cloud,
	apps map[string]asmodel.Application,
	chromosome asmodel.Solution) float64 {

	// nếu chromosome thiếu gene cho app → rất tệ
	if len(chromosome.AppsSolution) == 0 {
		return -1e12
	}

	// tham số model (đơn vị W, OC gần sát paper nhưng đơn giản)
	const (
		pIdlePerCloud   = 120.0
		pPeakPerCloud   = 250.0
		penaltyReject   = 800.0
		minCOP          = 1.5
		maxCOP          = 4.5
		minTempForCOP   = 18.0
		maxTempForCOP   = 28.0
	)

	// nhóm CPU per cloud, đếm rejected
	perCloudCpu := make(map[string]float64)
	rejectedCount := 0

	for appName, app := range apps {
		gene, ok := chromosome.AppsSolution[appName]
		if !ok {
			// không có gene cho app này → coi như reject + phạt nặng
			rejectedCount++
			continue
		}
		if !gene.Accepted {
			rejectedCount++
			continue
		}

		cpu := gene.AllocatedCpuCore
		if cpu <= 0 {
			cpu = app.Resources.CpuCore
			if cpu <= 0 {
				cpu = 1
			}
		}

		clName := gene.TargetCloudName
		if clName == "" {
			// không gán cloud → coi như reject
			rejectedCount++
			continue
		}
		perCloudCpu[clName] += float64(cpu)
	}

	// tính P_server + P_cool
	var totalPower float64 = 0

	for clName, usedCpu := range perCloudCpu {
		if usedCpu <= 0 {
			continue
		}

		// "utilization" giả định (không cần biết capacity thật)
		util := usedCpu / (usedCpu + 4.0) // saturates < 1

		// server power cho cloud này
		pServer := pIdlePerCloud + (pPeakPerCloud-pIdlePerCloud)*util

		// nhiệt độ cloud / default avg
		temp := m.AvgTemperature
		if c, ok := clouds[clName]; ok && c.TemperatureC > 0 {
			temp = c.TemperatureC
		}
		if temp < minTempForCOP {
			temp = minTempForCOP
		}
		if temp > maxTempForCOP {
			temp = maxTempForCOP
		}

		// COP tăng theo nhiệt độ (warm air supply → higher COP)
		r := (temp - minTempForCOP) / (maxTempForCOP - minTempForCOP)
		cop := minCOP + (maxCOP-minCOP)*r
		if cop < 0.5 {
			cop = 0.5
		}

		pCool := pServer / cop
		totalPower += pServer + pCool
	}

	// Penalty cho rejected apps (MTDP muốn phục vụ workload, không bỏ app)
	totalPower += penaltyReject * float64(rejectedCount)

	// GA maximizes fitness → ta đổi dấu
	return -totalPower
}

// ====================== CROSSOVER ======================

func (m *Mtdp) crossoverOperator(clouds map[string]asmodel.Cloud,
	apps map[string]asmodel.Application,
	appsOrder []string,
	population []asmodel.Solution) []asmodel.Solution {

	if len(apps) <= 1 {
		return population
	}

	var idxNeed []int
	for i := 0; i < len(population); i++ {
		if random.RandomFloat64(0, 1) < m.CrossoverProbability {
			idxNeed = append(idxNeed, i)
		}
	}

	var crossovered []asmodel.Solution
	whetherCrossover := make([]bool, len(population))
	var mu sync.Mutex
	var wg sync.WaitGroup

	for len(idxNeed) > 1 {
		firstPos := random.RandomInt(0, len(idxNeed)-1)
		firstIdx := idxNeed[firstPos]
		idxNeed = append(idxNeed[:firstPos], idxNeed[firstPos+1:]...)
		whetherCrossover[firstIdx] = true

		secondPos := random.RandomInt(0, len(idxNeed)-1)
		secondIdx := idxNeed[secondPos]
		idxNeed = append(idxNeed[:secondPos], idxNeed[secondPos+1:]...)
		whetherCrossover[secondIdx] = true

		ch1 := asmodel.SolutionCopy(population[firstIdx])
		ch2 := asmodel.SolutionCopy(population[secondIdx])

		wg.Add(1)
		go func(a, b asmodel.Solution) {
			defer wg.Done()
			n1, n2 := CmpAllPossTwoPointCrossover(a, b, clouds, apps, appsOrder)
			mu.Lock()
			crossovered = append(crossovered, n1, n2)
			mu.Unlock()
		}(ch1, ch2)
	}
	wg.Wait()

	for i := 0; i < len(population); i++ {
		if !whetherCrossover[i] {
			crossovered = append(crossovered, asmodel.SolutionCopy(population[i]))
		}
	}

	return crossovered
}

// ====================== MUTATION ======================

func (m *Mtdp) mutationOperator(clouds map[string]asmodel.Cloud,
	apps map[string]asmodel.Application,
	appsOrder []string,
	population []asmodel.Solution) []asmodel.Solution {

	mutated := make([]asmodel.Solution, len(population))
	var mu sync.Mutex
	var wg sync.WaitGroup

	for i := 0; i < len(population); i++ {
		wg.Add(1)
		go func(chromIdx int) {
			defer wg.Done()

			for {
				newChrom := asmodel.GenEmptySoln()
				for appName, oriGene := range population[chromIdx].AppsSolution {
					if random.RandomFloat64(0, 1) < m.MutationProbability {
						newChrom.AppsSolution[appName] = m.geneMutate(clouds, oriGene)
					} else {
						newChrom.AppsSolution[appName] = asmodel.SasCopy(oriGene)
					}
				}
				newChrom, ok := CmpRefineSoln(clouds, apps, appsOrder, newChrom)
				if ok {
					mu.Lock()
					mutated[chromIdx] = newChrom
					mu.Unlock()
					break
				}
			}
		}(i)
	}
	wg.Wait()
	return mutated
}

// gene mutation
func (m *Mtdp) geneMutate(clouds map[string]asmodel.Cloud,
	ori asmodel.SingleAppSolution) asmodel.SingleAppSolution {

	mut := asmodel.SasCopy(asmodel.RejSoln)
	cloudsToPick := asmodel.CloudMapCopy(clouds)

	if ori.Accepted {
		delete(cloudsToPick, ori.TargetCloudName)
	}

	// 50% accept / 50% reject
	mut.Accepted = random.RandomInt(0, 1) == 0
	if mut.Accepted {
		mut.TargetCloudName, _ = randomCloudMapPick(cloudsToPick)
	}
	return mut
}

// ====================== VẼ BIỂU ĐỒ EVOLUTION (OPTIONAL) ======================

func (m *Mtdp) DrawEvoChart() {
	drawChartFunc := func(res http.ResponseWriter, r *http.Request) {
		var xValuesAllBest []float64
		for i := range m.BestFitnessRecords {
			xValuesAllBest = append(xValuesAllBest, float64(i))
		}

		graph := chart.Chart{
			Title: "MTDP Evolution",
			XAxis: chart.XAxis{
				Name:      "Iteration Number",
				NameStyle: chart.StyleShow(),
				Style:     chart.StyleShow(),
				ValueFormatter: func(v interface{}) string {
					return strconv.FormatInt(int64(v.(float64)), 10)
				},
			},
			YAxis: chart.YAxis{
				AxisType:  chart.YAxisSecondary,
				Name:      "Fitness",
				NameStyle: chart.StyleShow(),
				Style:     chart.StyleShow(),
			},
			Background: chart.Style{
				Padding: chart.Box{
					Top:  50,
					Left: 20,
				},
			},
			Series: []chart.Series{
				chart.ContinuousSeries{
					Name:    "Best Fitness in all iteration",
					XValues: xValuesAllBest,
					YValues: m.BestFitnessRecords,
				},
				chart.ContinuousSeries{
					Name:    "Best Fitness in each iteration",
					XValues: xValuesAllBest,
					YValues: m.BestFitnessEachIter,
					Style: chart.Style{
						Show:            true,
						StrokeDashArray: []float64{5.0, 3.0, 2.0, 3.0},
						StrokeWidth:     1,
					},
				},
			},
		}

		graph.Elements = []chart.Renderable{
			chart.LegendThin(&graph),
		}

		res.Header().Set("Content-Type", "image/png")
		if err := graph.Render(chart.PNG, res); err != nil {
			log.Println("MTDP DrawEvoChart render error:", err)
		}
	}

	http.HandleFunc("/", drawChartFunc)
	if err := http.ListenAndServe(":8080", nil); err != nil {
		log.Println("MTDP DrawEvoChart ListenAndServe error:", err)
	}
}
