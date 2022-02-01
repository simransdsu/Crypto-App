//
//  Crypto_AppApp.swift
//  Crypto App
//
//  Created by Simran Preet Narang on 2022-01-10.
//

import SwiftUI

@main
struct CryptoApp: App {
    
    @StateObject var vm = HomeViewModel()
    
    init() {
        UINavigationBar.appearance().largeTitleTextAttributes = [
            .foregroundColor: UIColor(Color.theme.accent)
        ]
        UINavigationBar.appearance().titleTextAttributes = [
            .foregroundColor: UIColor(Color.theme.accent)
        ]
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                HomeView()
                    .navigationBarHidden(true)
            }.environmentObject(vm)
        }
    }
}
