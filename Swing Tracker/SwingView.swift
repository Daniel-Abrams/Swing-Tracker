//
//  SwingView.swift
//  Swing Tracker
//
//  Created by Daniel Abrams on 7/15/24.
//

import SwiftUI
import SwiftData
import Charts
import SceneKit
import SceneKit.ModelIO

struct SwingView: View {
   
    //Data points for charts
    struct DataPoint: Identifiable{
        var id = UUID()
        let x: Double
        let y: Double
        let series: String
    }
    //get the designated swing for the view
    let swing: Swing
    @State var accelerationValues: [DataPoint] = []
    @State var contactAngleValues: [DataPoint] = []
    
    var body: some View {
        
        VStack{
            Text(swing.name)
                .font(.title2)
                .bold()
                .padding(.bottom)
            
            
            ScrollView{
                
                Text("(WIP) Estimated Swing Path")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .font(.headline)
                
                
                SceneView(swing: swing)
                    .cornerRadius(20)
                    .padding(.horizontal)
                    .padding(.bottom)
                    .frame(height: 300)
                
                Text("Acceleration (m/s\u{00B2})")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                Chart(accelerationValues){item in
                    LineMark(x: .value("Time", item.x), y: .value("Acceleration", item.y))
                        .foregroundStyle(by: .value("Series", item.series))
                }
                .chartXAxisLabel("Time (s)")
                .frame(height: 300)
                .padding()
                .cornerRadius(5)
                
                Text("(WIP) Estimated Contact Angle: \(Int(swing.contactAngle * 180 / .pi))\u{00b0} (\(swing.faceOreintation))")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                Chart(contactAngleValues){item in
                    LineMark(x: .value("X", item.x), y: .value("Y", item.y))
                        .foregroundStyle(by: .value("Series", item.series))
                        .lineStyle(StrokeStyle(lineWidth: 10, lineCap: .round))
                    
                }
                
                .frame(height: 300)
                .padding()
                .cornerRadius(5)
                
                Text("Racket Head Rotation Rate: \((swing.rotation.max() ?? 0.0) * 180 / .pi) degrees/second (\(swing.spin)) ")
                    .bold()
                    .font(.title2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
            }
            .onAppear(){
                //initialize the charts for acceleration and racket face orientation
                
                for i in 0..<swing.xVals.count{
                    let dataPoint = DataPoint(x: Double(i) * 1.0/100.0, y: swing.xVals[i], series: "X Acceleration")
                    accelerationValues.append(dataPoint)
                }
                
                for i in 0..<swing.yVals.count{
                    let dataPoint = DataPoint(x: Double(i) * 1.0/100.0, y: swing.yVals[i], series: "Y Acceleration")
                    accelerationValues.append(dataPoint)
                    
                }
                
                for i in 0..<swing.zVals.count{
                    let dataPoint = DataPoint(x: Double(i) * 1.0/100.0, y: swing.zVals[i], series: "Z Acceleration")
                    accelerationValues.append(dataPoint)
                    
                    
                }
                
                for i in 2..<10 {
                    let dataPoint = DataPoint(x: Double(i), y: tan(swing.contactAngle) * Double(i) + 1, series: "Racket Head")
                    contactAngleValues.append(dataPoint)
                }
            }
        }
    }
    
}

struct SceneView: UIViewRepresentable{
    
    
    @ObservedObject var swing: Swing
    
    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        sceneView.backgroundColor = UIColor.lightGray
        sceneView.allowsCameraControl = true
        sceneView.autoenablesDefaultLighting = true
        
        let scene = SCNScene()
        sceneView.scene = scene
        
        //get the racket model
        let url = Bundle.main.url(forResource: "racket", withExtension: "obj", subdirectory: "SceneKit Asset Catalog.scnassets")
        let asset = MDLAsset(url: url!)
        guard let object = asset.object(at: 0) as? MDLMesh else
        {return sceneView}
        
        //add racket to scene
        let node = SCNNode(mdlObject: object)
        node.name = "racket"
        node.scale = SCNVector3(0.0001,0.0001,0.0001)
        scene.rootNode.addChildNode(node)
        
