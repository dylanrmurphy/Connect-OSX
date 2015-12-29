//
//  JoystickHelper.swift
//  LiveFlight
//
//  Created by Cameron Carmichael Alonso on 29/12/2015.
//  Copyright © 2015 Cameron Carmichael Alonso. All rights reserved.
//

import Cocoa

class JoystickHelper: NSObject, JoystickNotificationDelegate {

    let connector = InfiniteFlightAPIConnector()
    
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
    func joystickAdded(joystick: Joystick!, withName name: String!, id: String!) {
        joystick.registerForNotications(self)
        
        let axesSet = NSUserDefaults.standardUserDefaults().boolForKey("axesSet")
        
        if axesSet != true {
            // axes haven't been set yet
            
            // check to see if json exists with joystick name
            guard let path = NSBundle.mainBundle().pathForResource("JoystickMapping/\(name)", ofType: "json") else {
                
                // No map found
                NSLog("No map found - setting default values...")
                
                // Default values
                NSUserDefaults.standardUserDefaults().setInteger(49, forKey: "pitch")
                NSUserDefaults.standardUserDefaults().setInteger(48, forKey: "roll")
                NSUserDefaults.standardUserDefaults().setInteger(50, forKey: "throttle")
                NSUserDefaults.standardUserDefaults().setInteger(53, forKey: "rudder")
                
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
                    
                } else {
                    NSLog("Failed to parse JSON")
                }
            } catch let serializationError as NSError {
                NSLog(String(serializationError))
            }
            
            // change labels and mark as axes set
            NSNotificationCenter.defaultCenter().postNotificationName("changeLabelValues", object:nil)
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "axesSet")
            
        }
        
        
    }
    
    func joystickStateChanged(joystick: Joystick!, axis:Int32) {
        
        NSLog("Axis changed: \(axis)")
        
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
        
        let value:Int = Int(((joystick.getRelativeValueOfAxesIndex(axis) * 2) - 1) * 1024);
        
        if (Int(axis) == NSUserDefaults.standardUserDefaults().integerForKey("pitch")) {
            connector.didMoveAxis(0, value: Int32(value))
            
        } else if (Int(axis) == NSUserDefaults.standardUserDefaults().integerForKey("roll")) {
            connector.didMoveAxis(1, value: Int32(value))
            
        } else if (Int(axis) == NSUserDefaults.standardUserDefaults().integerForKey("throttle")) {
            connector.didMoveAxis(3, value: Int32(value))
            
        } else if (Int(axis) == NSUserDefaults.standardUserDefaults().integerForKey("rudder")) {
            connector.didMoveAxis(2, value: Int32(value))
            
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