//
//  RoxitApp.swift
//  Roxit
//
//  Created by Pierre Abdelsayed on 12/1/22.
//

import SwiftUI

@main
struct RoxitApp: App {
    @AppStorage("amountofBots") var amountofBots: Int = 3
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
