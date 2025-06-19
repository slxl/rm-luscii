import Foundation

struct Character: Codable, Identifiable {
    let id: Int
    let name: String
    let status: String
    let species: String
    let origin: Origin
    let image: String
    let episode: [String] // URLs to episodes
}

struct Origin: Codable {
    let name: String
    let url: String
} 