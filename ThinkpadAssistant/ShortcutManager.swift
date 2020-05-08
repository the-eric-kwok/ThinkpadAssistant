//
//  ShortcutManager.swift
//  ThinkpadAssistant
//
//  Created by Matt on 17.04.20.
//  Copyright © 2020 Matthäus Szturc. All rights reserved.
//

import Foundation
import MASShortcut

final class ShortcutManager {
    
    static let mirroringMonitorShortcut = MASShortcut(keyCode: kVK_F16, modifierFlags: [])
    static let disableWlanShortcut = MASShortcut(keyCode: kVK_F17, modifierFlags: [])
    static let systemPrefsShortcut = MASShortcut(keyCode: kVK_F18, modifierFlags: [])
    static let launchpadShortcut = MASShortcut(keyCode: kVK_F19, modifierFlags: [])
    static let micMuteShortcut = MASShortcut(keyCode: kVK_F20, modifierFlags: [])
    static let micMuteShortcutActivate = MASShortcut(keyCode: kVK_F20, modifierFlags: [.control])
    static let micMuteShortcutDeactivate = MASShortcut(keyCode: kVK_F20, modifierFlags: [.command])
    
    static func register() {
        MASShortcutMonitor.shared()?.register(systemPrefsShortcut, withAction: {
            startApp(withBundleIdentifier: "com.apple.systempreferences")
        })
        
        MASShortcutMonitor.shared()?.register(launchpadShortcut, withAction: {
            startApp(withBundleIdentifier: "com.apple.launchpad.launcher")
        })
        
        MASShortcutMonitor.shared()?.register(micMuteShortcut, withAction: {
            if(MuteMicManager.isMuted() == true){
                HUD.showImage(Icons.unmute, status: NSLocalizedString("Microphone\nunmuted", comment: ""))
                MuteMicManager.toggleMute()
            } else {
                HUD.showImage(Icons.mute, status: NSLocalizedString("Microphone\nmuted", comment: ""))
                MuteMicManager.toggleMute()
            }
        })
        
        MASShortcutMonitor.shared()?.register(micMuteShortcutActivate, withAction: {
            if(MuteMicManager.isMuted() == true){
                HUD.showImage(Icons.unmute, status: NSLocalizedString("Microphone\nunmuted", comment: ""))
                MuteMicManager.activateMicrophone()
            }
        })
        
        MASShortcutMonitor.shared()?.register(micMuteShortcutDeactivate, withAction: {
            if(MuteMicManager.isMuted() == false){
                HUD.showImage(Icons.mute, status: NSLocalizedString("Microphone\nmuted", comment: ""))
                MuteMicManager.deactivateMicrophone()
            }
        })
        
        MASShortcutMonitor.shared()?.register(disableWlanShortcut, withAction: {
            if(WifiManager.isPowered() == nil){
                return
            } else if(WifiManager.isPowered() == true){
                HUD.showImage(Icons.wlanOff, status: NSLocalizedString("Wi-Fi\ndisabled", comment: ""))
                WifiManager.disableWifi()
            } else {
                HUD.showImage(Icons.wlanOn, status: NSLocalizedString("Wi-Fi\nenabled", comment: ""))
                WifiManager.enableWifi()
            }
        })
        
        MASShortcutMonitor.shared()?.register(mirroringMonitorShortcut, withAction: {
            if(DisplayManager.getDisplayCount() > 1){
                if(DisplayManager.isDisplayMirrored() == true){
                    DispatchQueue.background(background: {
                        DisplayManager.disableHardwareMirroring()
                    }, completion:{
                        HUD.showImage(Icons.extending, status: NSLocalizedString("Screen\nextending", comment: ""))
                    })
                } else {
                    DispatchQueue.background(background: {
                        DisplayManager.enableHardwareMirroring()
                    }, completion:{
                        HUD.showImage(Icons.mirroring, status: NSLocalizedString("Screen\nmirroring", comment: ""))
                    })
                }
            }
        })
        
    }
    
    static func unregister() {
        MASShortcutMonitor.shared().unregisterShortcut(systemPrefsShortcut)
    }
    
    private static func startApp(withBundleIdentifier: String){
        
        let focusedApp = NSWorkspace.shared.frontmostApplication?.bundleIdentifier
        
        if(withBundleIdentifier == focusedApp){
            NSRunningApplication.runningApplications(withBundleIdentifier: focusedApp!).first?.hide()
        } else {
            NSWorkspace.shared.launchApplication(withBundleIdentifier: withBundleIdentifier, options: NSWorkspace.LaunchOptions.default, additionalEventParamDescriptor: nil, launchIdentifier: nil)
        }
    }
}
