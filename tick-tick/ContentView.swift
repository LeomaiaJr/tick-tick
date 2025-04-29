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
        .frame(width: 320, height: 400)
        .sheet(item: $selectedTask) { task in
            TaskDetailView(task: task, taskStore: taskStore, isPresented: $selectedTask)
        }
    }
}

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
        .frame(width: 450, height: 400)
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
