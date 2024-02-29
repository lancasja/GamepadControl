//
//  OSC.swift
//  GamepadControl
//
//  Created by Admin on 2/26/24.
//
import OSCKit
import Dispatch
import Combine

class OSC: ObservableObject {
    let localIP = "192.168.1.168"
    let sendPort: UInt16 = 11000
    let receivePort: UInt16 = 11001
    
    var client = OSCClient()
    var server: OSCServer?
    
    @Published var lastReceivedMessage: OSCMessage?
    
    func sendMessage(address: String, query: [any OSCValue]) {
        do {
            let message = OSCMessage(address, values: query)
            try client.send(message, to: localIP, port: sendPort)
        } catch let error {
            print("Error sending OSC message: \(error)")
        }
    }
    
    func startServer() {
        self.server = OSCServer(port: receivePort) { message, _ in
            DispatchQueue.main.async {
                self.lastReceivedMessage = message
            }
        }
        
        do {
            try self.server?.start()
            print("Listening on \(localIP):\(receivePort)")
        } catch let error {
            print("Error starting OSC server: \(error)")
        }
    }
}
