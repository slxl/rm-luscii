@testable import rm_luscii
import XCTest

@MainActor
final class EpisodeListViewModelTests: XCTestCase {
    var viewModel: EpisodeListViewModel!
    var mockAPIService: MockAPIService!

    override func setUp() {
        super.setUp()
        mockAPIService = MockAPIService()
        viewModel = EpisodeListViewModel(apiService: mockAPIService)
    }

    override func tearDown() {
        viewModel = nil
        mockAPIService = nil
        super.tearDown()
    }

    // MARK: - Initial State Tests

    func testInitialState() {
        XCTAssertTrue(viewModel.episodes.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertFalse(viewModel.reachedEnd)
        XCTAssertNil(viewModel.error)
        XCTAssertNil(viewModel.routeHandler)
    }

    // MARK: - Loading Episodes Tests

    func testLoadEpisodesSuccess() async {
        // Given
        let mockEpisodes = [
            Episode(id: 1, name: "Test Episode 1", air_date: "2023-01-01", episode: "S01E01", characters: []),
            Episode(id: 2, name: "Test Episode 2", air_date: "2023-01-02", episode: "S01E02", characters: [])
        ]

        let mockResponse = EpisodeResponse(info: PageInfo(count: 2, pages: 1, next: nil, prev: nil), results: mockEpisodes)
        mockAPIService.mockEpisodeResponse = mockResponse

        // When
        await viewModel.loadEpisodes(reset: true)

        // Then
        XCTAssertEqual(viewModel.episodes.count, 2)
        XCTAssertEqual(viewModel.episodes[0].name, "Test Episode 1")
        XCTAssertEqual(viewModel.episodes[1].name, "Test Episode 2")
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertTrue(viewModel.reachedEnd)
        XCTAssertNil(viewModel.error)
    }

    func testLoadEpisodesFailure() async {
        // Given
        let testError = NSError(domain: "TestError", code: 500, userInfo: nil)
        mockAPIService.mockError = testError

        // When
        await viewModel.loadEpisodes(reset: true)

        // Then
        XCTAssertTrue(viewModel.episodes.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.error, testError.localizedDescription)
    }

    func testLoadEpisodesPagination() async {
        // Given
        let firstPageEpisodes = [
            Episode(id: 1, name: "Episode 1", air_date: "2023-01-01", episode: "S01E01", characters: [])
        ]

        let secondPageEpisodes = [
            Episode(id: 2, name: "Episode 2", air_date: "2023-01-02", episode: "S01E02", characters: [])
        ]

        let firstResponse = EpisodeResponse(
            info: PageInfo(count: 2, pages: 2, next: "page2", prev: nil),
            results: firstPageEpisodes
        )
        let secondResponse = EpisodeResponse(
            info: PageInfo(count: 2, pages: 2, next: nil, prev: "page1"),
            results: secondPageEpisodes
        )

        mockAPIService.mockEpisodeResponse = firstResponse

        // When - Load first page
        await viewModel.loadEpisodes(reset: true)

        // Then
        XCTAssertEqual(viewModel.episodes.count, 1)
        XCTAssertFalse(viewModel.reachedEnd)

        // When - Load second page
        mockAPIService.mockEpisodeResponse = secondResponse
        await viewModel.loadEpisodes()

        // Then
        XCTAssertEqual(viewModel.episodes.count, 2)
        XCTAssertTrue(viewModel.reachedEnd)
    }

    func testLoadCharactersPreventsMultipleRequests() async {
        // Given
        let mockEpisodes = [Episode(id: 1, name: "Test", air_date: "2023-01-01", episode: "S01E01", characters: [])]
        let mockResponse = EpisodeResponse(info: PageInfo(count: 1, pages: 1, next: nil, prev: nil), results: mockEpisodes)
        mockAPIService.mockEpisodeResponse = mockResponse

        // When - Start multiple concurrent requests
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.viewModel.loadEpisodes(reset: true) }
            group.addTask { await self.viewModel.loadEpisodes(reset: true) }
            group.addTask { await self.viewModel.loadEpisodes(reset: true) }
        }

        // Then - Should only make one API call
        XCTAssertEqual(mockAPIService.fetchEpisodesCallCount, 1)
    }

    // MARK: - Route Handling Tests

    func testDidSelectEpisodeTriggersRoute() {
        // Given
        let episode = Episode(id: 1, name: "Test Episode", air_date: "2023-01-01", episode: "S01E01", characters: [])
        var capturedRoute: EpisodeListViewModel.Route?
        viewModel.routeHandler = { route in
            capturedRoute = route
        }

        // When
        viewModel.didSelectEpisode(episode)

        // Then
        XCTAssertEqual(capturedRoute, .showEpisodeDetail(episode))
    }

    func testDidSelectEpisodeWithoutRouteHandler() {
        // Given
        let episode = Episode(id: 1, name: "Test Episode", air_date: "2023-01-01", episode: "S01E01", characters: [])

        // When & Then - Should not crash
        viewModel.didSelectEpisode(episode)
    }

    // MARK: - Loading State Tests

    func testLoadingStateDuringAPIRequest() async {
        // Given - Start with not loading
        XCTAssertFalse(viewModel.isLoading)

        // When - Load characters
        await viewModel.loadEpisodes(reset: true)

        // Then - Should not be loading after completion
        XCTAssertFalse(viewModel.isLoading)
    }

    func testResetClearsState() async {
        // Given
        let mockEpisodes = [Episode(id: 1, name: "Test", air_date: "2023-01-01", episode: "S01E01", characters: [])]
        let mockResponse = EpisodeResponse(info: PageInfo(count: 1, pages: 1, next: nil, prev: nil), results: mockEpisodes)
        mockAPIService.mockEpisodeResponse = mockResponse

        // Load some episodes first
        await viewModel.loadEpisodes(reset: true)
        XCTAssertEqual(viewModel.episodes.count, 1)
        XCTAssertTrue(viewModel.reachedEnd)

        // When - Reset
        await viewModel.loadEpisodes(reset: true)

        // Then - Should start fresh
        XCTAssertEqual(viewModel.episodes.count, 1) // New episodes loaded
        XCTAssertTrue(viewModel.reachedEnd)
    }
}
