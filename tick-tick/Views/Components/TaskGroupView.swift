//
//  TaskGroupView.swift
//  tick-tick
//
//  Created by Leonardo Maia Jr
//

import SwiftUI
import AppKit

struct TaskGroupView: View {
    let title: String
    let tasks: [Task]
    @ObservedObject var taskStore: TaskStore
    @Binding var selectedTask: Task?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            if tasks.isEmpty {
                Text("No tasks")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color(NSColor.windowBackgroundColor).opacity(0.6))
                    .cornerRadius(6)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                ForEach(tasks) { task in
                    TaskRow(task: task, taskStore: taskStore, selectedTask: $selectedTask)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
} 