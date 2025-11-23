package weather

import (
	"encoding/json"
	"fmt"
	"net/http"
	"net/url"
	"strconv"
	"sync"
	"time"

	"github.com/astaxie/beego/logs" // Import beego logger nếu dùng trong project
)

// Cache entry for response (TTL 10min)
type cacheEntry struct {
	data       WeatherResponse
	expiresAt time.Time
}

// Cache map with mutex
var (
	cache     = make(map[string]*cacheEntry)
	cacheMu   sync.RWMutex
	httpClient = &http.Client{
		Timeout: 10 * time.Second,
	}
)

// ========= STRUCTS =========
type WeatherResponse struct {
	Latitude       float64        `json:"latitude"`
	Longitude      float64        `json:"longitude"`
	CurrentWeather CurrentWeather `json:"current"`
}

type CurrentWeather struct {
	Time        string  `json:"time"`
	Temperature float64 `json:"temperature_2m"`
	Humidity    float64 `json:"relative_humidity_2m,omitempty"` // Optional
	WindSpeed   float64 `json:"wind_speed_10m,omitempty"`
}

// ========= GET CURRENT WEATHER =========
func GetCurrentTemperature(latitude, longitude string) (float64, error) {
	// Validate lat/lon
	if lat, err := strconv.ParseFloat(latitude, 64); err != nil || lat < -90 || lat > 90 {
		return 0, fmt.Errorf("invalid latitude: %s", latitude)
	}
	if lon, err := strconv.ParseFloat(longitude, 64); err != nil || lon < -180 || lon > 180 {
		return 0, fmt.Errorf("invalid longitude: %s", longitude)
	}

	key := latitude + "," + longitude
	cacheMu.RLock()
	entry, ok := cache[key]
	cacheMu.RUnlock()
	if ok && time.Now().Before(entry.expiresAt) {
		logs.Info("Cache hit for %s", key)
		return entry.data.CurrentWeather.Temperature, nil
	}

	// Build URL
	baseURL, err := url.Parse("https://api.open-meteo.com/v1/forecast")
	if err != nil {
		return 0, fmt.Errorf("lỗi phân tích cú pháp URL cơ sở: %w", err)
	}
	q := baseURL.Query()
	q.Add("latitude", latitude)
	q.Add("longitude", longitude)
	q.Add("current", "temperature_2m,relative_humidity_2m,wind_speed_10m") // Add more fields
	baseURL.RawQuery = q.Encode()

	// Create request
	req, err := http.NewRequest(http.MethodGet, baseURL.String(), nil)
	if err != nil {
		return 0, fmt.Errorf("lỗi tạo yêu cầu HTTP: %w", err)
	}
	req.Header.Set("User-Agent", "emcontroller-client/1.0")

	// Do request
	resp, err := httpClient.Do(req)
	if err != nil {
		logs.Error("HTTP request failed: %v", err)
		return 0, fmt.Errorf("lỗi thực hiện yêu cầu HTTP: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		logs.Warn("API status: %s", resp.Status)
		return 0, fmt.Errorf("API trả về trạng thái không thành công: %s", resp.Status)
	}

	// Decode JSON
	var weatherData WeatherResponse
	err = json.NewDecoder(resp.Body).Decode(&weatherData)
	if err != nil {
		return 0, fmt.Errorf("lỗi giải mã phản hồi JSON: %w", err)
	}

	// Cache response (10min TTL)
	cacheMu.Lock()
	cache[key] = &cacheEntry{
		data:       weatherData,
		expiresAt: time.Now().Add(10 * time.Minute),
	}
	cacheMu.Unlock()

	logs.Info("Fetched temperature %f°C for %s", weatherData.CurrentWeather.Temperature, key)
	return weatherData.CurrentWeather.Temperature, nil
}