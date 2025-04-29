//
//  TaskRow.swift
//  tick-tick
//
//  Created by Leonardo Maia Jr
//

import SwiftUI
import AppKit

struct TaskRow: View {
    let task: Task
    @ObservedObject var taskStore: TaskStore
    @Binding var selectedTask: Task?
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .fontWeight(.medium)
                if !task.description.isEmpty {
                    Text(task.description)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            RoundedRectangle(cornerRadius: 4)
                .fill(urgencyColor)
                .frame(width: 12, height: 12)
            
            Button(action: {
                taskStore.toggleCompletion(for: task)
            }) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 16))
                    .foregroundColor(task.isCompleted ? .green : .gray)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(10)
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        .contentShape(Rectangle())
        .onTapGesture {
            selectedTask = task
        }
    }
    
    var urgencyColor: Color {
        switch task.urgencyLevel {
        case .yellow:
            return .yellow
        case .orange:
            return .orange
        case .red:
            return .red
        default:
            return .green
        }
    }
} 