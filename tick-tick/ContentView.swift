import SwiftUI
import AppKit

struct ContentView: View {
    @StateObject private var taskStore = TaskStore()
    @State private var showingAddTask = false
    @State private var showingAllTasks = false
    
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
                    TaskGroupView(title: "Short", tasks: taskStore.tasks.filter { $0.duration == .short && !$0.isCompleted }, taskStore: taskStore)
                    TaskGroupView(title: "Medium", tasks: taskStore.tasks.filter { $0.duration == .medium && !$0.isCompleted }, taskStore: taskStore)
                    TaskGroupView(title: "Long", tasks: taskStore.tasks.filter { $0.duration == .long && !$0.isCompleted }, taskStore: taskStore)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(width: 320, height: 400)
    }
}

struct TaskGroupView: View {
    let title: String
    let tasks: [Task]
    @ObservedObject var taskStore: TaskStore
    
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
                    TaskRow(task: task, taskStore: taskStore)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct TaskRow: View {
    let task: Task
    @ObservedObject var taskStore: TaskStore
    
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
                        
                        TextField("Optional details", text: $description)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
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
        .frame(width: 450, height: 500)
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

struct AllTasksView: View {
    @ObservedObject var taskStore: TaskStore
    @Environment(\.presentationMode) var presentationMode
    @State private var showCompletedTasks = false
    @State private var editMode = false
    
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
            .frame(minWidth: 500, minHeight: 600)
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

#Preview {
    ContentView()
}
