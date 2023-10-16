//
//  ContentView.swift
//  SocketConnection
//
//  Created by Anup D'Souza on 16/10/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var socketService = SocketService()
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
            HStack {
                Button("Connect") {
                    socketService.connectToServer()
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                
                Button("Disconnect") {
                    socketService.disconnectFromServer()
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
