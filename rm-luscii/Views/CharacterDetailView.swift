import SwiftUI

// MARK: - ShareSheet

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - CharacterDetailView

struct CharacterDetailView: View {
    @StateObject var viewModel: CharacterDetailViewModel
    @State private var showShareSheet = false
    @State private var shareFileURL: URL? = nil

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Character Card
                VStack(spacing: 20) {
                    // Character Image with gradient background
                    ZStack {
                        // Background gradient
                        LinearGradient(
                            colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .frame(width: 200, height: 200)
                        .clipShape(Circle())

                        AsyncImage(url: URL(string: viewModel.character.image)) { image in
                            image.resizable().aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Color.gray.opacity(0.2)
                        }
                        .frame(width: 180, height: 180)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 4
                                )
                        )
                        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                    }

                    // Character Name
                    Text(viewModel.character.name)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal)

                // Stats Card
                VStack(spacing: 16) {
                    // Status Badge
                    HStack {
                        Text("Status")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(viewModel.character.status)
                            .font(.headline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(viewModel.character.status.statusColor.opacity(0.2))
                                    .overlay(
                                        Capsule()
                                            .stroke(viewModel.character.status.statusColor, lineWidth: 1)
                                    )
                            )
                            .foregroundColor(viewModel.character.status.statusColor)
                    }

                    Divider()

                    // Character Stats
                    VStack(spacing: 12) {
                        StatRow(label: "Species", value: viewModel.character.species)
                        StatRow(label: "Origin", value: viewModel.character.origin.name)
                        StatRow(label: "Episodes", value: "\(viewModel.character.episode.count)")
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                )
                .padding(.horizontal)

                // Export Button
                Button(action: {
                    Task {
                        if let fileURL = await viewModel.exportCharacterDetailsForSharing() {
                            shareFileURL = fileURL
                            showShareSheet = true
                        }
                    }
                }) {
                    HStack {
                        if viewModel.isExporting {
                            ProgressView()
                                .scaleEffect(0.8)
                                .foregroundColor(.white)
                        } else {
                            Image(systemName: "square.and.arrow.up")
                                .font(.headline)
                        }
                        Text(viewModel.isExporting ? "Exporting..." : "Export Details")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .disabled(viewModel.isExporting)
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(
            LinearGradient(
                colors: [Color(.systemGroupedBackground), Color(.systemBackground)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .navigationTitle(viewModel.character.name)
        .navigationBarTitleDisplayMode(.inline)
        .alert(item: Binding(
            get: { viewModel.error.map { ErrorWrapper(message: $0) } },
            set: { _ in viewModel.error = nil }
        )) { wrapper in
            Alert(title: Text("Export Error"), message: Text(wrapper.message), dismissButton: .default(Text("OK")))
        }
        .sheet(isPresented: $showShareSheet) {
            if let fileURL = shareFileURL {
                ShareSheet(activityItems: [fileURL])
            }
        }
    }
}


#Preview {
    NavigationView {
        CharacterDetailView(viewModel: .mock)
    }
}
