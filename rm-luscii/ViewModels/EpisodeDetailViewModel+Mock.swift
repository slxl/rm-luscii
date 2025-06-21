import Foundation

extension EpisodeDetailViewModel {
    static var mock: EpisodeDetailViewModel {
        let mockEpisode = Episode(
            id: 1,
            name: "Pilot",
            air_date: "02/12/2013",
            episode: "S01E01",
            characters: [
                "https://rickandmortyapi.com/api/character/1",
                "https://rickandmortyapi.com/api/character/2",
                "https://rickandmortyapi.com/api/character/3"
            ]
        )

        let vm = EpisodeDetailViewModel(episode: mockEpisode, apiService: MockAPIService())
        vm.characters = [
            Character(
                id: 1,
                name: "Rick Sanchez",
                status: "Alive",
                species: "Human",
                origin: Origin(
                    name: "Earth",
                    url: ""
                ),
                image: "https://rickandmortyapi.com/api/character/avatar/1.jpeg",
                episode: []
            ),
            Character(
                id: 2,
                name: "Morty Smith",
                status: "Alive",
                species: "Human",
                origin: Origin(
                    name: "Earth",
                    url: ""
                ),
                image: "https://rickandmortyapi.com/api/character/avatar/2.jpeg",
                episode: []
            ),
            Character(
                id: 3,
                name: "Summer Smith",
                status: "Alive",
                species: "Human",
                origin: Origin(
                    name: "Earth",
                    url: ""
                ),
                image: "https://rickandmortyapi.com/api/character/avatar/3.jpeg",
                episode: []
            )
        ]

        return vm
    }
} 
