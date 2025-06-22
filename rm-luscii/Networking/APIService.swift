import Foundation

// MARK: - APIService

class APIService: APIServiceProtocol {
    private let session: URLSession

    private enum Constants {
        static let baseURL = "https://rickandmortyapi.com/api"
        static let episodeEndpoint = "/episode"
        static let characterEndpoint = "/character"
        static let pageQueryParameter = "page"
    }

    init(session: URLSession = .shared) {
        // Create a session configuration that disables caching
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil
        self.session = URLSession(configuration: config)
    }

    /// Creates a URLRequest with cache-busting headers to prevent caching issues
    /// - Parameter url: The URL to create the request for
    /// - Returns: A URLRequest configured to bypass cache
    private func createCacheBustingRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")

        return request
    }

    /// Fetches episodes from the Rick and Morty API with pagination support
    /// - Parameter page: The page number to fetch (defaults to 1)
    /// - Returns: An EpisodeResponse containing episodes and pagination info
    /// - Throws: URLError if the URL is invalid or network request fails
    func fetchEpisodes(page: Int = 1) async throws -> EpisodeResponse {
        guard let urlComponents = URLComponents(string: "\(Constants.baseURL)\(Constants.episodeEndpoint)") else {
            throw URLError(.badURL)
        }

        var components = urlComponents
        components.queryItems = [URLQueryItem(name: Constants.pageQueryParameter, value: "\(page)")]

        guard let url = components.url else {
            throw URLError(.badURL)
        }

        let request = createCacheBustingRequest(url: url)
        let (data, _) = try await session.data(for: request)

        return try JSONDecoder().decode(EpisodeResponse.self, from: data)
    }

    /// Fetches characters from the Rick and Morty API by their IDs
    /// - Parameter ids: Array of character IDs to fetch
    /// - Returns: Array of Character objects
    /// - Throws: URLError if the URL is invalid or network request fails
    func fetchCharacters(ids: [Int]) async throws -> [Character] {
        let idsString = ids.map { String($0) }.joined(separator: ",")

        guard
            let urlComponents = URLComponents(string: "\(Constants.baseURL)\(Constants.characterEndpoint)/\(idsString)"),
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
