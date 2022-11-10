//
//  FinderSync.swift
//  DiffusionInfo Finder
//
//  Created by Anastasiy on 11/7/22.
//

import Cocoa
import FinderSync
import ImageIO
import Foundation

class FinderSync: FIFinderSync {
                    
    var currentFile: URL?

    override init() {
        super.init()
        
        FIFinderSyncController.default().directoryURLs = []

        let connection = NSXPCConnection(serviceName: "Crispy-Driven-Pixels.DiffusionInfoXPC")
        connection.remoteObjectInterface = NSXPCInterface(with: DiffusionInfoXPCProtocol.self)
        connection.resume()
        let service = connection.remoteObjectProxyWithErrorHandler { error in
            NSLog("Received error: \(error)")
        } as? DiffusionInfoXPCProtocol

        service?.getFolders() { response in
            
            if let data = response.data(using: .utf8) {
                    if let dict: NSDictionary = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary ?? [:] {
                        var folderUrls: [URL] = []
                        let folderPaths: [String] = dict["folderSettings"] as? [String] ?? []
                        for folderStr in folderPaths
                        {
                            folderUrls.append(URL(fileURLWithPath:folderStr))
                        }
                        FIFinderSyncController.default().directoryURLs = Set(folderUrls)
                    }
                }
        }

        // Set up images for our badge identifiers. For demonstration purposes, this uses off-the-shelf images.
        FIFinderSyncController.default().setBadgeImage(NSImage(named: NSImage.colorPanelName)!, label: "Status One" , forBadgeIdentifier: "One")
        FIFinderSyncController.default().setBadgeImage(NSImage(named: NSImage.cautionName)!, label: "Status Two", forBadgeIdentifier: "Two")

        DistributedNotificationCenter.default().addObserver(self, selector: #selector(self.foldersChanged(_:)), name: NSNotification.Name("FoldersChanged"), object: nil)
    }
    
    deinit {
            DistributedNotificationCenter.default().removeObserver(self, name: NSNotification.Name("FoldersChanged"), object: nil)
    }
    
    @objc func foldersChanged(_ notification: Notification ) {

        let folderSettingsJSON: String = notification.object as! String
        
        if let data = folderSettingsJSON.data(using: .utf8) {
                if let foldersSettings: NSDictionary = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary ?? [:] {
                    // TODO: Refresh folderURLs
                }
            }
    }
    
    
    override func beginObservingDirectory(at url: URL) {
        // The user is now seeing the container's contents.
        // If they see it in more than one view at a time, we're only told once.
//        NSLog("beginObservingDirectoryAtURL: %@", url.path as NSString)
    }
    
    
    override func endObservingDirectory(at url: URL) {
        // The user is no longer seeing the container's contents.
//        NSLog("endObservingDirectoryAtURL: %@", url.path as NSString)
    }
    
    override func requestBadgeIdentifier(for url: URL) {
//        NSLog("requestBadgeIdentifierForURL: %@", url.path as NSString)
        
        // For demonstration purposes, this picks one of our two badges, or no badge at all, based on the filename.
//        let whichBadge = abs(url.path.hash) % 3
//        let badgeIdentifier = ["", "One", "Two"][whichBadge]
//        FIFinderSyncController.default().setBadgeIdentifier(badgeIdentifier, for: url)
    }
    
    // MARK: - Menu and toolbar item support
    
    override var toolbarItemName: String {
        return "DiffusionInfo"
    }
    
    override var toolbarItemToolTip: String {
        return "DiffusionInfo: Click the toolbar item for a menu."
    }
    
    override var toolbarItemImage: NSImage {
        return NSImage(named: NSImage.cautionName)!
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
    
    // Note that this also can produce menu items for Finder toolbar
    override func menu(for menuKind: FIMenuKind) -> NSMenu? {
        // Produce a menu for the extension.

        guard menuKind == .contextualMenuForItems else {
                    return nil
        }
        
        guard let items = FIFinderSyncController.default().selectedItemURLs(), items.count == 1, let item = items.first, let uti = try? item.resourceValues(forKeys: [.typeIdentifierKey]).typeIdentifier else {
            currentFile = nil
            return nil
        }

        currentFile = item
        let menu = NSMenu(title: "")

        let connection = NSXPCConnection(serviceName: "Crispy-Driven-Pixels.DiffusionInfoXPC")
        connection.remoteObjectInterface = NSXPCInterface(with: DiffusionInfoXPCProtocol.self)
        connection.resume()
        let service = connection.remoteObjectProxyWithErrorHandler { error in
            NSLog("Received error: \(error)")
        } as? DiffusionInfoXPCProtocol
        
        var diffusionInfo = ""
        
        let sem = DispatchSemaphore(value: 0)

        service?.getDiffusionData(withReply: item.path) { response in
            defer {
                sem.signal()
            }
            diffusionInfo = response
        }
        if !Thread.isMainThread {
            let _ = sem.wait(timeout: .distantFuture)
        } else {
            while sem.wait(timeout: .now()) == .timedOut {
                RunLoop.current.run(mode: .default, before: Date(timeIntervalSinceNow: 0))
            }
        }
        

        // This won't work
//        if let imageSource = CGImageSourceCreateWithURL(item as CFURL, nil) {
//            guard let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) else {
//                return nil
//            }
//            if let dict = imageProperties as? [AnyHashable: Any] {
//                    for (key, value) in dict {
//                        diffusionInfo += value as! String
//                    }
//            } else
//            {
//            }
//        } else
//        {
//        }
        if (UTTypeConformsTo(uti as CFString, kUTTypeImage)) {
            menu.addItem(withTitle: "Diffusion Info", action: #selector(sampleAction(_:)), keyEquivalent: "")
            let lines = diffusionInfo.split(whereSeparator: \.isNewline)
            for line in lines {
                menu.addItem(withTitle: String(line), action: #selector(sampleAction(_:)), keyEquivalent: "")
            }
        }
        
        return menu
    }
    
    @IBAction func sampleAction(_ sender: AnyObject?) {
        let target = FIFinderSyncController.default().targetedURL()
        let items = FIFinderSyncController.default().selectedItemURLs()
        
        let item = sender as! NSMenuItem
        NSLog("sampleAction: menu item: %@, target = %@, items = ", item.title as NSString, target!.path as NSString)
        for obj in items! {
            NSLog("    %@", obj.path as NSString)
        }
    }

}

