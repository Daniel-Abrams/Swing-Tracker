//
//  ContentView.swift
//  Swing Tracker
//
//  Created by Daniel Abrams on 6/14/24.
//

import SwiftUI
import SwiftData



struct ContentView: View {
    @Environment(\.modelContext) private var context
    //Create watchConnector
    @ObservedObject var watchConnector = WatchConnector()
    
    //Session active/inactive
    @State private var sessionActive: Bool = false
    
    @State private var iconPulse: CGFloat = 1.1
    
    var body: some View {
        NavigationStack{
            ZStack{
                Color.white
                    .ignoresSafeArea()
                
                VStack {
                    
                    Text("Tap \"Start Session\" on your Apple Watch to begin, then start hitting.")
                        .foregroundStyle(.black)
                        .fontDesign(.rounded)
                        .bold()
                        .padding()
                    
                    Divider()
                        .frame(width: 300)
                        .frame(minHeight: 5)
                        .overlay(.black)
                    
                    if self.sessionActive {
                        Text("Session Active")
                            .foregroundStyle(.black)
                            .opacity(0.5)
                            .font(.title)
                            .bold()
                            .fontDesign(.rounded)
                    }
                    else{
                        Text("Session Inactive. Waiting on Apple Watch...")
                            .foregroundStyle(.black)
                            .opacity(0.5)
                            .font(.title)
                            .bold()
                            .fontDesign(.rounded)
                    }
                    Spacer().frame(height: 20)
                    
                    //pulsing app icon
                    Image(uiImage: UIImage(named: "AppIcon") ?? UIImage())
                        .resizable()
                        .scaledToFit()
                        .opacity(0.2)
                        .scaleEffect(sessionActive ? 1.1 : 1.0)
                        .padding()
                        .animation(sessionActive ? .easeInOut(duration: 1.0).repeatForever(autoreverses: true) : .default, value: sessionActive)
                    
                    Spacer().frame(height: 100)
                }
                
                .onAppear{
                    self.sessionActive = false
                    
                }
                
                .toolbar{
                    ToolbarItem(placement: .navigationBarLeading){
                        Text("Swing Tracker")
                            .font(.title2)
                            .italic()
                            .bold()
                            .fontDesign(.rounded)
                        
                    }
                    ToolbarItem(placement: .navigationBarTrailing){
                        NavigationLink(destination: SessionView()){
                            
                            //menu button
                            Text("My Sessions")
                                .foregroundStyle(.white)
                        }
                        .buttonStyle(.bordered)
                        .tint(.green)
                    }
                }
                .toolbarBackground(Color.indigo, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                
            }
        }
        
        //On receiving a start/stop signal
        .onReceive(watchConnector.$startStop.receive(on: RunLoop.main)){newValue in
            //if received "start"
            if watchConnector.startStop {
                sessionActive = true
            }
            
            else if watchConnector.startStop == false && sessionActive == false{
                
            }
            //if received "stop"
            else{
                //set session to inactive
                sessionActive = false
                
                //retrieve the motion data that was sent
                let dataArrays = watchConnector.getDataArrays()
                
                //create a new session with the motion data
                let newSession = Session(numSwings: 0, sessionLength: 0, xAcceleration: dataArrays[0], yAcceleration: dataArrays[1], zAcceleration: dataArrays[2], pitch: dataArrays[3], yaw: dataArrays[4], roll: dataArrays[5], rotation: dataArrays[6])
                
                //insert session into persistent data
                context.insert(newSession)
                
                //parse out each individual swing from the session
                newSession.classifySwings()
                
                //insert each swing into persistent data
                for i in 0..<newSession.numSwings{
                    context.insert(newSession.swingList[i])
                }
            }
        }
    }
}










#Preview {
    ContentView()
    
}
