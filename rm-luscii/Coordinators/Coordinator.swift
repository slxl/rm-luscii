import SwiftUI
import UIKit

internal protocol Coordinator: AnyObject {
    associatedtype R // swiftlint:disable:this type_name

    var rootViewController: UIViewController { get }
    var routeHandler: ((R) -> Void)? { get set }

    @MainActor func start()
}
