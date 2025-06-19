import Foundation

extension CharacterDetailViewModel {
    static var mock: CharacterDetailViewModel {
        let mockCharacter = Character(
            id: 1,
            name: "Rick Sanchez",
            status: "Alive",
            species: "Human",
            origin: Origin(name: "Earth (C-137)", url: ""),
            image: "https://rickandmortyapi.com/api/character/avatar/1.jpeg",
            episode: Array(repeating: "", count: 41)
        )

        return CharacterDetailViewModel(character: mockCharacter, apiService: MockAPIService())
    }
}
