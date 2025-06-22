import SwiftUI

// MARK: - EpisodeListView

struct EpisodeListView: View {
    @ObservedObject var viewModel: EpisodeListViewModel
    @State private var showEasterEgg = false
    @State private var scrollOffset: CGFloat = 0

    var body: some View {
        ScrollViewReader { proxy in
            List {
                ForEach(viewModel.episodes) { episode in
                    Button(action: {
                        viewModel.didSelectEpisode(episode)
                    }) {
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
                    .buttonStyle(PlainButtonStyle())
                    .onAppear {
                        if episode == viewModel.episodes.last && !viewModel.reachedEnd {
                            Task { await viewModel.loadEpisodes() }
                        }
                    }
                }

                if viewModel.reachedEnd {
                    VStack(spacing: 8) {
                        HStack {
                            Spacer()
                            Text("You have reached the end of the list.")
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        
                        if showEasterEgg {
                            HStack {
                                Spacer()
                                Text("Seriously, you don't believe me? 😏")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                                    .italic()
                                Spacer()
                            }
                            .transition(.opacity.combined(with: .scale))
                        }
                    }
                    .id("endOfList")
                } else if viewModel.isLoading {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                }
            }
            .background(Color(.systemBackground))
            .task {
                if viewModel.episodes.isEmpty {
                    await viewModel.loadEpisodes(reset: true)
                }
            }
            .refreshable {
                await viewModel.loadEpisodes(reset: true)
            }
            .onChange(of: viewModel.reachedEnd) { oldValue, newValue in
                if newValue {
                    // When we reach the end, scroll to the bottom to trigger the easter egg
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            proxy.scrollTo("endOfList", anchor: .bottom)
                        }
                    }
                }
            }
            .simultaneousGesture(
                DragGesture()
                    .onChanged { value in
                        if viewModel.reachedEnd {
                            // Check if user is dragging past the bottom
                            let threshold: CGFloat = 50
                            if value.translation.height < -threshold && !showEasterEgg {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    showEasterEgg = true
                                }
                                
                                // Hide the easter egg after 3 seconds
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        showEasterEgg = false
                                    }
                                }
                            }
                        }
                    }
            )
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
    EpisodeListView(viewModel: .previewMock)
}
