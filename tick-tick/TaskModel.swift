import Foundation

enum TaskDuration: String, Codable, CaseIterable {
    case short = "Short"
    case medium = "Medium"
    case long = "Long"
}

enum UrgencyLevel: String, Codable {
    case normal = "Normal"
    case yellow = "Yellow"
    case orange = "Orange"
    case red = "Red"
}

struct Task: Identifiable, Codable {
    let id: UUID
    var title: String
    var description: String
    var duration: TaskDuration
    var isCompleted: Bool
    var creationDate: Date

    init(
        id: UUID = UUID(), title: String, description: String = "", duration: TaskDuration,
        isCompleted: Bool = false
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.duration = duration
        self.isCompleted = isCompleted
        self.creationDate = Date()
    }

    var urgencyLevel: UrgencyLevel {
        let daysSinceCreation =
            Calendar.current.dateComponents([.day], from: creationDate, to: Date()).day ?? 0

        switch duration {
        case .short:
            if daysSinceCreation >= 2 {
                return .red
            } else if daysSinceCreation >= 1 {
                return .yellow
            }
        case .medium:
            if daysSinceCreation >= 4 {
                return .red
            } else if daysSinceCreation >= 3 {
                return .orange
            } else if daysSinceCreation >= 2 {
                return .yellow
            }
        case .long:
            if daysSinceCreation >= 6 {
                return .red
            } else if daysSinceCreation >= 5 {
                return .orange
            } else if daysSinceCreation >= 4 {
                return .yellow
            }
        }

        return .normal
    }
}

class TaskStore: ObservableObject {
    @Published var tasks: [Task] = [] {
        didSet {
            save()
        }
    }

    init() {
        load()
    }

    func addTask(title: String, description: String, duration: TaskDuration) {
        let task = Task(title: title, description: description, duration: duration)
        tasks.append(task)
    }

    func deleteTask(at indexSet: IndexSet) {
        tasks.remove(atOffsets: indexSet)
    }

    func deleteTask(id: UUID) {
        if let index = tasks.firstIndex(where: { $0.id == id }) {
            tasks.remove(at: index)
        }
    }

    func toggleCompletion(for task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
        }
    }

    func updateTask(id: UUID, title: String, description: String, duration: TaskDuration) {
        if let index = tasks.firstIndex(where: { $0.id == id }) {
            tasks[index].title = title
            tasks[index].description = description
            tasks[index].duration = duration
        }
    }

    private func save() {
        if let encoded = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(encoded, forKey: "tasks")
        }
    }

    private func load() {
        if let data = UserDefaults.standard.data(forKey: "tasks"),
            let decoded = try? JSONDecoder().decode([Task].self, from: data)
        {
            tasks = decoded
        }
    }
}
