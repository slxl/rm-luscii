import Foundation

@MainActor
class CharacterDetailViewModel: ObservableObject {
    @Published var character: Character
    @Published var isLoading = false
    @Published var error: String?
    
    private let apiService: APIServiceProtocol
    
    init(character: Character, apiService: APIServiceProtocol = APIService()) {
        self.character = character
        self.apiService = apiService
    }
}
