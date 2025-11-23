package weather

import (
	"testing"
)

func TestGetCurrentTemperature(t *testing.T) {
	// Tọa độ Berlin (ví dụ từ báo cáo)
	lat := "52.52"
	lon := "13.41"

	temp, err := GetCurrentTemperature(lat, lon)

	if err != nil {
		// Nếu có lỗi (ví dụ: mất mạng), test thất bại
		t.Fatalf("GetCurrentTemperature trả về lỗi: %v", err)
	}

	// Nếu thành công, in ra nhiệt độ
	t.Logf("Nhiệt độ hiện tại ở (%.2s, %.2s) là: %.1f°C", lat, lon, temp)

	// Một bài test thực tế sẽ kiểm tra xem temp có nằm trong
	// một khoảng hợp lý không (ví dụ: -50 đến 50)
	if temp < -50 || temp > 50 {
		t.Errorf("Nhiệt độ %.1f°C nằm ngoài khoảng mong đợi", temp)
	}
}
