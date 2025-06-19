import Foundation

struct Episode: Codable, Identifiable, Equatable {
    let id: Int
    let name: String
    let air_date: String
    let episode: String
    let characters: [String] // URLs to character endpoints
}

struct EpisodeResponse: Codable {
    let info: PageInfo
    let results: [Episode]
}

struct PageInfo: Codable {
    let count: Int
    let pages: Int
    let next: String?
    let prev: String?
} 