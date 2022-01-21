//
//  UIApplication.swift
//  Crypto App
//
//  Created by Simran Preet Narang on 2022-01-21.
//

import Foundation
import SwiftUI

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
