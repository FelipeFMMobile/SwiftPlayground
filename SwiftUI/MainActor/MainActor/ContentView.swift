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
    @Published var myImage: UIImage = UIImage()
    let appleLogoURL = URL(string: "https://1000logos.net/wp-content/uploads/2016/10/Apple-Logo.png")!
    // creates a function that wait 3 seconds and and turn to true
    // @MainActor - if we put this annotation here, all code will run on mainthread!
    func loadValues() async throws {
         // 1 - we are starting a task that choose a background thread to run it
         Task(priority: .background) {
             do {
                 // this correctly shows that we are on background (not main) thread
                 printThread()
                 try await Task.sleep(nanoseconds: 2 * 1_000_000_000)
                 // 2 - let it run and change the published var, will trigger a main thread warning on XCode "Publishing changes from background thread ..."
                 printThread()
                 isLoaded = true
                 
//                 await MainActor.run {
//                     // without update the value on main thread, xcode will trigger a error indicating that cannot be peformed.
//                     print("is mainActor: \(Thread.isMainThread)")
//                     isLoaded = true
//                 }
             } catch {
                 
             }
         }
    }

    @MainActor
    func fetchImage() async {
        let data = try? await URLSession.shared.data(from: appleLogoURL).0
        guard let data, let image = UIImage(data: data) else {
            return
        }
        self.myImage = image
        printThread()
    }

    func printThread() {
        print("thread: \(Thread.current)")
        print("isMain: \(Thread.current.isMainThread)")
        print("----")
    }
}

// SwiftUI garatee that UI is always update on Mainthread.
struct LoadView: View {
    @StateObject var viewModel = ViewModel()
    var body: some View {
        VStack(alignment: .trailing) {
            Text("View isLoaded ?")
            Text("\(viewModel.isLoaded)").bold()
            Image(uiImage: viewModel.myImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width:100, height:100)
            Button {
                print("Clicked me!")
            } label: {
                Text("Clique to print")
            }

        }.padding(4.0)
        .task {
//            do {
//                try await viewModel.loadValues()
//            } catch {
//                
//            }
        }.onAppear {
            Task {
                await self.viewModel.fetchImage()
            }
            
        }
    }
}

#Preview {
    LoadView()
}
