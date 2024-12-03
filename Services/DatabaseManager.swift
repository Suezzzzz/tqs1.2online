import Foundation

enum APIError: Error {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case serverError(String)
}

class DatabaseManager {
    static let shared = DatabaseManager()
    private let baseURL = "http://47.88.66.19:3000/api"
    
    private init() {}
    
    // MARK: - Models
    struct Driver: Codable {
        let id: Int
        let name: String
        let phone: String?
        let licenseNumber: String
    }
    
    struct Vehicle: Codable {
        let id: Int
        let plateNumber: String
        let vehicleType: String
    }
    
    struct TimeSlot: Codable {
        let id: Int
        let date: String
        let startTime: String
        let endTime: String
        let maxCapacity: Int
    }
    
    struct Registration: Codable {
        let id: Int
        let driverId: Int
        let vehicleId: Int
        let timeSlotId: Int
        let expectedCheckInTime: String
        let status: String
    }
    
    // MARK: - API Methods
    func getDrivers() async throws -> [Driver] {
        guard let url = URL(string: "\(baseURL)/drivers") else {
            throw APIError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([Driver].self, from: data)
    }
    
    func getTimeSlots() async throws -> [TimeSlot] {
        guard let url = URL(string: "\(baseURL)/time-slots") else {
            throw APIError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([TimeSlot].self, from: data)
    }
    
    func createRegistration(driverId: Int, vehicleId: Int, timeSlotId: Int, expectedCheckInTime: String) async throws -> Int {
        guard let url = URL(string: "\(baseURL)/registrations") else {
            throw APIError.invalidURL
        }
        
        let body = [
            "driver_id": driverId,
            "vehicle_id": vehicleId,
            "time_slot_id": timeSlotId,
            "expected_check_in_time": expectedCheckInTime
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode([String: Int].self, from: data)
        return response["id"] ?? 0
    }
} 