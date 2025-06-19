import SwiftUI

// MARK: - EpisodeListView

struct EpisodeListView: View {
    @ObservedObject var viewModel: EpisodeListViewModel

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.episodes) { episode in
                    NavigationLink(destination: EpisodeDetailView(viewModel: EpisodeDetailViewModel(episode: episode))) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(episode.name)
                                .font(.headline)
                            Text(episode.air_date.formattedAirDate)
                                .font(.subheadline)
                            Text(episode.episode)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                    .onAppear {
                        if episode == viewModel.episodes.last && !viewModel.reachedEnd {
                            Task { await viewModel.loadEpisodes() }
                        }
                    }
                }

                if viewModel.reachedEnd {
                    HStack {
                        Spacer()
                        Text("You have reached the end of the list.")
                            .foregroundColor(.gray)
                        Spacer()
                    }
                } else if viewModel.isLoading {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                }
            }
            .navigationTitle("Episodes")
            .task {
                if viewModel.episodes.isEmpty {
                    await viewModel.loadEpisodes(reset: true)
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
}

#Preview {
    EpisodeListView(viewModel: .mock)
}
