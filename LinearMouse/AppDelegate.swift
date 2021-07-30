//
//  AppDelegate.swift
//  LinearMouse
//
//  Created by lujjjh on 2021/6/10.
//

import Combine
import SwiftUI

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    let statusItem = StatusItem()

    let mouseAcceleration = MouseAcceleration()
    var linearMovementOn: Bool = false {
        didSet {
            guard oldValue != linearMovementOn else { return }
            if linearMovementOn {
                mouseAcceleration.disable()
            } else {
                mouseAcceleration.enable()
            }
        }
    }

    var defaultsSubscription: AnyCancellable!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        withAccessibilityPermission {
            // register the start entry if the user grants the permission
            AutoStartManager.enable()

            // scrolling functionalities
            ScrollWheelEventTap().enable()

            // subscribe to the user settings
            let defaults = AppDefaults.shared
            self.defaultsSubscription = defaults.objectWillChange.sink { _ in
                DispatchQueue.main.async {
                    self.update(defaults)
                }
            }
            self.update(defaults)
        }
    }

    func withAccessibilityPermission(shouldAskForPermission: Bool = true, completion: @escaping () -> Void) {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue(): shouldAskForPermission] as CFDictionary
        guard AXIsProcessTrustedWithOptions(options) else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.withAccessibilityPermission(shouldAskForPermission: false, completion: completion)
            }
            return
        }
        completion()
    }

    func update(_ defaults: AppDefaults) {
        linearMovementOn = defaults.linearMovementOn
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if flag {
            return true
        }
        statusItem.openPreferencesAction()
        return false
    }
}