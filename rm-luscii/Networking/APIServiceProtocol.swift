import Foundation

// MARK: - APIServiceProtocol

protocol APIServiceProtocol {
    func fetchEpisodes(page: Int) async throws -> EpisodeResponse
    func fetchCharacters(ids: [Int]) async throws -> [Character]
}
