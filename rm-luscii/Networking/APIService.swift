import Foundation

// MARK: - APIServiceProtocol

protocol APIServiceProtocol {
    func fetchEpisodes(page: Int) async throws -> EpisodeResponse
    func fetchCharacters(ids: [Int]) async throws -> [Character]
}

// MARK: - APIService

class APIService: APIServiceProtocol {
    private let baseURL = "https://rickandmortyapi.com/api"
    private let session: URLSession

    init(session: URLSession = .shared) {
        // Create a session configuration that disables caching
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil
        self.session = URLSession(configuration: config)
    }

    private func createCacheBustingRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")

        return request
    }

    func fetchEpisodes(page: Int = 1) async throws -> EpisodeResponse {
        guard let urlComponents = URLComponents(string: "\(baseURL)/episode") else {
            throw URLError(.badURL)
        }

        var components = urlComponents
        components.queryItems = [URLQueryItem(name: "page", value: "\(page)")]

        guard let url = components.url else {
            throw URLError(.badURL)
        }

        let request = createCacheBustingRequest(url: url)
        let (data, _) = try await session.data(for: request)

        return try JSONDecoder().decode(EpisodeResponse.self, from: data)
    }

    func fetchCharacters(ids: [Int]) async throws -> [Character] {
        let idsString = ids.map { String($0) }.joined(separator: ",")

        guard
            let urlComponents = URLComponents(string: "\(baseURL)/character/\(idsString)"),
            let url = urlComponents.url
        else {
            throw URLError(.badURL)
        }

        let (data, _) = try await session.data(from: url)

        if ids.count == 1 {
            let character = try JSONDecoder().decode(Character.self, from: data)
            return [character]
        } else {
            return try JSONDecoder().decode([Character].self, from: data)
        }
    }
}

// MARK: - MockAPIService

class MockAPIService: APIServiceProtocol {
    func fetchEpisodes(page: Int) async throws -> EpisodeResponse {
        let episodes = [
            Episode(id: 1, name: "Pilot", air_date: "02/12/2013", episode: "S01E01", characters: []),
            Episode(id: 2, name: "Lawnmower Dog", air_date: "09/12/2013", episode: "S01E02", characters: [])
        ]

        let info = PageInfo(count: 2, pages: 1, next: nil, prev: nil)

        return EpisodeResponse(info: info, results: episodes)
    }

    func fetchCharacters(ids: [Int]) async throws -> [Character] {
        ids
            .map {
                Character(
                    id: $0,
                    name: "Character \($0)",
                    status: "Alive",
                    species: "Human",
                    origin: Origin(
                        name: "Earth",
                        url: ""
                    ),
                    image: "",
                    episode: []
                )
            }
    }
}
