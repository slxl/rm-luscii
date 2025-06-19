import SwiftUI

struct EpisodeDetailView: View {
    @StateObject var viewModel: EpisodeDetailViewModel
    
    var body: some View {
        List {
            if viewModel.isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            } else {
                ForEach(viewModel.characters) { character in
                    HStack {
                        AsyncImage(url: URL(string: character.image)) { image in
                            image.resizable().aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Color.gray.opacity(0.2)
                        }
                        .frame(width: 44, height: 44)
                        .clipShape(Circle())
                        Text(character.name)
                            .font(.body)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .navigationTitle(viewModel.episodeTitle)
        .task {
            if viewModel.characters.isEmpty {
                await viewModel.loadCharacters()
            }
        }
        .alert(item: Binding(
            get: { viewModel.error.map { ErrorWrapper(message: $0) } },
            set: { _ in viewModel.error = nil }
        )) { wrapper in
            Alert(title: Text("Error"), message: Text(wrapper.message), dismissButton: .default(Text("OK")))
        }
    }
}

#Preview {
    NavigationView {
        EpisodeDetailView(viewModel: .mock)
    }
} 