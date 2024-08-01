//
//  SwiftUIView.swift
//  Swing Tracker
//
//  Created by Daniel Abrams on 6/26/24.
//
import Foundation
import SwiftUI
import SwiftData

struct SessionView: View {
    @Environment(\.modelContext) private var context
    
    //retrieve the sessions and swings from persistent data
    @Query private var sessions: [Session]
    @Query private var swings: [Swing]
    
    
    var body: some View {
        NavigationView{
            ZStack{
                Color.indigo
                    .ignoresSafeArea()
                VStack{
                    Text("My Sessions")
                        .bold()
                        .font(.title3)
                    
                    List {
                        //list the sessions
                        ForEach (sessions) { Session in
                            
                            DisclosureGroup{
                                //for each session, list the swings in order
                                ForEach (Session.swingList.sorted(by: {$0.timeStamp < $1.timeStamp}) ){Swing in
                                    
                                    NavigationLink(destination: SwingView(swing: Swing)){
                                        Text(Swing.name)
                                            .foregroundStyle(.white)
                                    }
                                }
                                
                            }
                            label : {
                                //delete session button
                                Button(action: {
                                    context.delete(Session)
                                }){
                                    Image(systemName: "trash")
                                }
                                .buttonStyle(.borderless)
                                .foregroundStyle(.red)
                                .padding(.trailing)
                                
                                Text(Session.date.formatted().description)
                                    .bold()
                                    .font(.headline)
                                
                                
                            }
                            
                            
                        }
                    }
                    
                }
            }
            
        }
        .scrollContentBackground(.hidden)
        .background(Color.indigo)
    }
}







#Preview {
    SessionView()
}
