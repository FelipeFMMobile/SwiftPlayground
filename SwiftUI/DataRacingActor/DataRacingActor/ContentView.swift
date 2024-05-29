//
//  ContentView.swift
//  DataRacingActor
//
//  Created by Felipe Menezes on 18/04/24.
//

import SwiftUI


// 1 - first, lets check in our Scheme the flag Thread Sanitizer, and watch for logs

import Foundation

// first solution single queue
// second solution @MainActor
// third solution is using actor ViewModel
// forth solution globalActor
//@DataActor
class ViewModel: ObservableObject {
    var lastThreadName: String = "none"
    
    // var queue = DispatchQueue(label: "myQueue", qos: .background)

    //nonisolated init() { }

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
             } catch {
                 
             }
         }
    }

    // 2 solution is to put everything at same queue.
    private func updateName(_ name: String) {
        print("updated \(name)")
        // Data race will show here
        self.lastThreadName = name
        printThread()
        // 1 - first solution
//        queue.async {
//           
//        }
    }

    private func printThread() {
        print("thread: \(Thread.current)")
        print("isMain: \(Thread.current.isMainThread)")
        print("----")
    }
}

// 4 - forth solution: global action annotaion
//@globalActor
//actor DataActor {
//    static let shared = DataActor()
//}

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
                for _ in 0...10 {
                    try await viewModel.loadValues()
                    try await viewModel.loadValues2()
                }
            } catch {
                
            }
        }
    }
}

#Preview {
    ContentView()
}
