//
//  truckqueuing_system1_2App.swift
//  truckqueuing system1.2
//
//  Created by Di Zheng on 2024/11/22.
//

import SwiftUI

@main
struct truckqueuing_system1_2App: App {
    @StateObject private var viewModel = QueueViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
