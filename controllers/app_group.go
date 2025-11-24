package controllers

import (
	"encoding/json"
	"fmt"
	"net/http"
	"strconv"
	"strings"

	"github.com/astaxie/beego"

	"emcontroller/auto-schedule/algorithms"
	"emcontroller/auto-schedule/executors"
	"emcontroller/models"
)

// when deploying an application group, user can use this HTTP header to choose the scheduling algorithm to use.
const (
	SAHeaderKey     string = "Mcm-Scheduling-Algorithm"
	ExTimeOneCpuKey string = "Expected-Time-One-Cpu" // expected application computation time with one CPU core
)

type AppGroupController struct {
	beego.Controller
}

func (c *AppGroupController) DoNewAppGroup() {
	// scheduling, migration, and cleanup cannot be done at the same time
	if !algorithms.ScheMu.TryLock() {
		outErr := fmt.Errorf("Another task of Scheduling, Migration or Cleanup is running. Please try later.")
		beego.Error(outErr)
		c.Ctx.ResponseWriter.WriteHeader(http.StatusLocked)
		if result, err := c.Ctx.ResponseWriter.Write([]byte(outErr.Error())); err != nil {
			beego.Error(fmt.Sprintf("Write Error to response, error: %s, result: %d", err.Error(), result))
		}
		return
	}
	defer algorithms.ScheMu.Unlock()

	// === 1. Chỉ nhận JSON cho thực nghiệm ===
	contentType := strings.ToLower(c.Ctx.Request.Header.Get("Content-Type"))
	beego.Info(fmt.Sprintf("The header \"Content-Type\" is [%s]", contentType))

	if !strings.Contains(contentType, "json") {
		errMsg := "For experiment mode, only application/json body is supported"
		beego.Error(errMsg)
		c.Ctx.ResponseWriter.WriteHeader(http.StatusBadRequest)
		_, _ = c.Ctx.ResponseWriter.Write([]byte(errMsg))
		return
	}

	// === 2. Parse body thành []models.K8sApp ===
	body := c.Ctx.Input.RequestBody
	var apps []models.K8sApp
	if err := json.Unmarshal(body, &apps); err != nil {
		errMsg := fmt.Sprintf("Unmarshal request body to []K8sApp error: %s", err.Error())
		beego.Error(errMsg)
		c.Ctx.ResponseWriter.WriteHeader(http.StatusBadRequest)
		_, _ = c.Ctx.ResponseWriter.Write([]byte(errMsg))
		return
	}

	if len(apps) == 0 {
		errMsg := "No applications provided in request body"
		beego.Error(errMsg)
		c.Ctx.ResponseWriter.WriteHeader(http.StatusBadRequest)
		_, _ = c.Ctx.ResponseWriter.Write([]byte(errMsg))
		return
	}

	// === 3. Lấy tên thuật toán từ header ===
	algoName := c.Ctx.Request.Header.Get(SAHeaderKey)
	if algoName == "" {
		errMsg := "Missing header: " + SAHeaderKey
		beego.Error(errMsg)
		c.Ctx.ResponseWriter.WriteHeader(http.StatusBadRequest)
		_, _ = c.Ctx.ResponseWriter.Write([]byte(errMsg))
		return
	}
	beego.Info(fmt.Sprintf("Run scheduling algorithm [%s] on %d apps", algoName, len(apps)))

	// === 4. Gọi scheduler nội bộ cho thực nghiệm ===
	acceptedApps, usable, err := algorithms.ScheduleForExperiment(algoName, apps)
	if err != nil {
		errMsg := fmt.Sprintf("ScheduleForExperiment error: %s", err.Error())
		beego.Error(errMsg)
		c.Ctx.ResponseWriter.WriteHeader(http.StatusInternalServerError)
		_, _ = c.Ctx.ResponseWriter.Write([]byte(errMsg))
		return
	}

	// === 5. Nếu thuật toán báo unusable solution ===
	if !usable {
		errMsg := "unusable solution"
		beego.Warn(fmt.Sprintf("Algorithm [%s] returned unusable solution", algoName))
		c.Ctx.ResponseWriter.WriteHeader(http.StatusServiceUnavailable) // 503
		_, _ = c.Ctx.ResponseWriter.Write([]byte(errMsg))
		return
	}

	// === 6. Trả về acceptedApps dạng JSON ===
	c.Ctx.ResponseWriter.Header().Set("Content-Type", "application/json")
	c.Ctx.ResponseWriter.WriteHeader(http.StatusOK)
	if err := json.NewEncoder(c.Ctx.ResponseWriter).Encode(acceptedApps); err != nil {
		beego.Error(fmt.Sprintf("Encode acceptedApps to JSON error: %s", err.Error()))
	}
}

