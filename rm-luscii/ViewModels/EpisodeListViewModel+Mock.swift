import Foundation

extension EpisodeListViewModel {
    static var mock: EpisodeListViewModel {
        let vm = EpisodeListViewModel(apiService: MockAPIService())
        vm.episodes = [
            Episode(id: 1, name: "Pilot", air_date: "02/12/2013", episode: "S01E01", characters: []),
            Episode(id: 2, name: "Lawnmower Dog", air_date: "09/12/2013", episode: "S01E02", characters: []),
            Episode(id: 3, name: "Anatomy Park", air_date: "16/12/2013", episode: "S01E03", characters: []),
            Episode(id: 4, name: "M. Night Shaym-Aliens!", air_date: "13/01/2014", episode: "S01E04", characters: []),
            Episode(id: 5, name: "Meeseeks and Destroy", air_date: "20/01/2014", episode: "S01E05", characters: []),
            Episode(id: 6, name: "Rick Potion #9", air_date: "27/01/2014", episode: "S01E06", characters: []),
            Episode(id: 7, name: "Raising Gazorpazorp", air_date: "10/03/2014", episode: "S01E07", characters: [])
        ]
        vm.reachedEnd = true
        return vm
    }
} 