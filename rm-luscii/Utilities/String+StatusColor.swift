import SwiftUI
import UIKit

// MARK: - String Status Color Extension

extension String {
    /// Returns the appropriate UIColor for a character status based on the status string
    /// 
    /// Maps character status strings to appropriate system colors:
    /// - "alive" → systemGreen
    /// - "dead" → systemRed  
    /// - "unknown" → systemOrange
    /// - any other value → systemGray
    private var _statusUIColor: UIColor {
        switch self.lowercased() {
        case "alive":
            return UIColor.systemGreen
        case "dead":
            return UIColor.systemRed
        case "unknown":
            return UIColor.systemOrange
        default:
            return UIColor.systemGray
        }
    }

    /// Returns the appropriate SwiftUI Color for a character status
    /// 
    /// Converts the UIColor status color to SwiftUI Color for use in SwiftUI views.
    /// - Returns: SwiftUI Color corresponding to the character's status
    var statusColor: Color {
        Color(_statusUIColor)
    }

    /// Returns the appropriate UIColor for a character status (for UIKit usage)
    /// 
    /// Provides direct access to the UIColor version for use in UIKit contexts like PDF generation.
    /// - Returns: UIColor corresponding to the character's status
    var statusUIColor: UIColor {
        _statusUIColor
    }
}
