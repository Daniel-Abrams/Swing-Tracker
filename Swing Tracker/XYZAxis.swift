//
//  XYZAxis.swift
//  Swing Tracker
//
//  Created by Daniel Abrams on 8/1/24.
//

import Foundation
import SceneKit

//node class for xyz axis
class XYZAxisNode : SCNNode{
    
    override init(){
        super.init()
        createAxis()
    }
    
    required init(coder: NSCoder){
        super.init()
        createAxis()
    }
    
    func createAxis(){
        
        let axisLength: Float = 1.25
        
        // X axis
        let xAxis = SCNNode(geometry: SCNCylinder(radius: 0.015, height: CGFloat(axisLength)))
        xAxis.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        xAxis.position = SCNVector3(axisLength / 2,0,0)
        xAxis.eulerAngles = SCNVector3(0,0,Float.pi / 2)
        addChildNode(xAxis)
        
        // y axis
        let yAxis = SCNNode(geometry: SCNCylinder(radius: 0.015, height: CGFloat(axisLength)))
        yAxis.geometry?.firstMaterial?.diffuse.contents = UIColor.green
        yAxis.position = SCNVector3(0,axisLength / 2,0)
        addChildNode(yAxis)
        
        // z axis
        let zAxis = SCNNode(geometry: SCNCylinder(radius: 0.015, height: CGFloat(axisLength)))
        zAxis.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        zAxis.position = SCNVector3(0,0,axisLength / 2)
        zAxis.eulerAngles = SCNVector3(Float.pi / 2,0,0)
        addChildNode(zAxis)
    }
    
    
}
