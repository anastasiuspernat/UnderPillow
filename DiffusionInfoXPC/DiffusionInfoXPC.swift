//
//  DiffusionInfoXPC.h
//
//  Created by Anastasiy on 11/8/22.
//

import Cocoa
import FinderSync
import ImageIO
import Foundation

// This object implements the protocol which we have defined. It provides the actual behavior for the service. It is 'exported' by the service to make it available to the process hosting the service over an NSXPCConnection.
class DiffusionInfoXPC: NSObject, DiffusionInfoXPCProtocol {
    
    var folders: NSDictionary
    
    override init() {
        self.folders = [:]
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

    func getDiffusionData(withReply filePath:String, reply: @escaping (String) -> Void) {
        
        let diffusionInfo: String = shell("python -c 'import sys; from PIL import Image; image = Image.open(\"\(filePath)\"); textinfo = image.text[\"parameters\"]; print (textinfo);'")
        reply(diffusionInfo)
    }

    
    func getFolders(withReply reply: @escaping (NSDictionary) -> Void) {
            let defaults = UserDefaults.standard

            let defaultsDomain = defaults.persistentDomain(forName: "Crispy-Driven-Pixels.DiffusionInfoXPC") as? [String: AnyHashable] ?? [:]
            let folderSettings =  defaultsDomain["folderSettings"]
            reply(self.folders)
        }
        
        func setFolders(_ folders_dict: NSDictionary, withReply reply: @escaping (Bool) -> Void) {
            let defaults = UserDefaults.standard
            var defaultsDomain = defaults.persistentDomain(forName: "Crispy-Driven-Pixels.DiffusionInfoXPC") as? [String: AnyHashable] ?? [:]
            defaultsDomain["folderSettings"] = folders_dict["folderSettings"] as! URL
        }
        
}

