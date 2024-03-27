//: A UIKit based Playground for presenting user interface
  
import UIKit
import SwiftUI
import Combine
import PlaygroundSupport

// We create a viewModel, that add pets and emitt its change to view
class PetsViewModel: ObservableObject {
    var myPets: Int = 0
    var pets: [Pets] = []
    var newPet: String = ""

    func getTitle() -> String {
        "My pets"
    }
    
    func getPets() -> [Pets] {
        pets
    }

    func addPets() {
        myPets += 1
        pets.append(Pets(name: newPet, genre: .cat))
        objectWillChange.send()
        newPet = ""
    }
}

struct PetsView: View {
    // Here is where StateObject is relevant.
    // If we use ObservedObject instead, the PetsView
    // will be re-draw and also the PetsViewModel will be realloc
    @StateObject var viewModel = PetsViewModel() // SSOT
    init() {
        print("PetsView init")
    }
    var body: some View {
        VStack(alignment: .leading) {
            Section {
                ForEach(viewModel.getPets(), id: \.name) { pet in
                    Text(pet.name)
                }
            }
            Divider()
            Section {
                VStack {
                    TextField("Type your pet numer \(viewModel.myPets): ",
                              text: $viewModel.newPet)
                }
            }
            Divider()
            Section {
                Text("My pets \(viewModel.myPets)")
                Button("Add my pet counter") {
                    viewModel.addPets()
                }
            }
        }.padding(4.0)
    }
}

struct PetsCouterView: View {
    // The key point is, when myPets change the State of view
    // SwiftUI will redraw everything
    @State var observation = ""
    var body: some View {
        VStack {
            HStack(alignment: .top) {
                List {
                    Section {
                        Text("A view with StateObject")
                    }
                    Section {
                        PetsView()
                    }
                    TextField("Observation: ",
                              text: $observation)
                }
            }.padding(.bottom)
        }
    }
}

// Present the view controller in the Live View window
PlaygroundPage.current.setLiveView(PetsCouterView())
