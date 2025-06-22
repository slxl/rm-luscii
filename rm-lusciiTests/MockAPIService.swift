import Foundation
@testable import rm_luscii

class MockAPIService: APIServiceProtocol {
    var mockEpisodeResponse: EpisodeResponse?
    var mockCharacters: [Character]?
    var mockError: Error?
    var fetchEpisodesCallCount = 0
    var fetchCharactersCallCount = 0
    var capturedCharacterIDs: [Int] = []
    
    func fetchEpisodes(page: Int) async throws -> EpisodeResponse {
        fetchEpisodesCallCount += 1
        
        if let error = mockError {
            throw error
        }
        
        return mockEpisodeResponse ?? EpisodeResponse(
            info: PageInfo(count: 0, pages: 0, next: nil, prev: nil),
            results: []
        )
    }
    
    func fetchCharacters(ids: [Int]) async throws -> [Character] {
        fetchCharactersCallCount += 1
        capturedCharacterIDs = ids
        
        if let error = mockError {
            throw error
        }
        
        return mockCharacters ?? []
    }
    
    // MARK: - Reset Methods
    
    func reset() {
        mockEpisodeResponse = nil
        mockCharacters = nil
        mockError = nil
        fetchEpisodesCallCount = 0
        fetchCharactersCallCount = 0
        capturedCharacterIDs = []
    }
} 