import SwiftUI

// MARK: - CharacterDetailView

struct CharacterDetailView: View {
    @StateObject var viewModel: CharacterDetailViewModel

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
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
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
                            .foregroundColor(.primary)

                        Spacer()

                        Text(viewModel.character.status)
                            .font(.headline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(statusColor.opacity(0.2))
                                    .overlay(
                                        Capsule()
                                            .stroke(statusColor, lineWidth: 1)
                                    )
                            )
                            .foregroundColor(statusColor)
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
    }

    private var statusColor: Color {
        switch viewModel.character.status.lowercased() {
        case "alive":
            return .green
        case "dead":
            return .red
        case "unknown":
            return .orange
        default:
            return .gray
        }
    }
}

// MARK: - StatRow

struct StatRow: View {
    let label: String
    let value: String

    private var dottedLine: String {
        String(repeating: ".", count: 1000)
    }

    var body: some View {
        HStack {
            Text(label)
                .font(.system(.body, design: .rounded))
                .foregroundColor(.primary)

            Text(dottedLine)
                .layoutPriority(-1) // to make sure it will be truncated first when no space available
                .foregroundColor(.secondary.opacity(0.3))

            Spacer()

            Text(value)
                .font(.system(.body, design: .rounded, weight: .medium))
                .foregroundColor(.secondary)
        }
        .lineLimit(1)
    }
}

#Preview {
    NavigationView {
        CharacterDetailView(viewModel: .mock)
    }
}
