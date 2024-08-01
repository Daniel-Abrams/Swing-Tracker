//
//  AccelerometerData.swift
//  Swing Tracker
//
//  Created by Daniel Abrams on 6/14/24.
//

import Foundation
import CoreMotion
import SwiftUI


class MovementTracker {
    let motionManager = CMMotionManager()
    
    var x : [Double] = []
    var y : [Double] = []
    var z : [Double] = []
    var pitch : [Double] = []
    var yaw : [Double] = []
    var roll : [Double] = []
    var rotationRate : [Double] = []
  
  

    func readInstruments(){
       
        //empty the arrays
        self.x = []
        self.y = []
        self.z = []
        self.pitch = []
        self.yaw = []
        self.roll = []
        self.rotationRate = []
        
        //set the update interval of the motion device
        self.motionManager.deviceMotionUpdateInterval = 1.0 / 100.0  // 100 Hz
        
        motionManager.startDeviceMotionUpdates(using: .xArbitraryZVertical, to: .main){motion,error in
            
            //get motion values
            if let motion = motion{
                self.x.append(motion.userAcceleration.x)
                self.y.append(motion.userAcceleration.y)
                self.z.append(motion.userAcceleration.z)
                self.pitch.append( motion.attitude.pitch)
                self.yaw.append(motion.attitude.yaw)
                self.roll.append(motion.attitude.roll)
                self.rotationRate.append(motion.rotationRate.z)
                
            }
        }
        
        
        
    }
}