        //add XYZ axis to scene
        scene.rootNode.addChildNode(XYZAxisNode())
        
        
        node.position = SCNVector3(0.8,0.3,1)
        node.eulerAngles = SCNVector3(0,swing.yaw[0],swing.roll[0])
       
        //define animation
        var actions : [SCNAction] = []
        
        for i in 0..<swing.xVals.count{
            // TODO: movement animation needs improvement, the movement along some axis may need to be switched to align with the rotation of the racket
            let move = SCNAction.moveBy(x: CGFloat(swing.xVelocity[i] * 1.0/100), y: CGFloat(swing.zVelocity[i] * 5.0/100), z: CGFloat(swing.yVelocity[i] * 10.0/100), duration: 0.05)
            
            //racket head rotation
            let rotate = SCNAction.rotateTo(x: CGFloat(swing.pitch[i]), y: CGFloat(swing.yaw[i]), z: CGFloat(swing.roll[i])  - swing.roll[0]/2, duration: 0.05)
            actions.append(move)
            actions.append(rotate)
            
        }
        actions.append(SCNAction.move(to: SCNVector3(0.8,0.3,1) , duration: 0.1))
        
        //repeat movesequence 
        let moveSequence = SCNAction.sequence(actions)
        let repeatAction = SCNAction.repeatForever(moveSequence)
        node.runAction(repeatAction)
        
        return sceneView
        
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
       
    }
    
    
}


//swing object
@Model
class Swing : Identifiable, ObservableObject{
    
    var session: Session?
    var xVals : [Double]
    var yVals : [Double]
    var zVals : [Double]
    var pitch : [Double]
    var yaw   : [Double]
    var roll  : [Double]
    var rotation : [Double]
    var xVelocity : [Float] = [0.0]
    var yVelocity : [Float] = [0.0]
    var zVelocity : [Float] = [0.0]
    var contactAngle: Double = 0.0
    var faceOreintation: String = ""
    var spin: String = ""

    
    var name: String
    var timeStamp: Date
    
    var xMax: Int = 0
    var maxAcceleration : Double = 0.0
    
    init(session: Session, xVals: [Double], yVals: [Double], zVals: [Double], pitch: [Double], yaw: [Double], roll: [Double], rotation: [Double] , name: String, timeStamp: Date) {
        self.session = session
        self.xVals = xVals
        self.yVals = yVals
        self.zVals = zVals
        self.pitch = pitch
        self.yaw = yaw
        self.roll = roll
        self.rotation = rotation
        self.name = name
        self.timeStamp = timeStamp
        self.contactAngle = roll[(xVals.firstIndex(of: xVals.max() ?? 0.0) ?? 0)]
        
        //Determine if the racket face is closed or open
        if self.contactAngle * 180 / .pi < 90{
            self.faceOreintation = "Closed Face"
        }
        else{
            self.faceOreintation = "Open Face"
        }
        
        //Determine relative spin of the rackeet
        if abs((rotation.max() ?? 0.0) * 180 / .pi) < 100{
            self.spin = "Low Spin"
        }
        else if abs((rotation.max() ?? 0.0) * 180 / .pi) >= 100 && abs((rotation.max() ?? 0.0) * 180 / .pi) < 200 {
            self.spin = "Medium Spin"
        }
        else{
            self.spin = "High Spin"

        }
    
    //Estimate the velocity of the racket at each point in the swing
        for i in 1..<xVals.count{
            xVelocity.append(xVelocity[i-1] + Float(xVals[i] * 1.0/100))
            yVelocity.append(yVelocity[i-1] + Float(yVals[i] * 1.0/100))
            zVelocity.append(zVelocity[i-1] + Float(zVals[i] * 1.0/100))
        }
        
        
    }
    
    func computeMaxAcceleration(){
        self.xMax = xVals.firstIndex(of: xVals.max() ?? 0.0) ?? 0
        self.maxAcceleration = pow(pow(xVals[xMax],2) + pow(yVals[xMax],2) + pow(zVals[xMax],2), 0.5)
    }
    
}


