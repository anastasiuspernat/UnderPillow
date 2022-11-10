//
//  DiffusionInfoXPCProtocol.h
//  DiffusionInfoXPC
//
//  Created by Anastasiy on 11/8/22.
//


import Foundation

// The protocol that this service will vend as its API. This header file will also need to be visible to the process hosting the service.
@objc public protocol DiffusionInfoXPCProtocol {
    // func upperCaseString(_ string: String, withReply reply: @escaping (String) -> Void)
    
    func getFolders(withReply reply: @escaping (String) -> Void)
    func setFolders(_ folders: String, withReply reply: @escaping (Bool) -> Void)
    func getDiffusionData(withReply filePath:String, reply: @escaping (String) -> Void)
}
        

/*
 To use the service from an application or other process, use NSXPCConnection to establish a connection to the service by doing something like this:

     _connectionToService = [[NSXPCConnection alloc] initWithServiceName:@"Crispy-Driven-Pixels.DiffusionInfoXPC"];
     _connectionToService.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(DiffusionInfoXPCProtocol)];
     [_connectionToService resume];

Once you have a connection to the service, you can use it like this:

     [[_connectionToService remoteObjectProxy] upperCaseString:@"hello" withReply:^(NSString *aString) {
         // We have received a response. Update our text field, but do it on the main thread.
         NSLog(@"Result string was: %@", aString);
     }];

 And, when you are finished with the service, clean up the connection like this:

     [_connectionToService invalidate];
*/
