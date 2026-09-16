import SwiftUI
import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApplication.shared.setActivationPolicy(.accessory)
    }
}

@main
struct AIStatusApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var viewModel = AppViewModel()

    var body: some Scene {
        MenuBarExtra {
            MenuBarContentView(viewModel: viewModel)
        } label: {
            Image(systemName: "gauge.with.dots.needle.50percent")
        }
        .menuBarExtraStyle(.window)
    }
}
