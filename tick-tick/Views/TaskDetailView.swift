//
//  TaskDetailView.swift
//  tick-tick
//
//  Created by Leonardo Maia Jr
//

import SwiftUI
import AppKit

struct TaskDetailView: View {
    let task: Task
    @ObservedObject var taskStore: TaskStore
    @Binding var isPresented: Task?
    @State private var isEditing = false
    @State private var editedTitle: String = ""
    @State private var editedDescription: String = ""
    @State private var editedDuration: TaskDuration = .medium
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                if isEditing {
                    Text("Edit Task")
                        .font(.title2)
                        .fontWeight(.bold)
                } else {
                    VStack(alignment: .leading) {
                        Text(task.title)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Created: \(task.creationDate, formatter: dateFormatter)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                if isEditing {
                    Button(action: {
                        // Cancel editing
                        isEditing = false
                    }) {
                        Text("Cancel")
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.trailing, 8)
                    
                    Button(action: {
                        // Save changes to the task
                        saveChanges()
                    }) {
                        Text("Save")
                            .fontWeight(.medium)
                    }
                    .buttonStyle(PlainButtonStyle())
                } else {
                    Button(action: {
                        // Start editing
                        editedTitle = task.title
                        editedDescription = task.description
                        editedDuration = task.duration
                        isEditing = true
                    }) {
                        Image(systemName: "pencil.circle")
                            .font(.system(size: 20))
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.trailing, 8)
                    
                    Button(action: {
                        isPresented = nil
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.gray)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))
            
            if isEditing {
                // Edit Form
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Title Field
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Title")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            TextField("Task title", text: $editedTitle)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        // Description Field
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Description")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            TextEditor(text: $editedDescription)
                                .frame(minHeight: 100)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(Color(NSColor.separatorColor), lineWidth: 1)
                                )
                                .padding(.bottom, 8)
                        }
                        
                        // Duration Picker
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Duration")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            HStack(spacing: 12) {
                                ForEach(TaskDuration.allCases, id: \.self) { duration in
                                    Button(action: {
                                        editedDuration = duration
                                    }) {
                                        Text(duration.rawValue)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 6)
                                            .background(
                                                RoundedRectangle(cornerRadius: 6)
                                                    .fill(editedDuration == duration ? 
                                                        Color.blue : Color(NSColor.controlBackgroundColor))
                                            )
                                            .foregroundColor(editedDuration == duration ? .white : .primary)
                                            .fontWeight(editedDuration == duration ? .medium : .regular)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                                
                                Spacer()
                            }
                        }
                    }
                    .padding()
                }
            } else {
                // Status bar
                HStack(spacing: 16) {
                    HStack(spacing: 6) {
                        Text("Duration:")
                            .fontWeight(.medium)
                        Text(task.duration.rawValue)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color(NSColor.controlBackgroundColor))
                            )
                    }
                    
                    HStack(spacing: 6) {
                        Text("Status:")
                            .fontWeight(.medium)
                        Text(task.isCompleted ? "Completed" : "In Progress")
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(task.isCompleted ? Color.green.opacity(0.2) : Color.blue.opacity(0.2))
                            )
                            .foregroundColor(task.isCompleted ? .green : .blue)
                    }
                    
                    HStack(spacing: 6) {
                        Text("Urgency:")
                            .fontWeight(.medium)
                        Circle()
                            .fill(urgencyColor)
                            .frame(width: 12, height: 12)
                        Text(task.urgencyLevel.rawValue)
                    }
                    
                    Spacer()
                }
                .font(.caption)
                .padding()
                .background(Color(NSColor.windowBackgroundColor).opacity(0.8))
                
                // Description
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        if !task.description.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Description")
                                    .font(.headline)
                                
                                Text(task.description)
                                    .font(.body)
                                    .lineSpacing(4)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        } else {
                            VStack(alignment: .center, spacing: 8) {
                                Image(systemName: "text.alignleft")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray.opacity(0.5))
                                Text("No description provided")
                                    .font(.body)
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 40)
                        }
                    }
                    .padding()
                }
                
                // Actions
                HStack(spacing: 16) {
                    Button(action: {
                        taskStore.toggleCompletion(for: task)
                    }) {
                        HStack {
                            Image(systemName: task.isCompleted ? "circle" : "checkmark.circle")
                            Text(task.isCompleted ? "Mark as Incomplete" : "Mark as Complete")
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(task.isCompleted ? Color.gray.opacity(0.2) : Color.green.opacity(0.2))
                        )
                        .foregroundColor(task.isCompleted ? .gray : .green)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: {
                        taskStore.deleteTask(id: task.id)
                        isPresented = nil
                    }) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Delete")
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.red.opacity(0.2))
                        )
                        .foregroundColor(.red)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                }
                .padding()
                .background(Color(NSColor.windowBackgroundColor))
            }
        }
        .frame(width: Constants.UI.taskDetailWidth, height: Constants.UI.taskDetailHeight)
    }
    
    // Function to save changes to the task
    private func saveChanges() {
        // Only proceed if title is not empty
        if !editedTitle.isEmpty {
            // Update the task in the store
            taskStore.updateTask(
                id: task.id,
                title: editedTitle,
                description: editedDescription,
                duration: editedDuration
            )
            // Exit edit mode
            isEditing = false
            
            // Refresh the selected task to reflect the changes
            if let updatedTask = taskStore.tasks.first(where: { $0.id == task.id }) {
                // This will refresh the view with the updated task
                isPresented = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isPresented = updatedTask
                }
            }
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