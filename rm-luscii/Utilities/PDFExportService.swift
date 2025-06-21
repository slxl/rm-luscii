import Foundation
import PDFKit
import UIKit

// MARK: - PDFExportServiceProtocol

protocol PDFExportServiceProtocol {
    func createCharacterPDF(character: Character) throws -> Data
}

// MARK: - PDFExportService

class PDFExportService: PDFExportServiceProtocol {
    private enum Constants {
        static let pageRect = CGRect(x: 0, y: 0, width: 595.2, height: 841.8) // A4 size
        static let titleFontSize: CGFloat = 24
        static let subtitleFontSize: CGFloat = 18
        static let bodyFontSize: CGFloat = 14
        static let smallFontSize: CGFloat = 12
        
        static let titleString = "Character Details"
        static let statusLabelPrefix = "Status: "
        static let speciesLabelPrefix = "Species: "
        static let originLabelPrefix = "Origin: "
        static let episodesLabelPrefix = "Total Episodes: "
        static let timestampPrefix = "Exported on: "
        
        static let statusRectWidth: CGFloat = 200
        static let statusRectHeight: CGFloat = 25
        static let statusRectCornerRadius: CGFloat = 12.5
        static let statusBackgroundAlpha: CGFloat = 0.2
        static let statusTextPadding: CGFloat = 5
        
        static let initialYPosition: CGFloat = 50
        static let titleSpacing: CGFloat = 40
        static let subtitleSpacing: CGFloat = 30
        static let statusSpacing: CGFloat = 40
        static let detailSpacing: CGFloat = 25
        static let finalSpacing: CGFloat = 20
        
        static let leftMargin: CGFloat = 50
        static let statusLeftMargin: CGFloat = 60
        
        enum Metadata {
            static let creator = "Rick and Morty App"
            static let author = "Character Details"
        }
    }
    
    /// Creates a PDF document containing character details with formatted layout
    /// - Parameter character: The character whose details will be included in the PDF
    /// - Returns: PDF data that can be saved to a file or shared
    /// - Throws: Any error that occurs during PDF generation
    func createCharacterPDF(character: Character) throws -> Data {
        let pdfMetaData = [
            kCGPDFContextCreator: Constants.Metadata.creator,
            kCGPDFContextAuthor: Constants.Metadata.author,
            kCGPDFContextTitle: character.name
        ]
        
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        let renderer = UIGraphicsPDFRenderer(bounds: Constants.pageRect, format: format)

        let data = renderer.pdfData { context in
            context.beginPage()

            let titleFont = UIFont.boldSystemFont(ofSize: Constants.titleFontSize)
            let subtitleFont = UIFont.systemFont(ofSize: Constants.subtitleFontSize)
            let bodyFont = UIFont.systemFont(ofSize: Constants.bodyFontSize)
            let smallFont = UIFont.systemFont(ofSize: Constants.smallFontSize)

            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: titleFont,
                .foregroundColor: UIColor.black
            ]

            let subtitleAttributes: [NSAttributedString.Key: Any] = [
                .font: subtitleFont,
                .foregroundColor: UIColor.darkGray
            ]

            let bodyAttributes: [NSAttributedString.Key: Any] = [
                .font: bodyFont,
                .foregroundColor: UIColor.black
            ]

            let smallAttributes: [NSAttributedString.Key: Any] = [
                .font: smallFont,
                .foregroundColor: UIColor.gray
            ]

            var yPosition: CGFloat = Constants.initialYPosition

            // Title
            Constants.titleString.draw(at: CGPoint(x: Constants.leftMargin, y: yPosition), withAttributes: titleAttributes)
            yPosition += Constants.titleSpacing

            // Character Name
            let nameString = character.name
            nameString.draw(at: CGPoint(x: Constants.leftMargin, y: yPosition), withAttributes: subtitleAttributes)
            yPosition += Constants.subtitleSpacing

            // Status with colored background
            let statusString = "\(Constants.statusLabelPrefix)\(character.status)"
            let statusRect = CGRect(x: Constants.leftMargin, y: yPosition, width: Constants.statusRectWidth, height: Constants.statusRectHeight)

            // Draw status background
            let statusColor = character.status.statusUIColor
            statusColor.withAlphaComponent(Constants.statusBackgroundAlpha).setFill()
            UIBezierPath(roundedRect: statusRect, cornerRadius: Constants.statusRectCornerRadius).fill()
            statusColor.setStroke()
            UIBezierPath(roundedRect: statusRect, cornerRadius: Constants.statusRectCornerRadius).stroke()

            statusString.draw(at: CGPoint(x: Constants.statusLeftMargin, y: yPosition + Constants.statusTextPadding), withAttributes: bodyAttributes)
            yPosition += Constants.statusSpacing

            // Other details
            let details = [
                "\(Constants.speciesLabelPrefix)\(character.species)",
                "\(Constants.originLabelPrefix)\(character.origin.name)",
                "\(Constants.episodesLabelPrefix)\(character.episode.count)"
            ]

            for detail in details {
                detail.draw(at: CGPoint(x: Constants.leftMargin, y: yPosition), withAttributes: bodyAttributes)
                yPosition += Constants.detailSpacing
            }

            yPosition += Constants.finalSpacing

            // Export timestamp
            let timestampString = "\(Constants.timestampPrefix)\(Date().formatted(date: .abbreviated, time: .shortened))"
            timestampString.draw(at: CGPoint(x: Constants.leftMargin, y: yPosition), withAttributes: smallAttributes)
        }

        return data
    }
}

// MARK: - MockPDFExportService

/// Mock implementation of PDFExportServiceProtocol for testing and previews
class MockPDFExportService: PDFExportServiceProtocol {
    /// Provides mock PDF data for testing purposes
    /// - Parameter character: The character (ignored in mock implementation)
    /// - Returns: Empty Data object for testing
    func createCharacterPDF(character: Character) throws -> Data {
        // Return empty PDF data for testing
        return Data()
    }
}
