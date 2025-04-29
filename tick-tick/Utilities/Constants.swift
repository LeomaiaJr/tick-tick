//
//  Constants.swift
//  tick-tick
//
//  Created by Leonardo Maia Jr
//

import Foundation
import SwiftUI

struct Constants {
    struct UserDefaultsKeys {
        static let tasks = "tasks"
    }
    
    struct UI {
        static let mainMenuWidth: CGFloat = 320
        static let mainMenuHeight: CGFloat = 400
        static let taskDetailWidth: CGFloat = 450
        static let taskDetailHeight: CGFloat = 400
        static let addTaskFormWidth: CGFloat = 450
        static let addTaskFormHeight: CGFloat = 500
        static let allTasksViewWidth: CGFloat = 500
        static let allTasksViewHeight: CGFloat = 600
    }
    
    struct UrgencyThresholds {
        struct Short {
            static let yellow = 1 // days
            static let red = 2 // days
        }
        
        struct Medium {
            static let yellow = 2 // days
            static let orange = 3 // days
            static let red = 4 // days
        }
        
        struct Long {
            static let yellow = 4 // days
            static let orange = 5 // days
            static let red = 6 // days
        }
    }
} 