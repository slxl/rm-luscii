import Foundation

extension String {
    var formattedAirDate: String {
        // Try to parse and reformat, else return as is
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd/MM/yyyy" // Already formatted
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "dd/MM/yyyy"
        if let date = inputFormatter.date(from: self) {
            return outputFormatter.string(from: date)
        } else {
            // Try API format
            let apiFormatter = DateFormatter()
            apiFormatter.dateFormat = "dd MMM yyyy"
            if let date = apiFormatter.date(from: self) {
                return outputFormatter.string(from: date)
            }
            return self
        }
    }
} 