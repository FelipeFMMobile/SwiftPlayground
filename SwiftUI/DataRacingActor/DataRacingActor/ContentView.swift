//
//  ContentView.swift
//  DataRacingActor
//
//  Created by Felipe Menezes on 18/04/24.
//

import SwiftUI


// first, lets check in our Scheme the flag Thread Sanitizer, and watch for logs

import Foundation

// first solution @MainActor
// third solution is using actor
actor ViewModel: ObservableObject {
    // old solition
    var lastThreadName: String = "none"
    
    //var queue = DispatchQueue(label: "myQueue", qos: .background)

    func loadValues() async throws {
         Task(priority: .background) {
             do {
                 try await Task.sleep(nanoseconds: 1 * 1_000_000_000)
                 // surrond with DispatchQueue.main.async both is one solution
                 // or event create a function that update. Importatn here is
                 self.updateName("firstLoad")
                 
             } catch {
                 
             }
         }
    }

    func loadValues2() async throws {
         Task(priority: .background) {
             do {
                 try await Task.sleep(nanoseconds: 1 * 1_000_000_000)
                 // or eve
                 self.updateName("secondLoad")
                 // Data race in DataRacingActor.ViewModel.lastThreadName.setter :
             } catch {
                 
             }
         }
    }

    // 2 solution is to put everything at same queue.
    private func updateName(_ name: String) {
        print("updated \(name)")
        self.lastThreadName = name
        //queue.async {
            
        //}
    }
}


struct ContentView: View {
    @StateObject var viewModel = ViewModel()
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        .task {
            do {
                try await viewModel.loadValues()
                try await viewModel.loadValues2()
            } catch {
                
            }
        }
    }
}

#Preview {
    ContentView()
}
