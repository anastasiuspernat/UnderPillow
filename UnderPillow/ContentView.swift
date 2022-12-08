//
//  ContentView.swift
//  UnderPillow
//
//  Created by Anastasiy on 11/7/22.
//

import SwiftUI
import FinderSync

struct names {
    var id = 0
    var name = ""
}

@MainActor public class ListViewModel: ObservableObject {
  @Published var items: [String] = []
  @State var selectKeeper = Set<String>()
}

struct ContentView: View {
    @State var removeButtonDisabled = false
    @ObservedObject var viewModel = ListViewModel()

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                List(viewModel.items, id: \.self, selection: $viewModel.selectKeeper){ name in
                    Text(name)
                }
                    .onAppear{
                        
                        let service = UnderPillowXPC.getService()

                        var folderPaths: [String] = []
                        
                        let sem = DispatchSemaphore(value: 0)

                        service.getFolders() { response in
                            defer {
                                sem.signal()
                            }
                            if let data = response.data(using: .utf8) {
                                    if let dict: NSDictionary = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary ?? [:] {
                                        folderPaths = dict[UnderPillowXPC.keyFolderSettings] as? [String] ?? []
                                    }
                            }
                        }

                        if !Thread.isMainThread {
                            let _ = sem.wait(timeout: .distantFuture)
                        } else {
                            while sem.wait(timeout: .now()) == .timedOut {
                                RunLoop.current.run(mode: .default, before: Date(timeIntervalSinceNow: 0))
                            }
                        }
                        
                        viewModel.items = []
                        for folderPath in folderPaths {
                            viewModel.items.append(folderPath)
                        }
                } // List
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 5)
                Button(action: {
                    viewModel.selectKeeper.forEach { item in
                        viewModel.items.removeAll(where: { $0 == item })
                            }
                }, label: {
                    Text("Remove")
                })
                    .disabled(removeButtonDisabled)
            } // VStack
                .padding(.bottom, 10)
                .padding(.leading, 10)
                .frame(alignment: .leading)
            VStack {
                Text("Click on the button below to select folders with images")
                    .padding(.leading, 10)
                    .padding(.trailing, 10)
                Button(action: {
                                
                    let dialog = NSOpenPanel();
                        
                        dialog.showsResizeIndicator    = true
                        dialog.showsHiddenFiles        = false
                        dialog.canChooseDirectories    = true
                        dialog.canChooseFiles = false
                        dialog.canCreateDirectories    = false
                        dialog.allowsMultipleSelection = false

                        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
                            
                            let newPath = dialog.url?.path;
                            
                            if (viewModel.items.firstIndex(where: {$0 == newPath}) == nil) {
                                
                                viewModel.items.append(newPath!)
                                    
                                let service = UnderPillowXPC.getService()

                                let foldersStringsDict: NSMutableDictionary = [UnderPillowXPC.keyFolderSettings:viewModel.items]
                                
                                if let theJSONData = try? JSONSerialization.data(
                                    withJSONObject: foldersStringsDict,
                                    options: []) {

                                        let theJSONText = String(data: theJSONData,
                                                               encoding: .utf8)

                                    service.setFolders( theJSONText! ) { response in
                                        print("Response from XPC service(2):", response)
                                    }

                                    DistributedNotificationCenter.default().postNotificationName(NSNotification.Name(UnderPillowXPC.NotificationFoldersChanged), object: theJSONText, userInfo: nil, options: [.deliverImmediately])
                                }
                            }
                        } else {
                            // User clicked on "Cancel"
                            return
                        }
                }, label: {
                    Text("Select folders")
                })
                    .padding(.bottom, 50)
                Button(action: {
                    FIFinderSyncController.showExtensionManagementInterface()
                }, label: {
                    Text("Enable Finder Extension")
                })
                Spacer()
                        .frame(height: 40)
                Text("Check for new versions and updates:")
                        .font(.system(size: 11))
                Text("Anastasiy Safari")
                        .font(.system(size: 11))
                Link("https://anastasiy.com/ai", destination: URL(string: "https://anastasiy.com/ai")!)
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
