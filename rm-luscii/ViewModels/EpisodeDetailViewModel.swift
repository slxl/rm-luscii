import Foundation

@MainActor
class EpisodeDetailViewModel: ObservableObject, Routable {
    enum Route {
        case showCharacterDetail(Character)
    }

    @Published var characters: [Character] = []
    @Published var isLoading = false
    @Published var error: String?

    let episodeTitle: String

    private let apiService: APIServiceProtocol
    private let characterIDs: [Int]

    var routeHandler: ((Route) -> Void)?

    init(episode: Episode, apiService: APIServiceProtocol = APIService()) {
        self.episodeTitle = episode.name
        self.characterIDs = episode.characters.compactMap { URL(string: $0)?.lastPathComponent }.compactMap { Int($0) }
        self.apiService = apiService
    }

    /// Loads character details for all characters in the episode
    ///
    /// This function fetches character data for all character IDs associated with the episode
    /// using a single API call with an array of IDs for better performance.
    @MainActor
    func loadCharacters() async {
        guard !characterIDs.isEmpty else {
            return
        }

        isLoading = true
        error = nil

        do {
            let fetchedCharacters = try await apiService.fetchCharacters(ids: characterIDs)

            // Sort characters by their original order in the episode
            let characterDict = Dictionary(uniqueKeysWithValues: fetchedCharacters.map { ($0.id, $0) })
            self.characters = characterIDs.compactMap { characterDict[$0] }

        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    /// Handles character selection and triggers navigation
    func didSelectCharacter(_ character: Character) {
        route(.showCharacterDetail(character))
    }
}
