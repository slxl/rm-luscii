import SwiftUI

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
