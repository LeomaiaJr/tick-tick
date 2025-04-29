//
//  Extensions.swift
//  tick-tick
//
//  Created by Leonardo Maia Jr
//

import Foundation
import SwiftUI

// MARK: - Date Extensions
extension Date {
    /// Returns the number of days between this date and the current date
    var daysFromNow: Int {
        return Calendar.current.dateComponents([.day], from: self, to: Date()).day ?? 0
    }
    
    /// Format date with a specified style
    func formatted(style: DateFormatter.Style = .medium, timeStyle: DateFormatter.Style = .none) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        formatter.timeStyle = timeStyle
        return formatter.string(from: self)
    }
}

// MARK: - Color Extensions
extension Color {
    /// Returns the appropriate color for a task's urgency level
    static func forUrgencyLevel(_ level: UrgencyLevel) -> Color {
        switch level {
        case .yellow:
            return .yellow
        case .orange:
            return .orange
        case .red:
            return .red
        case .normal:
            return .green
        }
    }
}

// MARK: - View Extensions
extension View {
    /// Apply a standard task row style
    func taskRowStyle() -> some View {
        self.padding(10)
            .background(Color(NSColor.windowBackgroundColor))
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
} 