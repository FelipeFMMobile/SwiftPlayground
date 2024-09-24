//: A UIKit based Playground for presenting user interface
  
import SwiftUI
import PlaygroundSupport

class ViewModel: ObservableObject {
    @Published var inputText = ""
    init() {
        print("Init a ViewModel")
    }
}

struct ContentView: View {
    @StateObject var viewModel: ViewModel // SSOT
    var model: Model
    init(_ model: Model) {
        // the view bind its parameter and change it because it passed on init
        self.model = model
        let viewModel = ViewModel() // viewModel defined here, will also be re-init
        _viewModel = StateObject(wrappedValue: viewModel)
        print("ContentView init")
    }
    var body: some View {
        VStack(alignment: .leading) {
            Section {
                VStack {
                    Text("Just a simple view \(model.type)")
                        .font(.title)
                }
            }
        }.padding(40.0)
    }
}

struct Model {
    var type = "ui"
}

struct MainView: View {
    @State var changeViewState : Bool = false
    var body: some View {
        VStack(alignment: .leading) {
            Section {
                VStack {
                    // the ContentView simulate a View that receive a parameter
                    // every change of changeViewState re-init the view
                    ContentView(changeViewState ?
                                Model(type: "ui") : Model(type: ""))
                    Button("Go") {
                        changeViewState.toggle()
                        print("---- toggle ----")
                    }
                }
            }
        }.padding(4.0)
    }
}


// Present the view controller in the Live View window
PlaygroundPage.current.setLiveView(
    MainView().frame(width: 320,height: 640)
)
