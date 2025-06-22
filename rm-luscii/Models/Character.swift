import Foundation

struct Character: Codable, Identifiable, Equatable {
    let id: Int
    let name: String
    let status: String
    let species: String
    let origin: Origin
    let image: String
    let episode: [String] // URLs to episodes
}

struct Origin: Codable, Equatable {
    let name: String
    let url: String
} 