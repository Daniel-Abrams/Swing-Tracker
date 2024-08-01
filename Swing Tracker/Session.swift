//
//  Session.swift
//  Swing Tracker
//
//  Created by Daniel Abrams on 6/27/24.
//

import Foundation
import SwiftData
import SwiftUI

@Model
class Session: Identifiable, ObservableObject{
    
    var numSwings: Int
    var sessionLength: Double
    var xAcceleration: [Double]
    var yAcceleration: [Double]
    var zAcceleration: [Double]
    var pitch: [Double]
    var yaw: [Double]
    var roll: [Double]
    var rotation: [Double]
    @Relationship(deleteRule: .cascade, inverse: \Swing.session) var swingList: [Swing]
    
    
    var date : Date
    
    init(numSwings: Int, sessionLength: Double, xAcceleration: [Double], yAcceleration: [Double], zAcceleration: [Double], pitch: [Double], yaw: [Double], roll: [Double], rotation: [Double]) {
        
        
        self.numSwings = numSwings
        self.sessionLength = sessionLength
        self.xAcceleration = xAcceleration
        self.yAcceleration = yAcceleration
        self.zAcceleration = zAcceleration
        self.pitch = pitch
        self.yaw = yaw
        self.roll = roll
        self.rotation = rotation
        self.date = Date()
        swingList = []
    }
    
    //Parses out individual swings from a session
    
    func classifySwings() {
        var i = 0
        
        //iterate through the motion values
        while i < self.xAcceleration.count {
            //set a temporary variable
            var j = i
            
            //detect when the acceleration on the x axis exceeds 3.0 m/s^2. We use the x axis values because they are the most sensitive to a swing motion.
            
            //keep increasing temp varaible while the next motion value is greater than 3.0
            while abs(self.xAcceleration[j]) > 3.0 && j < self.xAcceleration.count-1 {
                j += 1
               
                //once the motion value drops below 3.0, enter the next loop, so we are nearing the "end" portion of a swing. Continue increasing temp variable
                while abs(self.xAcceleration[j]) < 1.0 && j < self.xAcceleration.count-1 {
                    j += 1
                    
                    //when the acceleration becomes "negative", the swing is slows don, marking the end of the swing. Continue increasing the temp variable for the last time.
                    while abs(self.xAcceleration[j]) > 1.0 && j < self.xAcceleration.count-1 {
                        j += 1
                    }
                }
            }
            
            // The difference between the temp varaible and i will determine whether the motion was a "blip" or an actual swing that needs to be recorded.
            if j - i > 10{
                
                //manually reset the X and Y reference fram, which will allow for a more accurate 3D rendering of the swings
                for k in i..<j{
                    self.pitch[k] -= self.pitch[i]
                    self.yaw[k] -= self.yaw[i]
                }
                
                //increment the number of swings in the session
                self.numSwings += 1
                
                //create a new swing object
                let newSwing = Swing(
                    
                    session: self,
                    
                    xVals:   Array(self.xAcceleration[i..<min(self.xAcceleration.count,j)]),
                    
                    yVals:   Array(self.yAcceleration[i..<min(self.xAcceleration.count,j)]),
                    
                    zVals:   Array(self.zAcceleration[i..<min(self.xAcceleration.count,j)]),
                    
                    pitch:   Array(self.pitch[i..<min(self.xAcceleration.count,j)]),
                    
                    yaw:   Array(self.yaw[i..<min(self.xAcceleration.count,j)]),
                    
                    roll:   Array(self.roll[i..<min(self.xAcceleration.count,j)]),
                    
                    rotation:   Array(self.rotation[i..<min(self.xAcceleration.count,j)]),
                    
                    name: ("Swing " + self.numSwings.description),
                    
                    timeStamp: Date()
                )
                //add the new swing to the session's list of swings
                swingList.append(newSwing)
                
            }
            //for the next iteration of the outer loop, skip over the values that we just classified as a swing.
            i = j + 1
        }
    }
}

