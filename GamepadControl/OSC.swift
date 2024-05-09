//
//  OSC.swift
//  GamepadControl
//
//  Created by Admin on 2/26/24.
//
import SwiftUI
import OSCKit

class OSC: ObservableObject {
    @ObservedObject var dawState: DawState
    var client: OSCClient
    var server: OSCServer
    var receiver: OSCReceiver

    static let sendPort: UInt16 = 11000
    let host = "localhost"
    
    init(dawStateInit: DawState) {
        dawState = dawStateInit
        client = OSCClient()
        server = OSCServer(port: 11001)
        receiver = OSCReceiver(dawStateInit)
    }
    
    func send(
        _ address: OSCAddressPattern,
        _ values: [AnyOSCValue] = [],
        port: UInt16 = sendPort
    ) {
        let message = OSCMessage(address, values: values)
        try? client.send(message, to: host, port: port)
        print("Sending OSC \(message)")
    }
    
    func startServer() {
        server.setHandler { message, timeTag in
            do {
                try self.receiver.handle(
                    message: message,
                    timeTag: timeTag
                )
            } catch {
                print("Error handling messages: \(error)")
            }
        }
        
        do {
            try server.start()
        } catch {
            print("Error starting server: \(error)")
        }
    }
    
    func stopServer() {
        server.stop()
    }
}
