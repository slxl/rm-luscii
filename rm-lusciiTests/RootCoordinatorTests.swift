@testable import rm_luscii
import SwiftUI
import XCTest

@MainActor
final class RootCoordinatorTests: XCTestCase {
    var coordinator: RootCoordinator!
    var mockAPIService: MockAPIService!
    var mockPDFExportService: MockPDFExportService!

    override func setUp() {
        super.setUp()
        mockAPIService = MockAPIService()
        mockPDFExportService = MockPDFExportService()
        coordinator = RootCoordinator(
            apiService: mockAPIService,
            pdfExportService: mockPDFExportService
        )
    }

    override func tearDown() {
        coordinator = nil
        mockAPIService = nil
        mockPDFExportService = nil
        super.tearDown()
    }

    // MARK: - Initial State Tests

    func testInitialState() {
        XCTAssertNil(coordinator.routeHandler)
        XCTAssertNotNil(coordinator.rootViewController)
        XCTAssertTrue(coordinator.rootViewController is UINavigationController)
    }

    func testDependencyInjection() {
        // The coordinator should use the injected dependencies
        XCTAssertNotNil(coordinator.rootViewController)
    }

    // MARK: - Start Method Tests

    func testStartPushesEpisodeListViewController() {
        // Given
        let navigationController = coordinator.rootViewController as! UINavigationController

        // When
        coordinator.start()

        // Then
        XCTAssertEqual(navigationController.viewControllers.count, 1)
        XCTAssertTrue(navigationController.viewControllers.first is UIHostingController<EpisodeListView>)
    }

    func testStartSetsNavigationTitle() {
        // Given
        let navigationController = coordinator.rootViewController as! UINavigationController

        // When
        coordinator.start()

        // Then
        let hostingController = navigationController.viewControllers.first as! UIHostingController<EpisodeListView>
        XCTAssertEqual(hostingController.title, "Episodes")
        XCTAssertEqual(hostingController.navigationItem.title, "Episodes")
    }

    // MARK: - Builder Method Tests

    func testBuildEpisodeListViewController() {
        // When
        let viewController = coordinator.buildEpisodeListViewController()

        // Then
        XCTAssertTrue(viewController is UIHostingController<EpisodeListView>)
        XCTAssertEqual(viewController.title, "Episodes")
    }

    func testBuildEpisodeDetailViewController() {
        // Given
        let episode = Episode(
            id: 1,
            name: "Test Episode",
            air_date: "2023-01-01",
            episode: "S01E01",
            characters: []
        )

        // When
        let viewController = coordinator.buildEpisodeDetailViewController(episode: episode)

        // Then
        XCTAssertTrue(viewController is UIHostingController<EpisodeDetailView>)
        XCTAssertEqual(viewController.title, "Test Episode")
    }

    func testBuildCharacterDetailViewController() {
        // Given
        let character = Character(
            id: 1,
            name: "Rick",
            status: "Alive",
            species: "Human",
            origin: Origin(name: "Earth", url: ""),
            image: "",
            episode: []
        )

        // When
        let viewController = coordinator.buildCharacterDetailViewController(character: character)

        // Then
        XCTAssertTrue(viewController is UIHostingController<CharacterDetailView>)
        XCTAssertEqual(viewController.title, "Rick")
    }

    // MARK: - Route Handler Tests

    func testHandleEpisodeListRoute() {
        // Given
        let navigationController = coordinator.rootViewController as! UINavigationController
        coordinator.start() // Start with episode list

        let episode = Episode(
            id: 1,
            name: "Test Episode",
            air_date: "2023-01-01",
            episode: "S01E01",
            characters: []
        )

        // When
        coordinator.handleEpisodeListRoute(.showEpisodeDetail(episode))

        // Then
        XCTAssertEqual(navigationController.viewControllers.count, 2)
        XCTAssertTrue(navigationController.viewControllers.last is UIHostingController<EpisodeDetailView>)
    }

    func testHandleEpisodeDetailRoute() {
        // Given
        let navigationController = coordinator.rootViewController as! UINavigationController
        coordinator.start() // Start with episode list

        let episode = Episode(
            id: 1,
            name: "Test Episode",
            air_date: "2023-01-01",
            episode: "S01E01",
            characters: []
        )

        // Navigate to episode detail first
        coordinator.handleEpisodeListRoute(.showEpisodeDetail(episode))

        let character = Character(
            id: 1,
            name: "Rick",
            status: "Alive",
            species: "Human",
            origin: Origin(name: "Earth", url: ""),
            image: "",
            episode: []
        )

        // When
        coordinator.handleEpisodeDetailRoute(.showCharacterDetail(character))

        // Then
        XCTAssertEqual(navigationController.viewControllers.count, 3)
        XCTAssertTrue(navigationController.viewControllers.last is UIHostingController<CharacterDetailView>)
    }

    // MARK: - ViewModel Integration Tests

    func testEpisodeListViewModelRouteHandler() {
        // Given
        let viewController = coordinator.buildEpisodeListViewController()
        let hostingController = viewController as! UIHostingController<EpisodeListView>
        let episodeListView = hostingController.rootView
        let viewModel = episodeListView.viewModel

        let episode = Episode(
            id: 1,
            name: "Test Episode",
            air_date: "2023-01-01",
            episode: "S01E01",
            characters: []
        )

        var capturedRoute: EpisodeListViewModel.Route?
        viewModel.routeHandler = { route in
            capturedRoute = route
        }

        // When
        viewModel.didSelectEpisode(episode)

        // Then
        XCTAssertEqual(capturedRoute, .showEpisodeDetail(episode))
    }

    func testEpisodeDetailViewModelRouteHandler() {
        // Given
        let episode = Episode(
            id: 1,
            name: "Test Episode",
            air_date: "2023-01-01",
            episode: "S01E01",
            characters: []
        )

        let viewController = coordinator.buildEpisodeDetailViewController(episode: episode)
        let hostingController = viewController as! UIHostingController<EpisodeDetailView>
        let episodeDetailView = hostingController.rootView
        let viewModel = episodeDetailView.viewModel

        let character = Character(
            id: 1,
            name: "Rick",
            status: "Alive",
            species: "Human",
            origin: Origin(name: "Earth", url: ""),
            image: "",
            episode: []
        )

        var capturedRoute: EpisodeDetailViewModel.Route?
        viewModel.routeHandler = { route in
            capturedRoute = route
        }

        // When
        viewModel.didSelectCharacter(character)

        // Then
        XCTAssertEqual(capturedRoute, .showCharacterDetail(character))
    }

    // MARK: - Navigation Stack Tests

    func testNavigationStackBehavior() {
        // Given
        let navigationController = coordinator.rootViewController as! UINavigationController
        coordinator.start()

        // When - Navigate to episode detail
        let episode = Episode(id: 1, name: "Test", air_date: "2023-01-01", episode: "S01E01", characters: [])
        coordinator.handleEpisodeListRoute(.showEpisodeDetail(episode))

        // Then - Should have 2 view controllers
        XCTAssertEqual(navigationController.viewControllers.count, 2)

        // When - Navigate to character detail
        let character = Character(id: 1, name: "Rick", status: "Alive", species: "Human", origin: Origin(name: "Earth", url: ""), image: "", episode: [])
        coordinator.handleEpisodeDetailRoute(.showCharacterDetail(character))

        // Then - Should have 3 view controllers
        XCTAssertEqual(navigationController.viewControllers.count, 3)

        // When - Pop back
        navigationController.popViewController(animated: false)

        // Then - Should have 2 view controllers again
        XCTAssertEqual(navigationController.viewControllers.count, 2)
    }
}
