//
//  AddTaskView.swift
//  tick-tick
//
//  Created by Leonardo Maia Jr
//

import SwiftUI
import AppKit

struct AddTaskView: View {
    @ObservedObject var taskStore: TaskStore
    @Environment(\.presentationMode) var presentationMode
    @State private var title = ""
    @State private var description = ""
    @State private var selectedDuration: TaskDuration = .medium
    @State private var showError = false
    @FocusState private var isTitleFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("New Task")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.gray)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))
            
            // Form content
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Title Field
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Title")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField("What needs to be done?", text: $title)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .focused($isTitleFocused)
                        
                        if showError && title.isEmpty {
                            Text("Title is required")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    
                    // Description Field
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Description")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextEditor(text: $description)
                            .frame(minHeight: 100)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color(NSColor.separatorColor), lineWidth: 1)
                            )
                            .padding(.bottom, 8)
                    }
                    
                    // Duration Picker - Simple Text Button Style
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Duration")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 12) {
                            ForEach(TaskDuration.allCases, id: \.self) { duration in
                                Button(action: {
                                    selectedDuration = duration
                                }) {
                                    Text(duration.rawValue)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 6)
                                        .background(
                                            RoundedRectangle(cornerRadius: 6)
                                                .fill(selectedDuration == duration ? 
                                                    Color.blue : Color(NSColor.controlBackgroundColor))
                                        )
                                        .foregroundColor(selectedDuration == duration ? .white : .primary)
                                        .fontWeight(selectedDuration == duration ? .medium : .regular)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            
                            Spacer()
                        }
                    }
                    
                    // Help text
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Task urgency will be calculated based on duration:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Group {
                            Text("• Short: ") + Text("yellow after 1 day, red after 2 days").foregroundColor(.gray)
                            Text("• Medium: ") + Text("yellow after 2 days, orange after 3, red after 4").foregroundColor(.gray)
                            Text("• Long: ") + Text("yellow after 4 days, orange after 5, red after 6").foregroundColor(.gray)
                        }
                        .font(.caption)
                    }
                    .padding()
                    .background(Color(NSColor.textBackgroundColor).opacity(0.4))
                    .cornerRadius(8)
                }
                .padding()
            }
            
            // Button area
            HStack {
                Spacer()
                
                Button(action: {
                    if title.isEmpty {
                        showError = true
                        isTitleFocused = true
                    } else {
                        taskStore.addTask(title: title, description: description, duration: selectedDuration)
                        presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    Text("Add Task")
                        .fontWeight(.medium)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 8)
                        .background(title.isEmpty ? Color.blue.opacity(0.6) : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(title.isEmpty)
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor).opacity(0.95))
        }
        .frame(width: Constants.UI.addTaskFormWidth, height: Constants.UI.addTaskFormHeight)
        .onAppear {
            // Reset the form state when it appears
            title = ""
            description = ""
            selectedDuration = .medium
            showError = false
            isTitleFocused = true
        }
    }
} 