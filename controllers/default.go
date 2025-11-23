package controllers

import (
	"fmt"
	"time"

	"github.com/astaxie/beego"

	"emcontroller/models"
	"emcontroller/weather" // Import weather
)

type MainController struct {
	beego.Controller
}

func (c *MainController) Get() {
	c.Data["Website"] = models.ControllerName
	c.Data["VersionInfo"] = fmt.Sprintf("Build time: [%s]. Git commit: [%s]\n", models.BuildDate, models.GitCommit)

	// Demo stats nếu models rỗng (thêm tạm để card không 0, thay bằng real data sau)
	c.Data["TotalClouds"] = 2
	c.Data["TotalVMs"] = 5
	c.Data["AvailableResources"] = "80%"
	c.Data["OccupiedResources"] = "20%"

	// Fetch weather mặc định (Hà Nội) cho initial load
	temp, err := weather.GetCurrentTemperature("21.0285", "105.8542")
	if err != nil {
		c.Data["WeatherTemp"] = "N/A (Lỗi: " + err.Error() + ")"
	} else {
		c.Data["WeatherTemp"] = fmt.Sprintf("%.1f°C", temp)
	}
	c.Data["WeatherTime"] = time.Now().Format("15:04")

	c.TplName = "index.tpl"
}

// GetWeather handles AJAX request for dynamic weather update (/api/weather?city=...)
func (c *MainController) GetWeather() {
	city := c.GetString("city")
	var lat, lon string
	switch city {
	case "hanoi":
		lat, lon = "21.0285", "105.8542"
	case "hcm":
		lat, lon = "10.8231", "106.6297"
	case "singapore":
		lat, lon = "1.3521", "103.8198"
	case "tokyo":
		lat, lon = "35.6762", "139.6503"
	default:
		lat, lon = "21.0285", "105.8542" // Default Hà Nội
	}

	temp, err := weather.GetCurrentTemperature(lat, lon)
	if err != nil {
		c.Data["json"] = map[string]interface{}{"error": err.Error()}
		c.ServeJSON()
		return
	}

	// Logic issues/suggestions dựa temp (extend cho humidity/rain nếu cần)
	issues := []string{}
	suggestions := []string{}
	if temp > 35.0 {
		issues = append(issues, "Nhiệt độ cao: Rủi ro overheat data center")
		suggestions = append(suggestions, "Scale up cooling VMs 20% ở AWS Singapore")
	} else if temp < 20.0 {
		issues = append(issues, "Lạnh: Giảm hiệu suất battery backup")
		suggestions = append(suggestions, "Tăng redundancy pods trên GCP")
	} else {
		suggestions = append(suggestions, "Thời tiết lý tưởng – Giữ schedule hiện tại")
	}

	c.Data["json"] = map[string]interface{}{
		"temp":        temp,
		"issues":      issues,
		"suggestions": suggestions,
		"updateTime":  time.Now().Format("15:04"),
	}
	c.ServeJSON()
}
