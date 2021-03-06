//
//  JoystickHelper.swift
//  LiveFlight
//
//  Created by Cameron Carmichael Alonso on 29/12/2015.
//  Copyright © 2015 Cameron Carmichael Alonso. All rights reserved.
//

import Cocoa

class JoystickConfig {
    var joystickConnected:Bool = false
    var connectedJoystickName:String = ""
    init(connected:Bool, name:String) {
        self.joystickConnected = connected
        self.connectedJoystickName = name
    }
}

var joystickConfig = JoystickConfig(connected: false, name: "")

class JoystickHelper: NSObject, JoystickNotificationDelegate {

    let connector = InfiniteFlightAPIConnector()
    let controls = FlightControls()
    
    //joystick values
    var rollValue = 0;
    var pitchValue = 0;
    var rudderValue = 0;
    var throttleValue = 0;
    
    var tryPitch = false
    var tryRoll = false
    var tryThrottle = false
    var tryRudder = false
    
    override init() {
        super.init()
        
        /*
            Init Joystick Manager
            ========================
        */
        
        let joystick:JoystickManager = JoystickManager.sharedInstance()
        joystick.joystickAddedDelegate = self;
        
        
        /*
            NotificationCenter setup
            ========================
        */
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(JoystickHelper.tryPitch(_:)), name:"tryPitch", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(JoystickHelper.tryRoll(_:)), name:"tryRoll", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(JoystickHelper.tryThrottle(_:)), name:"tryThrottle", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(JoystickHelper.tryRudder(_:)), name:"tryRudder", object: nil)
        

        
    }
    
    func tryPitch(notification: NSNotification) {
        tryPitch = true
    }
    
    func tryRoll(notification: NSNotification) {
        tryRoll = true
    }
    
    func tryThrottle(notification: NSNotification) {
        tryThrottle = true
    }
    
    func tryRudder(notification: NSNotification) {
        tryRudder = true
    }
    
    //joystick work
    func joystickAdded(joystick: Joystick!) {
        joystick.registerForNotications(self)
        
        if NSUserDefaults.standardUserDefaults().integerForKey("lastJoystick") != Int(joystick.productId) {
            // different joystick. Reset
         
            // remove last map
            NSUserDefaults.standardUserDefaults().removeObjectForKey("mapStatus")
            
            // set axesSet to false
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: "axesSet")
            
        }
        
        
        // set last joystick name and connected
        joystickConfig = JoystickConfig(connected: true, name: ("\(joystick.manufacturerName) \(joystick.productName)"))
        
        
        let axesSet = NSUserDefaults.standardUserDefaults().boolForKey("axesSet")
        
        // this is to reset axes when upgrading. Since there is a common pattern, there shouldn't be much impact.
        let axesSet11 = NSUserDefaults.standardUserDefaults().boolForKey("axesSet11")
        
        if axesSet != true || axesSet11 != true {
            // axes haven't been set yet
            
            // check to see if json exists with joystick name
            guard let path = NSBundle.mainBundle().pathForResource("JoystickMapping/\(joystick.manufacturerName) \(joystick.productName)", ofType: "json") else {
                
                // No map found
                NSLog("No map found - setting default values...")
                
                // Default values
                NSUserDefaults.standardUserDefaults().setInteger(49, forKey: "pitch")
                NSUserDefaults.standardUserDefaults().setInteger(48, forKey: "roll")
                NSUserDefaults.standardUserDefaults().setInteger(50, forKey: "throttle")
                NSUserDefaults.standardUserDefaults().setInteger(53, forKey: "rudder")
                
                // using generic values
                NSUserDefaults.standardUserDefaults().setInteger(0, forKey: "mapStatus")
                
                return
            }
            
            // if this point is reached, a map exists
            let fileData = NSData(contentsOfFile: path)
            
            do {
                if let response:NSDictionary = try NSJSONSerialization.JSONObjectWithData(fileData!, options:NSJSONReadingOptions.MutableContainers) as? Dictionary<String, AnyObject> {
                    
                    let pitchAxis = response.valueForKey("Pitch-OSX") as! Int
                    let rollAxis = response.valueForKey("Roll-OSX") as! Int
                    let throttleAxis = response.valueForKey("Throttle-OSX") as! Int
                    let rudderAxis = response.valueForKey("Rudder-OSX") as! Int
                    
                    //save values
                    NSUserDefaults.standardUserDefaults().setInteger(pitchAxis, forKey: "pitch")
                    NSUserDefaults.standardUserDefaults().setInteger(rollAxis, forKey: "roll")
                    NSUserDefaults.standardUserDefaults().setInteger(throttleAxis, forKey: "throttle")
                    NSUserDefaults.standardUserDefaults().setInteger(rudderAxis, forKey: "rudder")
                    
                    // using mapped values
                    NSUserDefaults.standardUserDefaults().setInteger(1, forKey: "mapStatus")
                    
                } else {
                    NSLog("Failed to parse JSON")
                }
            } catch let serializationError as NSError {
                NSLog(String(serializationError))
            }
            
        }
        
        // change labels and mark as axes set
        NSNotificationCenter.defaultCenter().postNotificationName("changeLabelValues", object:nil)
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "axesSet")
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "axesSet11")
        
        NSUserDefaults.standardUserDefaults().setInteger(Int(joystick.productId), forKey: "lastJoystick")
        
    }
    
    func joystickRemoved(joystick: Joystick!) {
        
        joystickConfig = JoystickConfig(connected: false, name: "")
        

        // change label values
        NSNotificationCenter.defaultCenter().postNotificationName("changeLabelValues", object:nil)
        
    }
    
    func joystickStateChanged(joystick: Joystick!, axis:Int32) {
  
        //check to see if calibrating
        if (tryPitch == true) {
            //detect axis then save
            NSUserDefaults.standardUserDefaults().setInteger(Int(axis), forKey: "pitch")
            tryPitch = false
            
            NSNotificationCenter.defaultCenter().postNotificationName("changeLabelValues", object:nil)
            
        } else if (tryRoll == true) {
            //detect axis then save
            NSUserDefaults.standardUserDefaults().setInteger(Int(axis), forKey: "roll")
            tryRoll = false
            
            NSNotificationCenter.defaultCenter().postNotificationName("changeLabelValues", object:nil)
            
        } else if (tryThrottle == true) {
            //detect axis then save
            NSUserDefaults.standardUserDefaults().setInteger(Int(axis), forKey: "throttle")
            tryThrottle = false
            
            NSNotificationCenter.defaultCenter().postNotificationName("changeLabelValues", object:nil)
            
        } else if (tryRudder == true) {
            //detect axis then save
            NSUserDefaults.standardUserDefaults().setInteger(Int(axis), forKey: "rudder")
            tryRudder = false
            
            NSNotificationCenter.defaultCenter().postNotificationName("changeLabelValues", object:nil)
            
        }
        
        
        var value:Int32 = 0
        
        // print relVal - this is useful for debugging
        let relVal = joystick.getRelativeValueOfAxesIndex(axis)
        NSLog("RelVal: \(relVal)")
        
        if NSUserDefaults.standardUserDefaults().boolForKey("gamepadMode") == true {
        
            // is a gamepad
            // values are [-128, 128]
            
             value = Int32(joystick.getRelativeValueOfAxesIndex(axis) * 2048)
            
        } else {
            
            // raw values are [0, 1024]
            value = Int32(((joystick.getRelativeValueOfAxesIndex(axis) * 2) - 1) * 1024)

        }
        
        if (Int(axis) == NSUserDefaults.standardUserDefaults().integerForKey("pitch")) {
            controls.pitchChanged(value)
            
        } else if (Int(axis) == NSUserDefaults.standardUserDefaults().integerForKey("roll")) {
            controls.rollChanged(value)
            
        } else if (Int(axis) == NSUserDefaults.standardUserDefaults().integerForKey("throttle")) {
            controls.throttleChanged(value)
            
        } else if (Int(axis) == NSUserDefaults.standardUserDefaults().integerForKey("rudder")) {
            controls.rudderChanged(value)
            
        }
        
    }
    
    func joystickButtonReleased(buttonIndex: Int32, onJoystick joystick: Joystick!) {
        NSLog("Button --> Released \(buttonIndex)")
        connector.didPressButton(buttonIndex, state: 1)
        
    }
    
    func joystickButtonPushed(buttonIndex: Int32, onJoystick joystick: Joystick!) {
        
        NSLog("Button --> Pressed \(buttonIndex)")
        connector.didPressButton(buttonIndex, state: 0)
    }
    
}
