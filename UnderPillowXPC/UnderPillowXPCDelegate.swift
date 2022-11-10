//
//  UnderPillowXPC.m
//  UnderPillowXPC
//
//  Created by Anastasiy on 11/8/22.
//

import Foundation

class UnderPillowXPCDelegate: NSObject, NSXPCListenerDelegate {
    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {        
        newConnection.exportedInterface = NSXPCInterface(with: UnderPillowXPCProtocol.self)
        let exportedObject = UnderPillowXPC()
        newConnection.exportedObject = exportedObject
        newConnection.resume()
        return true
    }
}

//
//// This implements the example protocol. Replace the body of this class with the implementation of this service's protocol.
//- (void)upperCaseString:(NSString *)aString withReply:(void (^)(NSString *))reply {
//    NSString *response = [aString uppercaseString];
//    reply(response);
//}

