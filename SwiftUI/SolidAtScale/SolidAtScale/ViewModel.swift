//
//  ViewModel.swift
//  SolidAtScale
//
//  Created by Felipe Menezes on 05/06/24.
//

import Foundation


// Here is a simple example of the Dependency Inversion Principle (DIP).
// At initialization, our ViewModel is high-level, and the network is low-level.
// They are dependent and tightly coupled if we user network property!
// The solution is easy: use protocols. Check the networkLSP property now!
class ViewModel: ObservableObject {
    let params = NetworkRequesterSolid_5.Params(domain: "www.google.com", path: "/find")
    let response = NetworkRequesterSolid_5.ResponseJSONAdapter()
    var network: NetworkRequesterSolid_5
    var networkLSP: NetworkRequesterSolidProtocol

    init(_ network: NetworkRequesterSolidProtocol) {
        // this breaks the LSP
        self.network = NetworkRequesterSolid_5(params, response)
        // this solve it
        self.networkLSP = network
    }
}
