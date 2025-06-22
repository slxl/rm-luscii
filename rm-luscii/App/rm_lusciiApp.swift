import SwiftUI

// MARK: - rm_lusciiApp

@main
struct rm_lusciiApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            CoordinatorView(coordinator: appDelegate.coordinator)
        }
    }
}

// MARK: - CoordinatorView

struct CoordinatorView: UIViewControllerRepresentable {
    let coordinator: RootCoordinator

    func makeUIViewController(context: Context) -> UIViewController {
        coordinator.start()
        return coordinator.rootViewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // No updates needed
    }
}
