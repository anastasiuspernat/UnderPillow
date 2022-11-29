//
//  UnderPillowXPC.h
//
//  Created by Anastasiy on 11/8/22.
//

import Cocoa
import FinderSync
import ImageIO
import Foundation

// This object implements the protocol which we have defined. It provides the actual behavior for the service. It is 'exported' by the service to make it available to the process hosting the service over an NSXPCConnection.
class UnderPillowXPC: NSObject, UnderPillowXPCProtocol {
    
    static let keyFolderSettings = "folderSettings"
    static let NotificationFoldersChanged = "FoldersChanged"
    static let myServiceName = "Crispy-Driven-Pixels.UnderPillowXPC"

    override init() {
        super.init()
    }

    func shell(_ command: String) -> String {
        let task = Process()
        let pipe = Pipe()
        
        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["-c", command]
        task.launchPath = "/bin/sh"
        task.standardInput = nil
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)!
        
        return output
    }
    
    static func getService() -> UnderPillowXPCProtocol
    {
        let connection = NSXPCConnection(serviceName: UnderPillowXPC.myServiceName)
        connection.remoteObjectInterface = NSXPCInterface(with: UnderPillowXPCProtocol.self)
        connection.resume()

        let service = connection.remoteObjectProxyWithErrorHandler { error in
            print("Received error:", error)
        } as? UnderPillowXPCProtocol
        
        return service!
    }

    func getDiffusionData(withReply filePath:String, reply: @escaping (String) -> Void) {
        
        // TODO: replace with this when it's working
//        var UnderPillow: String = ""
//        if let imageSource = CGImageSourceCreateWithURL(URL(string: filePath)! as CFURL, nil) {
//            guard let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) else {
//                return reply("")
//            }
//            if let dict = imageProperties as? [AnyHashable: Any] {
//                    for (_, value) in dict {
//                        UnderPillow += value as! String
//                    }
//            } else
//            {
//            }
//        } else
//        {
//        }

        let UnderPillow: String = shell("python -c 'import sys; from PIL import Image; image = Image.open(\"\(filePath)\"); textinfo = image.text[\"parameters\"] if \"parameters\" in image.text else image.text[\"Dream\"]; print (textinfo);'")
        reply(UnderPillow)
    }

    
    func getFolders(withReply reply: @escaping (String) -> Void) {
        let defaults = UserDefaults.standard
        let folderSettings = [UnderPillowXPC.keyFolderSettings:defaults.object(forKey: UnderPillowXPC.keyFolderSettings)]

        if let theJSONData = try? JSONSerialization.data(
            withJSONObject: folderSettings,
            options: []) {
                let theJSONText = String(data: theJSONData,
                                       encoding: .utf8)
            reply(theJSONText!)
        } else
        {
            reply("{}")
        }
        
    }
        
    func setFolders(_ folders_dictJSON: String, withReply reply: @escaping (Bool) -> Void) {
        
        if let data = folders_dictJSON.data(using: .utf8) {
                if let folders_dict: NSDictionary = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary ?? [:] {
                    let userDefaults = UserDefaults.standard
                    userDefaults.set(folders_dict[UnderPillowXPC.keyFolderSettings], forKey:UnderPillowXPC.keyFolderSettings)
                }
            }
    }
        
}

