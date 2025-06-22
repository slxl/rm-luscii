// MARK: - PreviewAPIService

class PreviewAPIService: APIServiceProtocol {
    private enum Constants {
        static let defaultPageCount = 2
        static let defaultTotalPages = 1
        static let defaultCharacterStatus = "Alive"
        static let defaultCharacterSpecies = "Human"
        static let defaultOriginName = "Earth"
        static let defaultOriginURL = ""
    }

    /// Provides mock episode data for testing and previews
    /// - Parameter page: The page number (ignored in mock implementation)
    /// - Returns: Mock EpisodeResponse with sample episodes
    func fetchEpisodes(page: Int) async throws -> EpisodeResponse {
        let episodes = [
            Episode(id: 1, name: "Pilot", air_date: "02/12/2013", episode: "S01E01", characters: []),
            Episode(id: 2, name: "Lawnmower Dog", air_date: "09/12/2013", episode: "S01E02", characters: [])
        ]

        let info = PageInfo(count: Constants.defaultPageCount, pages: Constants.defaultTotalPages, next: nil, prev: nil)

        return EpisodeResponse(info: info, results: episodes)
    }

    /// Provides mock character data for testing and previews
    /// - Parameter ids: Array of character IDs to generate mock characters for
    /// - Returns: Array of mock Character objects
    func fetchCharacters(ids: [Int]) async throws -> [Character] {
        ids
            .map {
                Character(
                    id: $0,
                    name: "Character \($0)",
                    status: Constants.defaultCharacterStatus,
                    species: Constants.defaultCharacterSpecies,
                    origin: Origin(
                        name: Constants.defaultOriginName,
                        url: Constants.defaultOriginURL
                    ),
                    image: "",
                    episode: []
                )
            }
    }
}
