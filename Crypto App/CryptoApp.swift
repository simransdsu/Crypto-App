//
//  Crypto_AppApp.swift
//  Crypto App
//
//  Created by Simran Preet Narang on 2022-01-10.
//

import SwiftUI

@main
struct CryptoApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                HomeView()
                    .navigationBarHidden(true)
            }
        }
    }
}
