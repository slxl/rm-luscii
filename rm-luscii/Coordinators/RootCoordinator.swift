import SwiftUI
import UIKit

internal class RootCoordinator: Coordinator {
    enum Route {}

    var rootViewController: UIViewController {
        rootNavigationController
    }

    var routeHandler: ((Route) -> Void)?
    private var childCoordinators: [any Coordinator] = []
    
    // MARK: - Dependencies
    private let apiService: APIServiceProtocol
    private let pdfExportService: PDFExportServiceProtocol

    private lazy var rootNavigationController: UINavigationController = .init()

    init(
        apiService: APIServiceProtocol = APIService(),
        pdfExportService: PDFExportServiceProtocol = PDFExportService()
    ) {
        self.apiService = apiService
        self.pdfExportService = pdfExportService
    }

    @MainActor
    func start() {
        let episodeListViewController = buildEpisodeListViewController()
        rootNavigationController.pushViewController(episodeListViewController, animated: false)
    }

    // MARK: - Builders

    @MainActor
    func buildEpisodeListViewController() -> UIViewController {
        let episodeListViewModel = EpisodeListViewModel(apiService: apiService)
        episodeListViewModel.routeHandler = { [weak self] route in
            self?.handleEpisodeListRoute(route)
        }
        let episodeListView = EpisodeListView(viewModel: episodeListViewModel)
        let hostingController = UIHostingController(rootView: episodeListView)
        
        // Set the navigation title
        hostingController.title = "Episodes"
        hostingController.navigationItem.title = "Episodes"
        
        return hostingController
    }

    @MainActor
    func buildEpisodeDetailViewController(episode: Episode) -> UIViewController {
        let episodeDetailViewModel = EpisodeDetailViewModel(episode: episode, apiService: apiService)
        episodeDetailViewModel.routeHandler = { [weak self] route in
            self?.handleEpisodeDetailRoute(route)
        }
        let episodeDetailView = EpisodeDetailView(viewModel: episodeDetailViewModel)
        let hostingController = UIHostingController(rootView: episodeDetailView)
        
        // Set the navigation title
        hostingController.title = episodeDetailViewModel.episodeTitle
        hostingController.navigationItem.title = episodeDetailViewModel.episodeTitle
        
        return hostingController
    }

    @MainActor func buildCharacterDetailViewController(character: Character) -> UIViewController {
        let characterDetailViewModel = CharacterDetailViewModel(
            character: character,
            pdfExportService: pdfExportService
        )
        let characterDetailView = CharacterDetailView(viewModel: characterDetailViewModel)
        let hostingController = UIHostingController(rootView: characterDetailView)
        
        // Set the navigation title
        hostingController.title = character.name
        hostingController.navigationItem.title = character.name
        
        return hostingController
    }

    // MARK: - Route handlers

    @MainActor
    func handleEpisodeListRoute(_ route: EpisodeListViewModel.Route) {
        switch route {
        case let .showEpisodeDetail(episode):
            let episodeDetailViewController = buildEpisodeDetailViewController(episode: episode)
            rootNavigationController.pushViewController(episodeDetailViewController, animated: true)
        }
    }

    @MainActor
    func handleEpisodeDetailRoute(_ route: EpisodeDetailViewModel.Route) {
        switch route {
        case let .showCharacterDetail(character):
            let characterDetailViewController = buildCharacterDetailViewController(character: character)
            rootNavigationController.pushViewController(characterDetailViewController, animated: true)
        }
    }
} 
