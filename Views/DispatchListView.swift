import SwiftUI

struct DispatchListView: View {
    @ObservedObject var viewModel: QueueViewModel
    @State private var selectedRegistration: Registration?
    @State private var showingDispatchSheet = false
    
    // 获取未发车且未过号的车辆
    var availableRegistrations: [Registration] {
        viewModel.registrations.filter { 
            !$0.isDispatched && $0.status != .skipped 
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(Array(availableRegistrations.enumerated()), id: \.element.id) { index, registration in
                    DispatchRow(
                        registration: registration,
                        viewModel: viewModel,
                        canDispatch: index < 3,
                        index: index
                    )
                    .onTapGesture {
                        if index < 3 {
                            selectedRegistration = registration
                            showingDispatchSheet = true
                        }
                    }
                }
            }
            .navigationTitle("发车列表")
            .refreshable {
                viewModel.loadData()
            }
            .sheet(isPresented: $showingDispatchSheet) {
                if let registration = selectedRegistration {
                    DispatchConfirmationView(viewModel: viewModel, registration: registration)
                }
            }
            .alert("发车成功", isPresented: $viewModel.showingSuccessAlert) {
                Button("确定", role: .cancel) { }
            } message: {
                Text("祝您一路平安")
            }
        }
    }
}

// 添加 DispatchRow 视图
struct DispatchRow: View {
    let registration: Registration
    @ObservedObject var viewModel: QueueViewModel
    let canDispatch: Bool
    let index: Int
    @State private var showingDispatchSheet = false
    @State private var showingSkipAlert = false
    @State private var password = ""
    @State private var showingPasswordError = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    if let driver = registration.driver {
                        Text(driver.name)
                            .font(.headline)
                        Text(driver.phoneNumber)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    if let vehicle = registration.vehicle {
                        Text(vehicle.plateNumber)
                            .font(.subheadline)
                    }
                }
                
                Spacer()
                
                VStack(spacing: 8) {
                    // 发车按钮
                    if registration.checkInTime != nil {
                        if canDispatch {
                            Button("发车") {
                                showingDispatchSheet = true
                            }
                            .buttonStyle(.borderedProminent)
                        } else {
                            Text("等待中")
                                .foregroundColor(.gray)
                        }
                    } else {
                        Text("未签到")
                            .foregroundColor(.orange)
                    }
                    
                    // 过号按钮
                    Button("过号") {
                        showingSkipAlert = true
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.red)
                }
            }
            
            HStack {
                if let checkInTime = registration.checkInTime {
                    Text("签到时间: \(checkInTime.formatted(date: .omitted, time: .shortened))")
                        .font(.caption)
                }
                
                Spacer()
                
                // 序号移到这里
                Text("#\(index + 1)")
                    .font(.caption)
                    .foregroundColor(index < 3 ? .blue : .gray)
            }
            
            if let driver = registration.driver, driver.isContinuousDriver {
                Text("连跑司机")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 4)
        .sheet(isPresented: $showingDispatchSheet) {
            DispatchSheetView(registration: registration, viewModel: viewModel)
        }
        // 过号密码验证弹窗
        .alert("请输入密码", isPresented: $showingSkipAlert) {
            SecureField("密码", text: $password)
            Button("确认") {
                if password == "jian.pan" {
                    viewModel.skipRegistration(registration)
                } else {
                    showingPasswordError = true
                }
                password = ""
            }
            Button("取消", role: .cancel) {
                password = ""
            }
        }
        // 密码错误提示
        .alert("密码错误", isPresented: $showingPasswordError) {
            Button("确定", role: .cancel) { }
        }
    }
}

struct DispatchSheetView: View {
    let registration: Registration
    @ObservedObject var viewModel: QueueViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var trailerNumber = ""
    @State private var selectedRoute: Route = .CA_PA
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("挂车信息")) {
                    TextField("挂车号", text: $trailerNumber)
                        .textInputAutocapitalization(.characters)
                }
                
                Section(header: Text("路线选择")) {
                    Picker("路线", selection: $selectedRoute) {
                        ForEach(Route.allCases, id: \.self) { route in
                            Text(route.rawValue).tag(route)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section {
                    Button("确认发车") {
                        viewModel.dispatchVehicle(
                            registration: registration,
                            trailerNumber: trailerNumber,
                            route: selectedRoute
                        )
                        dismiss()
                    }
                    .disabled(trailerNumber.isEmpty)
                }
            }
            .navigationTitle("发车信息")
            .navigationBarItems(trailing: Button("取消") {
                dismiss()
            })
        }
    }
}

#Preview {
    DispatchListView(viewModel: QueueViewModel())
} 
