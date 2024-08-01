//
//  ContentView.swift
//  Swing Tracker Watch Watch App
//
//  Created by Daniel Abrams on 6/21/24.
//
//
//  ContentView.swift
//  Swing Tracker
//
//  Created by Daniel Abrams on 6/14/24.
//

import SwiftUI
import WatchKit

struct ContentView: View {
    
   @State var extendedSession : WKExtendedRuntimeSession = WKExtendedRuntimeSession()
   var delegate = WKDelegate()
    
    //create motionManager object
    private var movementTracker = MovementTracker()
    
    //create watch connector object
    @StateObject var watchConnector = WatchToIOSConnector()

    //session is Running?
    @State var sessionRunning = false
    
    let queue = OperationQueue()
    
    
    var body: some View {
        ZStack{
            Color.white
                .ignoresSafeArea()
            
            Image(uiImage: UIImage(named: "AppIcon") ?? UIImage())
                .resizable()
                .scaledToFit()
                .opacity(0.2)
               
            
            VStack {
                
                if self.sessionRunning {
                    Text("Session Running...")
                        .foregroundStyle(.black)
                        .opacity(0.5)
                        .padding()
                        
                }
                else{
                    Text("Session Inactive")
                        .foregroundStyle(.black)
                        .opacity(0.5)
                        .padding()
                      
                }
                Button("Start Session"){
                  startDiagnostic()
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .padding()
                
                Button("Stop Session"){
                  stopDiagnostic()
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .padding()
            }
            
        }
        .ignoresSafeArea()
        
    }
    
    
    func startDiagnostic(){
        //is session already running?
        if sessionRunning == false {
            //start an extended runtimesession
            extendedSession = WKExtendedRuntimeSession()
            extendedSession.start()
            
            //session is running, let IPhone know the session is active
            self.sessionRunning = true
            watchConnector.sendStartStop(startStop: true)
            
            //get motion updates
            movementTracker.readInstruments()
            
        }
    }
    
    func stopDiagnostic(){
        
        //is session running?
        if sessionRunning == true {
        
            //retrieve the motion values from the motion device
            let XYZGyro = [movementTracker.x,movementTracker.y,movementTracker.z,movementTracker.pitch,movementTracker.yaw,movementTracker.roll,movementTracker.rotationRate]
            
            //send motion values from the Apple Watch to the IPhone
            watchConnector.sendAccelerationData(xVals: XYZGyro[0],yVals: XYZGyro[1],zVals: XYZGyro[2],pitch: XYZGyro[3],yaw: XYZGyro[4],roll: XYZGyro[5],rotation: XYZGyro[6])
            
            //session is stopped, let the IPhone know that the session is inactive
            self.sessionRunning = false
            watchConnector.sendStartStop(startStop: false)
            
            //Stop the extended session and discontinue motion updates
            extendedSession.invalidate()
            movementTracker.motionManager.stopDeviceMotionUpdates()
        }
    }
}
//no additions needed
class WKDelegate: NSObject, WKExtendedRuntimeSessionDelegate{
    func extendedRuntimeSession(_ extendedRuntimeSession: WKExtendedRuntimeSession, didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason, error: Error?) {
        }
    
    func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        
    }
    
    func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
    
    }
    
    
}

#Preview {
    ContentView()
    
}

