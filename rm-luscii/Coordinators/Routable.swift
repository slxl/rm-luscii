import Foundation

/// Protocol for ViewModels that can handle navigation routes
/// 
/// This protocol provides a type-safe way for ViewModels to communicate
/// navigation events to their coordinators without tight coupling.
protocol Routable: AnyObject {
    associatedtype Route
    
    /// Handler for navigation routes
    var routeHandler: ((Route) -> Void)? { get set }
}

// MARK: - Routable Extensions

extension Routable {
    /// Convenience method to trigger a route
    /// 
    /// This method provides a cleaner way to trigger routes from within the ViewModel
    /// - Parameter route: The route to trigger
    func route(_ route: Route) {
        routeHandler?(route)
    }
} 