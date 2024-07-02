//
//  NetworkRequester.swift
//  SolidAtScale
//
//  Created by Felipe Menezes on 05/06/24.
//

import Foundation

// Let's apply SOLID solutions for large scale apps.

// Sometimes, we create a simple web requester

struct JsonModel: Codable {
}

struct JsonModel2: Codable {
}

// 1 - A simple requester class without SOLID concerns
class NetworkRequester {
    func fetchFromURL() async throws -> JsonModel {
        let domain = "https://www.google.com"
        let path = "/files"
        guard let url = URL(string: domain + path) else { throw NSError() }
        let data = try await URLSession.shared.data(from: url).0
        return try JSONDecoder().decode(JsonModel.self, from: data)
   }
}
// SRP - Notice how many responsibilities the class has. Can it scale? Other domains? Other paths, responses?

// Solution: Let's remove parameters from it in step 2, but it won't be enough. OCP will help us break it into pieces ...
// Notice: Nested classes are to keep it simple to understand
class NetworkRequesterSolid_1 {
    var params: Params

    struct Params {
        var domain: String
        var path: String
    }

    init(_ params: Params) {
        self.params = params
    }

    func fetchFromURL() async throws -> JsonModel {
        guard let url = URL(string: params.domain + params.path) else { throw NSError() }
        let data = try await URLSession.shared.data(from: url).0
        return try JSONDecoder().decode(JsonModel.self, from: data)
   }
}

// 2 OCP (Open/Closed Principle)
// Look at the class, still coupled. How to make it have only one reason to change?
// First, analyze the change factors at scale:
// > JsonModel could be different
// > Params could change
// > Response handling code could also be different

// Solution: Let's start fix the response processor, in step 2.
class NetworkRequesterSolid_2 {
    var params: Params

    struct Params {
        var domain: String
        var path: String
    }

    struct ResponseJSONAdapter {
        func process<T: Decodable>(_ data: Data, type: T.Type) async throws -> T {
            return try JSONDecoder().decode(type.self, from: data)
        }
    }

    init(_ params: Params) {
        self.params = params
    }

    func fetchFromURL() async throws -> some Decodable {
        guard let url = URL(string: params.domain + params.path) else { throw NSError() }
        let data = try await URLSession.shared.data(from: url).0
        return try await ResponseJSONAdapter().process(data, type: JsonModel.self)
   }
}

// 3 - But there's still something wrong with this OCP approach. 
// Notice that ResponseJSONAdapter is tightly coupled to the function.
// Additionally, it doesn't allow extending the behavior. What if we want a different responseAdapter?
// At scale, this should be considered.

// Solution: Let's use protocols to provide full extension possibilities.
class NetworkRequesterSolid_3 {
    var params: Params
    var response: ResponseAdapterProtocol

    struct Params {
        var domain: String
        var path: String
    }
    
    protocol ResponseAdapterProtocol {
        func process<T: Decodable>(_ data: Data, type: T.Type) async throws -> T
    }

    struct ResponseJSONAdapter: ResponseAdapterProtocol {
        func process<T: Decodable>(_ data: Data, type: T.Type) async throws -> T {
            return try JSONDecoder().decode(type.self, from: data)
        }
    }

    init(_ params: Params, _ response: ResponseAdapterProtocol) {
        self.params = params
        self.response = response
    }

    func fetchFromURL() async throws -> some Decodable {
        guard let url = URL(string: params.domain + params.path) else { throw NSError() }
        let data = try await URLSession.shared.data(from: url).0
        return try await self.response.process(data, type: JsonModel.self)
   }
}
// Great! Now using OCP, any class that conforms to ResponseAdapterProtocol can be injected into our requester.

// 4 - ISP (Interface Segregation Principle)
// But what if we want to add another function to our ResponseAdapterProtocol?
// In many large-scale projects, changes that include a new function (or variable) in the protocol conformance
// could break a lot of implementations that inherit from it.

// Solution: Create a new protocol that extends ResponseAdapterProtocol and doesn't force rewriting all the code.
class NetworkRequesterSolid_4 {
    var params: Params
    var response: ResponseAdapterProtocol

    struct Params {
        var domain: String
        var path: String
    }
    
    protocol ResponseAdapterProtocol {
        func process<T: Decodable>(_ data: Data, type: T.Type) async throws -> T
    }

    protocol ResponseRawAdapterProtocol {
        var rawString: String { get set }
    }

    struct ResponseJSONAdapter: ResponseAdapterProtocol {
        func process<T: Decodable>(_ data: Data, type: T.Type) async throws -> T {
            return try JSONDecoder().decode(type.self, from: data)
        }
    }

    // This modified adapter uses a wrapper to conform to and fulfill the new interface requirements.
    // In large-scale projects, none of the existing classes that already conform to ResponseAdapterProtocol
    // need to be changed, only the new ones.
    // Remember, nested classes are used here only for example purposes.
    class ResponseRawAdapter: ResponseRawAdapterProtocol, ResponseAdapterProtocol {
        let responseAdapter = ResponseJSONAdapter()
        var rawString: String = ""
        
        func process<T>(_ data: Data, type: T.Type) async throws -> T where T : Decodable {
            let result = try await responseAdapter.process(data, type: type)
            guard let raw = String(data: data, encoding: .utf8) else { throw NSError() }
            rawString = raw
            return result
        }
    }

    init(_ params: Params, _ response: ResponseAdapterProtocol) {
        self.params = params
        self.response = response
    }

    public func fetchFromURL() async throws -> some Decodable {
        guard let url = URL(string: params.domain + params.path) else { throw NSError() }
        let data = try await URLSession.shared.data(from: url).0
        return try await self.response.process(data, type: JsonModel.self)
   }
}

// 5 - LSP (Liskov Substitution Principle)
// Did you notice that our fetchFromURL is still fixed to only one model, right?
// Let's use an example of Liskov Substitution Principle to change it a little bit.

// Solution: To show breaking the LSP, we will inherit from NetworkRequesterSolid_4 and provide a new fetch method.
protocol NetworkRequesterSolidProtocol {
    func fetchFromURL<T: Decodable>(_ type: T.Type) async throws -> T
}

class NetworkRequesterSolid_5: NetworkRequesterSolid_4 {
    #warning("This breaks Liskov, child change behaviour of parent")
    public func fetchFromURL() async throws -> some Decodable {
        guard let url = URL(string: params.domain + params.path) else { throw NSError() }
        let data = try await URLSession.shared.data(from: url).0
        return try await self.response.process(data, type: JsonModel2.self)
   }
}

extension NetworkRequesterSolid_5: NetworkRequesterSolidProtocol {
    // Instead, let's create a protocol that uses generalization to handle both classes with one signature.
    // At this point, NetworkRequesterSolid_4 could use NetworkRequesterSolidProtocol and, if preferred,
    // be fixed to JsonModel there.
    func fetchFromURL<T: Decodable>(_ type: T.Type) async throws -> T
    {
        guard let url = URL(string: params.domain + params.path) else { throw NSError() }
        let data = try await URLSession.shared.data(from: url).0
        return try await self.response.process(data, type: type)
    }
}

// Next, check our ViewModel, Depedency Inversion - DSP will be explained there!
