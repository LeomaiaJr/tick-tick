//
//  ContentView.swift
//  tick-tick
//
//  Created by Leonardo Maia Jr
//

import SwiftUI
import AppKit

struct ContentView: View {
    @StateObject private var taskStore = TaskStore()
    @State private var showingAddTask = false
    @State private var showingAllTasks = false
    @State private var selectedTask: Task? = nil
    
    var body: some View {
        VStack {
            HStack {
                Text("Tasks")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Button(action: {
                    showingAddTask = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.blue)
                }
                .buttonStyle(PlainButtonStyle())
                .sheet(isPresented: $showingAddTask) {
                    AddTaskView(taskStore: taskStore)
                }
                Button(action: {
                    showingAllTasks = true
                }) {
                    Image(systemName: "list.bullet.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.blue)
                }
                .buttonStyle(PlainButtonStyle())
                .sheet(isPresented: $showingAllTasks) {
                    AllTasksView(taskStore: taskStore)
                }
            }
            .padding([.horizontal, .top])
            .padding(.bottom, 8)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    TaskGroupView(title: "Short", tasks: taskStore.tasks.filter { $0.duration == .short && !$0.isCompleted }, taskStore: taskStore, selectedTask: $selectedTask)
                    TaskGroupView(title: "Medium", tasks: taskStore.tasks.filter { $0.duration == .medium && !$0.isCompleted }, taskStore: taskStore, selectedTask: $selectedTask)
                    TaskGroupView(title: "Long", tasks: taskStore.tasks.filter { $0.duration == .long && !$0.isCompleted }, taskStore: taskStore, selectedTask: $selectedTask)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(width: Constants.UI.mainMenuWidth, height: Constants.UI.mainMenuHeight)
        .sheet(item: $selectedTask) { task in
            TaskDetailView(task: task, taskStore: taskStore, isPresented: $selectedTask)
        }
    }
}

#Preview {
    ContentView()
} 