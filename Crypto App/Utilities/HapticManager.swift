//
//  HapticManager.swift
//  Crypto App
//
//  Created by Simran Preet Narang on 2022-02-09.
//

import Foundation
import UIKit

class HapticManager {
    static let generator = UINotificationFeedbackGenerator()
    
    static func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        generator.notificationOccurred(type)
    }
}
