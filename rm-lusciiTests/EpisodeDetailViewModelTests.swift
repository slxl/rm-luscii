@testable import rm_luscii
import XCTest

@MainActor
final class EpisodeDetailViewModelTests: XCTestCase {
    var viewModel: EpisodeDetailViewModel!
    var mockAPIService: MockAPIService!
    var testEpisode: Episode!

    override func setUp() {
        super.setUp()
        mockAPIService = MockAPIService()

        testEpisode = Episode(
            id: 1,
            name: "Test Episode",
            air_date: "2023-01-01",
            episode: "S01E01",
            characters: [
                "https://rickandmortyapi.com/api/character/1",
                "https://rickandmortyapi.com/api/character/2"
            ]
        )

        viewModel = EpisodeDetailViewModel(episode: testEpisode, apiService: mockAPIService)
    }

    override func tearDown() {
        viewModel = nil
        mockAPIService = nil
        testEpisode = nil
        super.tearDown()
    }

    // MARK: - Initial State Tests

    func testInitialState() {
        XCTAssertTrue(viewModel.characters.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.error)
        XCTAssertEqual(viewModel.episodeTitle, "Test Episode")
        XCTAssertNil(viewModel.routeHandler)
    }

    func testCharacterIDsExtraction() async {
        // Test that character IDs are correctly extracted from URLs
        let episodeWithCharacterURLs = Episode(
            id: 1,
            name: "Test Episode",
            air_date: "2023-01-01",
            episode: "S01E01",
            characters: [
                "https://rickandmortyapi.com/api/character/1",
                "https://rickandmortyapi.com/api/character/2",
                "https://rickandmortyapi.com/api/character/42"
            ]
        )
        
        let testViewModel = EpisodeDetailViewModel(episode: episodeWithCharacterURLs, apiService: mockAPIService)
        
        // Verify the episode title is set correctly
        XCTAssertEqual(testViewModel.episodeTitle, "Test Episode")
        
        // Test that character IDs are extracted by calling loadCharacters and verifying API call
        await testViewModel.loadCharacters()
        
        // The mock should have been called with the extracted character IDs [1, 2, 42]
        XCTAssertEqual(mockAPIService.fetchCharactersCallCount, 1)
        XCTAssertEqual(mockAPIService.capturedCharacterIDs, [1, 2, 42])
    }

    // MARK: - Loading Characters Tests

    func testLoadCharactersSuccess() async {
        // Given
        let mockCharacters = [
            Character(id: 1, name: "Rick", status: "Alive", species: "Human", origin: Origin(name: "Earth", url: ""), image: "", episode: []),
            Character(id: 2, name: "Morty", status: "Alive", species: "Human", origin: Origin(name: "Earth", url: ""), image: "", episode: [])
        ]

        mockAPIService.mockCharacters = mockCharacters

        // When
        await viewModel.loadCharacters()

        // Then
        XCTAssertEqual(viewModel.characters.count, 2)
        XCTAssertEqual(viewModel.characters[0].name, "Rick")
        XCTAssertEqual(viewModel.characters[1].name, "Morty")
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.error)
    }

    func testLoadCharactersFailure() async {
        // Given
        let testError = NSError(domain: "TestError", code: 500, userInfo: nil)
        mockAPIService.mockError = testError

        // When
        await viewModel.loadCharacters()

        // Then
        XCTAssertTrue(viewModel.characters.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.error, testError.localizedDescription)
    }

    func testLoadCharactersWithEmptyCharacterList() async {
        // Given
        let episodeWithNoCharacters = Episode(
            id: 1,
            name: "Empty Episode",
            air_date: "2023-01-01",
            episode: "S01E01",
            characters: []
        )

        let viewModelWithNoCharacters = EpisodeDetailViewModel(episode: episodeWithNoCharacters, apiService: mockAPIService)

        // When
        await viewModelWithNoCharacters.loadCharacters()

        // Then
        XCTAssertTrue(viewModelWithNoCharacters.characters.isEmpty)
        XCTAssertFalse(viewModelWithNoCharacters.isLoading)
        XCTAssertNil(viewModelWithNoCharacters.error)
    }

    func testLoadCharactersMaintainsOrder() async {
        // Given
        let mockCharacters = [
            Character(id: 2, name: "Morty", status: "Alive", species: "Human", origin: Origin(name: "Earth", url: ""), image: "", episode: []),
            Character(id: 1, name: "Rick", status: "Alive", species: "Human", origin: Origin(name: "Earth", url: ""), image: "", episode: [])
        ]
        
        mockAPIService.mockCharacters = mockCharacters

        // When
        await viewModel.loadCharacters()

        // Then - Characters should be in the order they appear in the episode
        XCTAssertEqual(viewModel.characters.count, 2)
        XCTAssertEqual(viewModel.characters[0].id, 1) // First in episode
        XCTAssertEqual(viewModel.characters[1].id, 2) // Second in episode
    }

    func testLoadCharactersPreventsMultipleRequests() async {
        // When - Start multiple concurrent requests
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.viewModel.loadCharacters() }
            group.addTask { await self.viewModel.loadCharacters() }
            group.addTask { await self.viewModel.loadCharacters() }
        }

        // Then - Should only make one API call
        XCTAssertEqual(mockAPIService.fetchCharactersCallCount, 1)
    }

    // MARK: - Route Handling Tests

    func testDidSelectCharacterTriggersRoute() {
        // Given
        let character = Character(id: 1, name: "Rick", status: "Alive", species: "Human", origin: Origin(name: "Earth", url: ""), image: "", episode: [])
        var capturedRoute: EpisodeDetailViewModel.Route?
        viewModel.routeHandler = { route in
            capturedRoute = route
        }

        // When
        viewModel.didSelectCharacter(character)

        // Then
        XCTAssertEqual(capturedRoute, .showCharacterDetail(character))
    }

    func testDidSelectCharacterWithoutRouteHandler() {
        // Given
        let character = Character(id: 1, name: "Rick", status: "Alive", species: "Human", origin: Origin(name: "Earth", url: ""), image: "", episode: [])

        // When & Then - Should not crash
        viewModel.didSelectCharacter(character)
    }

    // MARK: - Loading State Tests

    func testLoadingStateDuringAPIRequest() async {
        // Given - Start with not loading
        XCTAssertFalse(viewModel.isLoading)
        
        // When - Load characters
        await viewModel.loadCharacters()
        
        // Then - Should not be loading after completion
        XCTAssertFalse(viewModel.isLoading)
    }

    func testErrorClearingOnNewRequest() async {
        // Given
        let testError = NSError(domain: "TestError", code: 500, userInfo: nil)
        mockAPIService.mockError = testError

        // Load with error
        await viewModel.loadCharacters()
        XCTAssertEqual(viewModel.error, testError.localizedDescription)

        // When - Load again with success
        mockAPIService.mockError = nil
        let mockCharacters = [Character(id: 1, name: "Rick", status: "Alive", species: "Human", origin: Origin(name: "Earth", url: ""), image: "", episode: [])]
        mockAPIService.mockCharacters = mockCharacters

        await viewModel.loadCharacters()

        // Then - Error should be cleared
        XCTAssertNil(viewModel.error)
        XCTAssertEqual(viewModel.characters.count, 1)
    }
}
