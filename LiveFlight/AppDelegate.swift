//
//  AppDelegate.swift
//  LiveFlight
//
//  Created by Cameron Carmichael Alonso on 23/08/15.
//  Copyright (c) 2015 Cameron Carmichael Alonso. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet var gamepadModeButton: NSMenuItem!
    @IBOutlet var logButton: NSMenuItem!
    @IBOutlet var packetSpacingButton: NSMenuItem!
    var optionsWindow: NSWindowController!
    var reachability: Reachability?
    var receiver = UDPReceiver()
    var connector = InfiniteFlightAPIConnector()
    var joystickHelper = JoystickHelper()
    
    func applicationWillFinishLaunching(notification: NSNotification) {
        
        /*
            Load Settings
            ========================
        */

        
        // we always save to app sandbox
        if let dir : NSString = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.LibraryDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first {
            
            let logDir = "\(dir)/Logs"
            NSUserDefaults.standardUserDefaults().setValue(String(logDir), forKey: "logPath")
            
        }
            

        if NSUserDefaults.standardUserDefaults().boolForKey("logging") == true {
            
            //output to file
            let file = "LiveFlight_Connect.log"
            
            if let dir : NSString = NSUserDefaults.standardUserDefaults().valueForKey("logPath") as! String {
                
                NSLog("Logging enabled to directory: %@", dir)
                
                let path = dir.stringByAppendingPathComponent(file);
                
                //remove old file
                do {
                    try NSFileManager.defaultManager().removeItemAtPath(path)
                }
                catch let error as NSError {
                    error.description
                }
                
                freopen(path.cStringUsingEncoding(NSASCIIStringEncoding)!, "a+", stderr)
                
            }
            
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "logging")
            logButton.state = 1
            
        } else {
            
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "logging")
            logButton.state = 0
        }
        
        // set gamepad mode toggle
        if NSUserDefaults.standardUserDefaults().boolForKey("gamepadMode") == true {
            
            gamepadModeButton.state = 1
            
        } else {
            
            gamepadModeButton.state = 0
            
        }
        

        //set delay button appropriately
        let currentDelay = NSUserDefaults.standardUserDefaults().integerForKey("packetDelay")
        let currentDelaySetup = NSUserDefaults.standardUserDefaults().boolForKey("packetDelaySetup")
        
        
        if currentDelaySetup == false {
            //set to 10ms as default
            NSUserDefaults.standardUserDefaults().setInteger(10, forKey: "packetDelay")
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "packetDelaySetup")
            packetSpacingButton.title = "Toggle Delay Between Packets (10ms)"
            
            //set all axes to -2
            NSUserDefaults.standardUserDefaults().setInteger(-2, forKey: "pitch")
            NSUserDefaults.standardUserDefaults().setInteger(-2, forKey: "roll")
            NSUserDefaults.standardUserDefaults().setInteger(-2, forKey: "throttle")
            NSUserDefaults.standardUserDefaults().setInteger(-2, forKey: "rudder")
            
            
        } else {
            packetSpacingButton.title = "Toggle Delay Between Packets (\(currentDelay)ms)"
            
        }
        
        
        logAppInfo()
    }
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        
        /*
            Check Networking Status
            ========================
        */
        
        do {
            reachability =  try Reachability(hostname: "http://www.liveflightapp.com/")
        } catch ReachabilityError.FailedToCreateWithAddress(_) {
            NSLog("Failed to create connection")
            return
        } catch {}
        
        
        
        #if RELEASE
        
            /*
                App Store Release
                ========================
            */
            Release().setupReleaseFrameworks()
            
        #endif


        /*
            Init Networking
            ========================
        */
        
        receiver = UDPReceiver()
        receiver.startUDPListener()

        
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
    
    func logAppInfo() {
        
        let nsObject = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"]
        let bundleVersion = nsObject as! String
        NSLog("LiveFlight Connect version \(bundleVersion)")
        NSLog("OS: \(NSProcessInfo().operatingSystemVersionString)")
        NSLog("AppKit: \(NSAppKitVersionNumber)")
        NSLog("IFAddresses: \(getIFAddresses())")

        NSLog("\n\n")
    }
    
    
    /*
        Menu Settings
        ========================
    */
    
    @IBAction func openJoystickGuide(sender: AnyObject) {
        
        let forumURL = "http://help.liveflightapp.com/"
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: forumURL)!)
        
    }
    
    @IBAction func openTerms(sender: AnyObject) {
        
        let forumURL = "http://help.liveflightapp.com/legal/terms"
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: forumURL)!)
        
    }
    
    @IBAction func openPrivacyPolicy(sender: AnyObject) {
        
        let forumURL = "http://help.liveflightapp.com/legal/privacy"
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: forumURL)!)
        
    }
    
    @IBAction func openGitHub(sender: AnyObject) {
        
        let githubURL = "https://github.com/LiveFlightApp/Connect-OSX"
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: githubURL)!)
        
    }
    
    @IBAction func openForum(sender: AnyObject) {
        
        let forumURL = "https://community.infinite-flight.com/?u=carmalonso"
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: forumURL)!)
        
    }
    
    @IBAction func openLiveFlight(sender: AnyObject) {
        
        let liveFlightURL = "http://www.liveflightapp.com"
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: liveFlightURL)!)
        
    }
    
    @IBAction func openLiveFlightFacebook(sender: AnyObject) {
        
        let liveFlightURL = "http://www.facebook.com/liveflightapp"
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: liveFlightURL)!)
        
    }
    
    @IBAction func openLiveFlightTwitter(sender: AnyObject) {
        
        let liveFlightURL = "http://www.twitter.com/liveflightapp"
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: liveFlightURL)!)
        
    }
    
    @IBAction func toggleGamepadMode(sender: AnyObject) {
        // enable/disable gamepad mode
        
        if gamepadModeButton.state == 0 {
            //enable
            gamepadModeButton.state = 1
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "gamepadMode")
        } else {
            gamepadModeButton.state = 0
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "gamepadMode")
        }
        
    }
    
    @IBAction func toggleLogging(sender: AnyObject) {
        //enable/disable logging
        
        if logButton.state == 0 {
            //enable
            logButton.state = 1
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "logging")
        } else {
            logButton.state = 0
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "logging")
        }
        
    }
    
    @IBAction func togglePacketSpacing(sender: AnyObject) {
        //change delay between sending packets
        //0, 10, 20, 50ms.
        
        let currentDelay = NSUserDefaults.standardUserDefaults().integerForKey("packetDelay")
        
        if currentDelay == 0 {
            //set to 10
            NSUserDefaults.standardUserDefaults().setInteger(10, forKey: "packetDelay")
            packetSpacingButton.title = "Toggle Delay Between Packets (10ms)"
            
        } else if currentDelay == 10 {
            //set to 20
            NSUserDefaults.standardUserDefaults().setInteger(20, forKey: "packetDelay")
            packetSpacingButton.title = "Toggle Delay Between Packets (20ms)"
            
        } else if currentDelay == 20 {
            //set to 50
            NSUserDefaults.standardUserDefaults().setInteger(50, forKey: "packetDelay")
            packetSpacingButton.title = "Toggle Delay Between Packets (50ms)"
            
        } else {
            //set to 0
            NSUserDefaults.standardUserDefaults().setInteger(0, forKey: "packetDelay")
            packetSpacingButton.title = "Toggle Delay Between Packets (0ms)"
            
        }
        
    }
    
    @IBAction func openOptionsWindow(sender: AnyObject) {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        optionsWindow = storyboard.instantiateControllerWithIdentifier("optionsWindow") as! NSWindowController
        
        optionsWindow.showWindow(self)
        
    }
    
    @IBAction func nextCamera(sender: AnyObject) {
        connector.nextCamera()
    }
    
    @IBAction func previousCamera(sender: AnyObject) {
        connector.previousCamera()
    }
    
    @IBAction func cockpitCamera(sender: AnyObject) {
        connector.cockpitCamera()
    }
    
    @IBAction func vcCamera(sender: AnyObject) {
        connector.vcCamera()
    }
    
    @IBAction func followCamera(sender: AnyObject) {
        connector.followCamera()
    }
    
    @IBAction func onBoardCamera(sender: AnyObject) {
        connector.onboardCamera()
    }
    
    @IBAction func flybyCamera(sender: AnyObject) {
        connector.flybyCamera()
    }
    
    @IBAction func towerCamera(sender: AnyObject) {
        connector.towerCamera()
    }
    
    @IBAction func landingGear(sender: AnyObject) {
        connector.landingGear()
    }
    
    @IBAction func spoilers(sender: AnyObject) {
        connector.spoilers()
    }
    
    @IBAction func flapsUp(sender: AnyObject) {
        connector.flapsUp()
    }
    
    @IBAction func flapsDown(sender: AnyObject) {
        connector.flapsDown()
    }
    
    @IBAction func brakes(sender: AnyObject) {
        connector.parkingBrakes()
    }
    
    @IBAction func autopilot(sender: AnyObject) {
        connector.autopilot()
    }
    
    @IBAction func pushback(sender: AnyObject) {
        connector.pushback()
    }
    
    @IBAction func pause(sender: AnyObject) {
        connector.togglePause()
    }
    
    @IBAction func landingLight(sender: AnyObject) {
        connector.landing()
    }
    
    @IBAction func strobeLight(sender: AnyObject) {
        connector.strobe()
    }
    
    @IBAction func beaconLight(sender: AnyObject) {
        connector.beacon()
    }
    
    @IBAction func navLight(sender: AnyObject) {
        connector.nav()
    }
    
    @IBAction func atcMenu(sender: AnyObject) {
        connector.atcMenu()
    }
    
    func getIFAddresses() -> [String] {
        var addresses = [String]()
        
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs> = nil
        if getifaddrs(&ifaddr) == 0 {
            
            // For each interface ...
            for (var ptr = ifaddr; ptr != nil; ptr = ptr.memory.ifa_next) {
                let flags = Int32(ptr.memory.ifa_flags)
                var addr = ptr.memory.ifa_addr.memory
                
                // Check for running IPv4, IPv6 interfaces. Skip the loopback interface.
                if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
                    if addr.sa_family == UInt8(AF_INET) || addr.sa_family == UInt8(AF_INET6) {
                        
                        // Convert interface address to a human readable string:
                        var hostname = [CChar](count: Int(NI_MAXHOST), repeatedValue: 0)
                        if (getnameinfo(&addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count),
                            nil, socklen_t(0), NI_NUMERICHOST) == 0) {
                                if let address = String.fromCString(hostname) {
                                    addresses.append(address)
                                }
                        }
                    }
                }
            }
            freeifaddrs(ifaddr)
        }
        
        return addresses
    }
    
}


class WindowController: NSWindowController {
    
    
    override func windowDidLoad() {
        super.windowDidLoad()
    }
    
}


