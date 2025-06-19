import Foundation

protocol APIServiceProtocol {
    func fetchEpisodes(page: Int) async throws -> EpisodeResponse
    func fetchCharacter(id: Int) async throws -> Character
    func fetchCharacters(ids: [Int]) async throws -> [Character]
}

class APIService: APIServiceProtocol {
    private let baseURL = "https://rickandmortyapi.com/api"
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func fetchEpisodes(page: Int = 1) async throws -> EpisodeResponse {
        let url = URL(string: "\(baseURL)/episode?page=\(page)")!
        let (data, _) = try await session.data(from: url)
        return try JSONDecoder().decode(EpisodeResponse.self, from: data)
    }
    
    func fetchCharacter(id: Int) async throws -> Character {
        let url = URL(string: "\(baseURL)/character/\(id)")!
        let (data, _) = try await session.data(from: url)
        return try JSONDecoder().decode(Character.self, from: data)
    }
    
    func fetchCharacters(ids: [Int]) async throws -> [Character] {
        let idsString = ids.map { String($0) }.joined(separator: ",")
        let url = URL(string: "\(baseURL)/character/\(idsString)")!
        let (data, _) = try await session.data(from: url)
        if ids.count == 1 {
            let character = try JSONDecoder().decode(Character.self, from: data)
            return [character]
        } else {
            return try JSONDecoder().decode([Character].self, from: data)
        }
    }
}

class MockAPIService: APIServiceProtocol {
    func fetchEpisodes(page: Int) async throws -> EpisodeResponse {
        let episodes = [
            Episode(id: 1, name: "Pilot", air_date: "02/12/2013", episode: "S01E01", characters: []),
            Episode(id: 2, name: "Lawnmower Dog", air_date: "09/12/2013", episode: "S01E02", characters: [])
        ]
        let info = PageInfo(count: 2, pages: 1, next: nil, prev: nil)
        return EpisodeResponse(info: info, results: episodes)
    }
    func fetchCharacter(id: Int) async throws -> Character {
        return Character(id: id, name: "Rick Sanchez", status: "Alive", species: "Human", origin: Origin(name: "Earth", url: ""), image: "", episode: [])
    }
    func fetchCharacters(ids: [Int]) async throws -> [Character] {
        return ids.map { Character(id: $0, name: "Character \($0)", status: "Alive", species: "Human", origin: Origin(name: "Earth", url: ""), image: "", episode: []) }
    }
} 