import Foundation
@testable import rm_luscii

class MockPDFExportService: PDFExportServiceProtocol {
    var mockPDFData: Data?
    var mockError: Error?
    var createPDFCallCount = 0

    func createCharacterPDF(character: Character) throws -> Data {
        createPDFCallCount += 1

        if let error = mockError {
            throw error
        }

        return mockPDFData ?? Data()
    }

    // MARK: - Reset Methods

    func reset() {
        mockPDFData = nil
        mockError = nil
        createPDFCallCount = 0
    }
}
