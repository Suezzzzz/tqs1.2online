import Foundation
import Combine

class QueueViewModel: ObservableObject {
    @Published var drivers: [DatabaseManager.Driver] = []
    @Published var timeSlots: [DatabaseManager.TimeSlot] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let databaseManager = DatabaseManager.shared
    
    func loadData() async {
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        do {
            async let driversTask = databaseManager.getDrivers()
            async let timeSlotsTask = databaseManager.getTimeSlots()
            
            let (drivers, timeSlots) = try await (driversTask, timeSlotsTask)
            
            DispatchQueue.main.async {
                self.drivers = drivers
                self.timeSlots = timeSlots
                self.isLoading = false
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    func createRegistration(driverId: Int, vehicleId: Int, timeSlotId: Int, expectedCheckInTime: String) async throws -> Int {
        return try await databaseManager.createRegistration(
            driverId: driverId,
            vehicleId: vehicleId,
            timeSlotId: timeSlotId,
            expectedCheckInTime: expectedCheckInTime
        )
    }
} 
