import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = QueueViewModel()
    @StateObject private var networkMonitor = NetworkMonitor()
    
    var body: some View {
        NavigationView {
            Group {
                if !networkMonitor.isConnected {
                    NoNetworkView()
                } else if viewModel.isLoading {
                    ProgressView("加载中...")
                } else {
                    MainQueueView(viewModel: viewModel)
                }
            }
            .navigationTitle("卡车排队系统")
        }
        .task {
            await viewModel.loadData()
        }
        .alert("错误", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("确定") {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}

struct NoNetworkView: View {
    var body: some View {
        VStack {
            Image(systemName: "wifi.slash")
                .font(.system(size: 60))
                .foregroundColor(.red)
            Text("无网络连接")
                .font(.title)
                .padding()
            Text("请检查网络设置后重试")
                .foregroundColor(.gray)
        }
    }
}

struct MainQueueView: View {
    @ObservedObject var viewModel: QueueViewModel
    
    var body: some View {
        List {
            Section("时间段") {
                ForEach(viewModel.timeSlots, id: \.id) { timeSlot in
                    TimeSlotRow(timeSlot: timeSlot)
                }
            }
        }
        .refreshable {
            await viewModel.loadData()
        }
    }
}

struct TimeSlotRow: View {
    let timeSlot: DatabaseManager.TimeSlot
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("日期: \(timeSlot.date)")
            Text("时间: \(timeSlot.startTime) - \(timeSlot.endTime)")
            Text("容量: \(timeSlot.maxCapacity)")
        }
    }
} 