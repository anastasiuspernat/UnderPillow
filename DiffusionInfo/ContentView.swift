//
//  ContentView.swift
//  DiffusionInfo
//
//  Created by Anastasiy on 11/7/22.
//

import SwiftUI

struct names {
    var id = 0
    var name = ""
}

var demoData = [""]

struct ContentView: View {
    @State var selectKeeper = Set<String>()
    
    var body: some View {
        HStack {
            List(demoData, id: \.self, selection: $selectKeeper){ name in
                Text(name)
            }
                .frame(maxWidth: .infinity)
            VStack {
                Text("Click on the button below to select folders with images")
                    .padding()
                Button(action: {
                                
                    let dialog = NSOpenPanel();
                        
                        dialog.showsResizeIndicator    = true
                        dialog.showsHiddenFiles        = false
                        dialog.canChooseDirectories    = true
                        dialog.canChooseFiles = false
                        dialog.canCreateDirectories    = false
                        dialog.allowsMultipleSelection = false

                        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
                            
                            let connection = NSXPCConnection(serviceName: "Crispy-Driven-Pixels.DiffusionInfoXPC")
                            connection.remoteObjectInterface = NSXPCInterface(with: DiffusionInfoXPCProtocol.self)
                            connection.resume()

                            var service = connection.remoteObjectProxyWithErrorHandler { error in
                                print("Received error:", error)
                            } as? DiffusionInfoXPCProtocol

                            service?.setFolders( ["folderSettings":dialog.url?.path] ) { response in
                                print("Response from XPC service(2):", response)
                            }

                            DistributedNotificationCenter.default().postNotificationName(NSNotification.Name("FoldersChanged"), object: Bundle.main.bundleIdentifier, userInfo: nil, options: [.deliverImmediately])

                        } else {
                            // User clicked on "Cancel"
                            return
                        }
                }, label: {
                    Text("Select folders")
                })
                    .padding()
                Spacer()
                        .frame(height: 40)
                Text("Support, more information:")
                        .font(.system(size: 11))
                Text("Anastasiy Safari")
                        .font(.system(size: 11))
                Link("https://anastasiy.com", destination: URL(string: "https://anastasiy.com")!)
                        .font(.system(size: 11))
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
