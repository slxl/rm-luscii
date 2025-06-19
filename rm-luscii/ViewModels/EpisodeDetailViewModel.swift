import Foundation

@MainActor
class EpisodeDetailViewModel: ObservableObject {
    @Published var characters: [Character] = []
    @Published var isLoading = false
    @Published var error: String?
    let episodeTitle: String
    
    private let apiService: APIServiceProtocol
    private let characterIDs: [Int]
    
    init(episode: Episode, apiService: APIServiceProtocol = APIService()) {
        self.episodeTitle = episode.name
        self.characterIDs = episode.characters.compactMap { URL(string: $0)?.lastPathComponent }.compactMap { Int($0) }
        self.apiService = apiService
    }
    
    func loadCharacters() async {
        guard !isLoading else { return }
        isLoading = true
        error = nil
        do {
            characters = try await apiService.fetchCharacters(ids: characterIDs)
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
} 