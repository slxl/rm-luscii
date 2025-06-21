import Foundation

@MainActor
class CharacterDetailViewModel: ObservableObject {
    @Published var character: Character
    @Published var error: String?
    @Published var isExporting = false

    private let pdfExportService: PDFExportServiceProtocol

    private enum Constants {
        static let pdfExtension = ".pdf"
        static let spaceReplacement = "_"
        static let filenameSuffix = "_details"
    }

    init(
        character: Character,
        pdfExportService: PDFExportServiceProtocol
    ) {
        self.character = character
        self.pdfExportService = pdfExportService
    }

    /// Exports character details as a PDF file and returns the file URL for sharing
    ///
    /// This function runs the PDF generation on a background thread to avoid blocking the UI.
    /// The PDF includes character name, status, species, origin, episode count, and export timestamp.
    ///
    /// - Returns: The URL of the generated PDF file, or nil if export failed

    func exportCharacterDetailsForSharing() async -> URL? {
        await MainActor.run { self.isExporting = true }

        // Capture values before the task to avoid self references
        let character = self.character
        let pdfExportService = self.pdfExportService

        let task = Task.detached(priority: .userInitiated) { () -> URL? in
            // Create filename
            let filename = "\(character.name.replacingOccurrences(of: " ", with: Constants.spaceReplacement))\(Constants.filenameSuffix)\(Constants.pdfExtension)"

            // Get documents directory

            guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                return nil
            }

            let fileURL = documentsPath.appendingPathComponent(filename)
            do {
                // Create PDF document using the service
                let pdfData = try pdfExportService.createCharacterPDF(character: character)

                // Write PDF to file
                try pdfData.write(to: fileURL)

                return fileURL
            } catch {
                return nil
            }
        }

        let fileURL = await task.value

        await MainActor.run { self.isExporting = false }

        if fileURL == nil {
            await MainActor.run {
                self.error = "Failed to export character details"
            }
        }

        return fileURL
    }
}
