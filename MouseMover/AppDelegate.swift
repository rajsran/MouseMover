import Cocoa
import IOKit.pwr_mgt
import Quartz
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var assertionID: IOPMAssertionID = 0
    var mouseMoveTimer: Timer?
    var stopTimer: Timer?
    var isRunning: Bool = false
    var eventMonitor: Any?
    @AppStorage("moveInterval") private var moveInterval: Double = 5.0 // default to 1 second
    @AppStorage("runDuration") private var runDuration: Double = 900.0 // default to 15 minutes

    var startStopMenuItem: NSMenuItem?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Check for accessibility permissions
        checkAccessibilityPermissions()
        
        // Set the application's icon in the Dock
        if let dockIcon = NSImage(named: "DockIcon") {
            NSApplication.shared.applicationIconImage = dockIcon
        }

        // Create the status bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            if let menuBarIcon = NSImage(named: "MenuBarIcon") {
                button.image = menuBarIcon
                button.image?.isTemplate = true // This makes the icon adapt to light/dark mode
            } else {
                print("Menu bar icon not found")
            }
        }
        
        // Create the menu
        let menu = NSMenu()
        startStopMenuItem = NSMenuItem(title: "Start", action: #selector(toggleStartStop), keyEquivalent: "s")
        menu.addItem(startStopMenuItem!)
        menu.addItem(NSMenuItem.separator())
        
        let customMenuItem = NSMenuItem()
        let customView = NSHostingView(rootView: CustomMenuItemView())
        customView.frame = NSRect(x: 0, y: 0, width: 300, height: 200) // Adjust frame size
        customMenuItem.view = customView
        menu.addItem(customMenuItem)
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))
        statusItem?.menu = menu
        
        // Prevent sleep
        let reasonForActivity = "Prevent sleep for StayAwakeApp" as CFString
        let success = IOPMAssertionCreateWithName(kIOPMAssertionTypeNoDisplaySleep as CFString, IOPMAssertionLevel(kIOPMAssertionLevelOn), reasonForActivity, &assertionID)
        if success == kIOReturnSuccess {
            print("Sleep prevented successfully")
        } else {
            print("Failed to prevent sleep")
        }

        // Monitor for Esc key
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { event in
            if event.keyCode == 53 { // 53 is the keyCode for the Esc key
                self.quit()
            }
        }
        
        // Start mouse movement immediately
        startMouseMoveTimer()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Release the sleep prevention assertion
        IOPMAssertionRelease(assertionID)
        
        // Stop mouse move timer
        stopMouseMoveTimer()
        
        // Remove the event monitor
        if let eventMonitor = eventMonitor {
            NSEvent.removeMonitor(eventMonitor)
        }
        
        // Reset cursor to default
        NSCursor.arrow.set()
    }

    func checkAccessibilityPermissions() {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        let accessEnabled = AXIsProcessTrustedWithOptions(options)

        if !accessEnabled {
            let alert = NSAlert()
            alert.messageText = "Accessibility Permissions Required"
            alert.informativeText = "Please enable accessibility permissions for this app in System Preferences."
            alert.addButton(withTitle: "Open System Preferences")
            alert.addButton(withTitle: "Quit")
            let response = alert.runModal()
            if response == .alertFirstButtonReturn {
                if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                    NSWorkspace.shared.open(url)
                }
            } else {
                NSApplication.shared.terminate(self)
            }
        }
    }

    func moveMouse() {
        let currentLocation = NSEvent.mouseLocation

        // Add a small random offset
        let offsetX = CGFloat(arc4random_uniform(5)) - 2.5
        let offsetY = CGFloat(arc4random_uniform(5)) - 2.5
        let newLocation = CGPoint(x: currentLocation.x + offsetX, y: currentLocation.y + offsetY)

        let move = CGEvent(mouseEventSource: nil, mouseType: .mouseMoved, mouseCursorPosition: newLocation, mouseButton: .left)
        move?.post(tap: .cghidEventTap)
        
        // Set the cursor to hand
        NSCursor.pointingHand.push()
    }

    func startMouseMoveTimer() {
        stopMouseMoveTimer()  // Ensure any existing timer is stopped before starting a new one
        mouseMoveTimer = Timer.scheduledTimer(withTimeInterval: moveInterval, repeats: true) { _ in
            self.moveMouse()
        }
        stopTimer = Timer.scheduledTimer(withTimeInterval: runDuration, repeats: false) { _ in
            self.stopMouseMoveTimer()
        }
        isRunning = true
        updateMenu()
        // Change cursor to hand
        NSCursor.pointingHand.set()
    }

    func stopMouseMoveTimer() {
        mouseMoveTimer?.invalidate()
        stopTimer?.invalidate()
        mouseMoveTimer = nil
        stopTimer = nil
        isRunning = false
        updateMenu()
        // Reset cursor to default
        NSCursor.arrow.pop()
    }

    @objc func toggleStartStop() {
        if isRunning {
            stopMouseMoveTimer()
        } else {
            startMouseMoveTimer()
        }
    }

    func updateMenu() {
        if isRunning {
            startStopMenuItem?.title = "Stop"
            startStopMenuItem?.action = #selector(toggleStartStop)
        } else {
            startStopMenuItem?.title = "Start"
            startStopMenuItem?.action = #selector(toggleStartStop)
        }
    }

    @objc func quit() {
        NSApplication.shared.terminate(self)
    }
}


