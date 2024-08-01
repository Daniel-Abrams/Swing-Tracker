//
//  WatchToIOSConnector.swift
//  Swing Tracker
//
//  Created by Daniel Abrams on 6/22/24.
//

import Foundation
import WatchConnectivity

class WatchToIOSConnector: NSObject, WCSessionDelegate, ObservableObject{
   
    
    
    var session: WCSession
    
    init(session: WCSession = .default){
        self.session = session
        super.init()
        session.delegate = self
        session.activate()
    }
    
    
   
    //Function for sending motion values
    func sendAccelerationData(xVals: [Double],yVals: [Double],zVals: [Double],pitch: [Double],yaw: [Double],roll: [Double],rotation: [Double]){
      
        if session.isReachable{
            
            //send all the motion values
            let data : [String: Any] = [
                "xVals": xVals,
                "yVals": yVals,
                "zVals": zVals,
                "pitch": pitch,
                "yaw": yaw,
                "roll": roll,
                "rotation": rotation
            ]
            session.sendMessage(data, replyHandler: nil)
           
        }
        else{
            print("Session Unreachable")
        }
    }
    
    //Function for sending the start/stop signal to the Iphone
    func sendStartStop(startStop: Bool){
        if session.isReachable{
            let data : [String: Any] = [
                "startStop": startStop
            ]
            session.sendMessage(data, replyHandler: nil)
        }
        else{
            print("Session Unreachable")
        }
    }
    
    //Not necessary
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
      
    }
}
