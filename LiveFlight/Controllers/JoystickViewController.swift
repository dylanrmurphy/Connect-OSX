//
//  JoystickViewController.swift
//  LiveFlight
//
//  Created by Cameron Carmichael Alonso on 11/10/15.
//  Copyright © 2015 Cameron Carmichael Alonso. All rights reserved.
//

import Cocoa

class JoystickViewController: NSViewController {
    
    @IBOutlet weak var pitchLabel: NSTextField!
    @IBOutlet weak var rollLabel: NSTextField!
    @IBOutlet weak var throttleLabel: NSTextField!
    @IBOutlet weak var rudderLabel: NSTextField!
    @IBOutlet weak var joystickName: NSTextField!
    @IBOutlet weak var joystickRecognised: NSTextField!
    @IBOutlet var allClearView: Status!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(JoystickViewController.changeLabelValues(_:)), name:"changeLabelValues", object: nil)
        
        //this is a hack, to avoid having to create a new NSNotification object
        NSNotificationCenter.defaultCenter().postNotificationName("changeLabelValues", object:nil)
        
    }
    
    func changeLabelValues(notification:NSNotification) {
        
        allClearView!.hidden = true
        
        let pitch = NSUserDefaults.standardUserDefaults().integerForKey("pitch")
        let roll = NSUserDefaults.standardUserDefaults().integerForKey("roll")
        let throttle = NSUserDefaults.standardUserDefaults().integerForKey("throttle")
        let rudder = NSUserDefaults.standardUserDefaults().integerForKey("rudder")
        
        if pitch != -2 {
            pitchLabel.stringValue = "Axis \(String(pitch))"
        }
        
        if roll != -2 {
            rollLabel.stringValue = "Axis \(String(roll))"
        }
        
        if throttle != -2 {
            throttleLabel.stringValue = "Axis \(String(throttle))"
        }
        
        if rudder != -2 {
            rudderLabel.stringValue = "Axis \(String(rudder))"
        }
        

        if joystickConfig.joystickConnected == true {
            
            // remove duplicate words from name
            // some manufacturers include name in product name too
            var joystickNameArray = joystickConfig.connectedJoystickName.characters.split{$0 == " "}.map(String.init)
            
            var filter = Dictionary<String,Int>()
            var len = joystickNameArray.count
            for var index = 0; index < len  ;index += 1 {
                let value = joystickNameArray[index]
                if (filter[value] != nil) {
                    joystickNameArray.removeAtIndex(index--)
                    len -= 1
                }else{
                    filter[value] = 1
                }
            }
            
            joystickName.stringValue = joystickNameArray.joinWithSeparator(" ")
            
            let mapStatus = NSUserDefaults.standardUserDefaults().integerForKey("mapStatus")
            
            if mapStatus == -2 {
                joystickRecognised.stringValue = "Using custom-assigned values for axes."
                
                
            } else if mapStatus == 0 {
                joystickRecognised.stringValue = "Using generic joystick values. These may not work correctly."
                
            } else if mapStatus == 1 {
                joystickRecognised.stringValue = "Using accurate values for your joystick (provided by LiveFlight)."
                
                allClearView!.hidden = false
                
            } else {
                joystickRecognised.stringValue = "Using generic joystick values. These may not work correctly."
                
            }
            
            
        } else {
            joystickName.stringValue = "No joystick connected"
            joystickRecognised.stringValue = "Plug a joystick in via USB to get started."
        }
    }
    
    /*
        Actions for setting axes
        ========================
    */
    
    @IBAction func pitch(sender: AnyObject) {
        
        NSNotificationCenter.defaultCenter().postNotificationName("tryPitch", object: nil)
        pitchLabel.stringValue = "Move the stick forwards and backwards"
        
        NSUserDefaults.standardUserDefaults().setInteger(-2, forKey: "mapStatus")
        
    }
    
    @IBAction func roll(sender: AnyObject) {
        
        NSNotificationCenter.defaultCenter().postNotificationName("tryRoll", object: nil)
        rollLabel.stringValue = "Move the stick from side to side"
        
        NSUserDefaults.standardUserDefaults().setInteger(-2, forKey: "mapStatus")
        
    }
    
    @IBAction func throttle(sender: AnyObject) {
        
        NSNotificationCenter.defaultCenter().postNotificationName("tryThrottle", object: nil)
        throttleLabel.stringValue = "Move the lever forwards and backwards"
        
        NSUserDefaults.standardUserDefaults().setInteger(-2, forKey: "mapStatus")
        
    }
    
    @IBAction func rudder(sender: AnyObject) {
        
        NSNotificationCenter.defaultCenter().postNotificationName("tryRudder", object: nil)
        rudderLabel.stringValue = "Twist/move the rudder"
        
        NSUserDefaults.standardUserDefaults().setInteger(-2, forKey: "mapStatus")
        
    }
    
    /*
        Actions for clearing saved axes
        ========================
    */
    
    @IBAction func clear(sender: AnyObject) {
        
        // remove saved axes
        NSUserDefaults.standardUserDefaults().setInteger(-2, forKey: "pitch")
        NSUserDefaults.standardUserDefaults().setInteger(-2, forKey: "roll")
        NSUserDefaults.standardUserDefaults().setInteger(-2, forKey: "throttle")
        NSUserDefaults.standardUserDefaults().setInteger(-2, forKey: "rudder")
        NSUserDefaults.standardUserDefaults().setInteger(-2, forKey: "mapStatus")
        
        // update labels
        pitchLabel.stringValue = "No axis assigned"
        rollLabel.stringValue = "No axis assigned"
        throttleLabel.stringValue = "No axis assigned"
        rudderLabel.stringValue = "No axis assigned"
        
    }
    
    
}
