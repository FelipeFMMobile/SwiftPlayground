import Foundation

public enum PetsSpecies {
    case bird, lizard, dog, cat
}

public struct Pets {
    public init(name: String, genre: PetsSpecies) {
        self.name = name
        self.genre = genre
    }
    
    public var name: String
    public var genre: PetsSpecies
}
