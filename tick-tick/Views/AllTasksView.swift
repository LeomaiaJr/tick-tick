//
//  AllTasksView.swift
//  tick-tick
//
//  Created by Leonardo Maia Jr
//

import SwiftUI
import AppKit

struct AllTasksView: View {
    @ObservedObject var taskStore: TaskStore
    @Environment(\.presentationMode) var presentationMode
    @State private var showCompletedTasks = false
    @State private var editMode = false
    @State private var selectedTask: Task? = nil
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header controls 
                HStack {
                    Toggle("Show Completed", isOn: $showCompletedTasks)
                        .toggleStyle(SwitchToggleStyle())
                    
                    Spacer()
                    
                    Button(action: {
                        editMode.toggle()
                    }) {
                        Text(editMode ? "Done" : "Edit")
                    }
                }
                .padding([.horizontal, .top])
                .padding(.bottom, 8)
                
                // Task list
                List {
                    ForEach(TaskDuration.allCases, id: \.self) { duration in
                        Section(header: 
                            HStack {
                                Text(duration.rawValue)
                                    .font(.headline)
                                Spacer()
                            }
                            .padding(.vertical, 4)
                        ) {
                            let filteredTasks = taskStore.tasks.filter { 
                                $0.duration == duration && (showCompletedTasks || !$0.isCompleted)
                            }
                            
                            if filteredTasks.isEmpty {
                                Text("No tasks")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            } else {
                                ForEach(filteredTasks) { task in
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(task.title)
                                                .fontWeight(.medium)
                                                .strikethrough(task.isCompleted)
                                            
                                            if !task.description.isEmpty {
                                                Text(task.description)
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                                    .lineLimit(1)
                                            }
                                            
                                            Text("Created: \(task.creationDate, formatter: dateFormatter)")
                                                .font(.caption2)
                                                .foregroundColor(.gray)
                                        }
                                        
                                        Spacer()
                                        
                                        if editMode {
                                            Button(action: {
                                                taskStore.deleteTask(id: task.id)
                                            }) {
                                                Image(systemName: "trash")
                                                    .foregroundColor(.red)
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        } else {
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(urgencyColor(for: task))
                                                .frame(width: 12, height: 12)
                                            
                                            Button(action: {
                                                taskStore.toggleCompletion(for: task)
                                            }) {
                                                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                                    .foregroundColor(task.isCompleted ? .green : .gray)
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                    }
                                    .padding(.vertical, 4)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        if !editMode {
                                            selectedTask = task
                                        }
                                    }
                                }
                                .onDelete { indexSet in
                                    let tasksToDelete = indexSet.map { filteredTasks[$0] }
                                    for task in tasksToDelete {
                                        taskStore.deleteTask(id: task.id)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("All Tasks")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .sheet(item: $selectedTask) { task in
                TaskDetailView(task: task, taskStore: taskStore, isPresented: $selectedTask)
            }
            .frame(minWidth: Constants.UI.allTasksViewWidth, minHeight: Constants.UI.allTasksViewHeight)
        }
    }
    
    private func urgencyColor(for task: Task) -> Color {
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
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }
} 