// Phần DoNewAppGroupJson / DoNewAppGroupForm để nguyên – dùng cho MCM “thật”
func (c *AppGroupController) DoNewAppGroupJson() {
	var apps []models.K8sApp
	if err := json.Unmarshal(c.Ctx.Input.RequestBody, &apps); err != nil {
		outErr := fmt.Errorf("json.Unmarshal the applications in RequestBody, error: %w", err)
		beego.Error(outErr)
		c.Ctx.ResponseWriter.WriteHeader(http.StatusBadRequest)
		if result, err := c.Ctx.ResponseWriter.Write([]byte(outErr.Error())); err != nil {
			beego.Error(fmt.Sprintf("Write Error to response, error: %s, result: %d", err.Error(), result))
		}
		return
	}

	beego.Info(fmt.Sprintf("From json input, we successfully parsed applications [%+v]", apps))

	schedAlgorithm := c.Ctx.Request.Header.Get(SAHeaderKey)
	beego.Info(fmt.Sprintf("The header %s is [%s]", SAHeaderKey, schedAlgorithm))

	exTimeOneCpuStr := c.Ctx.Request.Header.Get(ExTimeOneCpuKey)
	exTimeOneCpu, err := strconv.ParseFloat(exTimeOneCpuStr, 64)
	if err != nil {
		exTimeOneCpu = algorithms.DefaultExpAppCompuTimeOneCpu
		outErr := fmt.Errorf("parse HTTP header key [%s] value [%s] to float64 error: %s, we set it to the default value [%g]",
			ExTimeOneCpuKey, exTimeOneCpuStr, err.Error(), exTimeOneCpu)
		beego.Error(outErr)
	} else {
		beego.Info(fmt.Sprintf("Parse header %s to float [%g]", ExTimeOneCpuKey, exTimeOneCpu))
	}

	outApps, err, statusCode := executors.CreateAutoScheduleApps(apps, schedAlgorithm, exTimeOneCpu)
	if err != nil {
		outErr := fmt.Errorf("executors.CreateAutoScheduleApps(apps), error: %w", err)
		beego.Error(outErr)
		c.Ctx.ResponseWriter.WriteHeader(statusCode)
		if result, err := c.Ctx.ResponseWriter.Write([]byte(outErr.Error())); err != nil {
			beego.Error(fmt.Sprintf("Write Error to response, error: %s, result: %d", err.Error(), result))
		}
		return
	}

	c.Ctx.Output.Status = http.StatusCreated
	c.Data["json"] = outApps
	c.ServeJSON()
}

func (c *AppGroupController) DoNewAppGroupForm() {
	outErr := fmt.Errorf("Please set the \"Content-Type\" as \"%s\", because the functions to handle other content types have not been implemented.", JsonContentType)
	beego.Error(outErr)
	c.Ctx.ResponseWriter.WriteHeader(http.StatusMethodNotAllowed)
	if result, err := c.Ctx.ResponseWriter.Write([]byte(outErr.Error())); err != nil {
		beego.Error(fmt.Sprintf("Write Error to response, error: %s, result: %d", err.Error(), result))
	}
	return
}
