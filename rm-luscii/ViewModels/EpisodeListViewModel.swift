import Combine
import Foundation

@MainActor
class EpisodeListViewModel: ObservableObject {
    @Published var episodes: [Episode] = []
    @Published var isLoading = false
    @Published var reachedEnd = false
    @Published var error: String?

    private var currentPage = 1
    private var totalPages = 1
    private var cancellables = Set<AnyCancellable>()
    private let apiService: APIServiceProtocol

    init(apiService: APIServiceProtocol = APIService()) {
        self.apiService = apiService
    }

    func loadEpisodes(reset: Bool = false) async {
        guard !isLoading else {
            return
        }

        if reset {
            currentPage = 1
            episodes = []
            reachedEnd = false
        }

        guard !reachedEnd else {
            return
        }

        isLoading = true
        error = nil

        do {
            let response = try await apiService.fetchEpisodes(page: currentPage)
            if reset {
                episodes = response.results
            } else {
                episodes += response.results
            }

            totalPages = response.info.pages

            if currentPage >= totalPages {
                reachedEnd = true
            } else {
                currentPage += 1
            }

        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }
}
