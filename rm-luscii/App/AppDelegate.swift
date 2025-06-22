import SwiftUI
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    lazy var coordinator: RootCoordinator = .init()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        true
    }
}
