//
//  WatchConnector.swift
//  Swing Tracker Watch Watch App
//
//  Created by Daniel Abrams on 6/22/24.
//

import Foundation
import WatchConnectivity
import Combine

class WatchConnector: NSObject, WCSessionDelegate, ObservableObject{
    
    
    @Published var startStop : Bool = false
    var xVals : [Double] = []
    var yVals : [Double] = []
    var zVals : [Double] = []
    var pitch : [Double] = []
    var yaw : [Double] = []
    var roll : [Double] = []
    var rotation : [Double] = []
    
    var session: WCSession
    
    init(session: WCSession = .default){
        self.session = session
        super.init()
        session.delegate = self
        session.activate()
    }
    
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        
        
        // TODO: Turn these statements into a switch statement, if possible
        
        //if received x acceleration values
        if let xVals = message["xVals"] as? [Double]{
            DispatchQueue.main.sync {
                self.xVals = xVals
                
            }
        }
        //if received y acceleration values
        if let yVals = message["yVals"] as? [Double]{
            DispatchQueue.main.sync {
                self.yVals = yVals
            }
        }
        
        //if receieved z acceleration values
        if let zVals = message["zVals"] as? [Double]{
            DispatchQueue.main.sync {
                self.zVals = zVals
            }
        }
        //if received pitch values
        if let pitch = message["pitch"] as? [Double]{
            DispatchQueue.main.sync {
                self.pitch = pitch
            }
        }
        
        //if received yaw values
        if let yaw = message["yaw"] as? [Double]{
            DispatchQueue.main.sync {
                self.yaw = yaw
            }
        }
        
        //if recieved roll values
        if let roll = message["roll"] as? [Double]{
            DispatchQueue.main.sync {
                self.roll = roll
            }
        }
        
        //if receivec rotational rate values
        if let rotation = message["rotation"] as? [Double]{
            
            DispatchQueue.main.sync {
                self.rotation = rotation

            }
        }
        //if received start/stop values
        else if let startStop = message["startStop"] as? Bool{
            DispatchQueue.main.sync {
                self.startStop = startStop
            }
        }
        
        
    }
        
        func getDataArrays() -> [[Double]]{
            return [self.xVals,self.yVals,self.zVals,self.pitch,self.yaw,self.roll, self.rotation]
        }
        
    }


