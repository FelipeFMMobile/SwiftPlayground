//
//  ContentView.swift
//  MainActor
//
//  Created by Felipe Menezes on 16/04/24.
//

import SwiftUI

// We have a viewModel thats control UI updates
class ViewModel: ObservableObject {
    @Published var isLoaded: Bool = false
    // creates a function that wait 3 seconds and and turn to true
    // @MainActor - if we put this annotation here, all code will run on mainthread!
    func loadValues() async throws {
         Task(priority: .background) {
             do {
                 print("\(Thread.isMainThread)") // besides the warning, this correctly shows that we are on background thread
                 try await Task.sleep(nanoseconds: 3 * 1_000_000_000)
                 await MainActor.run {
                     // without update the value on main thread, xcode will trigger a error indicating that cannot be peformed.
                     print("mainActor: \(Thread.isMainThread)")
                     isLoaded = true
                 }
             } catch {
                 
             }
         }
    }
}

// SwiftUI garatee that UI is always update on Mainthread.
struct LoadView: View {
    @StateObject var viewModel = ViewModel()
    var body: some View {
        VStack(alignment: .trailing) {
            Text("View isLoaded ?")
            Text("\(viewModel.isLoaded)").bold()
            Button {
                print("Clicked me!")
            } label: {
                Text("Clique to print")
            }

        }.padding(4.0)
            .task {
                do {
                    try await viewModel.loadValues()
                } catch {
                    
                }
            }
    }
}

#Preview {
    LoadView()
}
