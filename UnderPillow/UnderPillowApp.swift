//
//  UnderPillowApp.swift
//  UnderPillowApp
//
//  Created by Anastasiy on 11/7/22.
//

import SwiftUI
import Foundation


@main
struct UnderPillowApp: App {
    @ObservedObject var viewModel = ListViewModel()
    init() {
        
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 100, idealWidth: 400,
                                minHeight: 100, idealHeight: 500,
                                alignment: .center)
        }
    }
}
