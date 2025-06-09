import SwiftUI

class JournalStore: ObservableObject {
    @Published var entries: [JournalEntry] = []

    init() {
        // Load saved entries if they exist
        if let data = UserDefaults.standard.data(forKey: "journal_entries"),
           let decoded = try? JSONDecoder().decode([JournalEntry].self, from: data) {
            self.entries = decoded
        }
    }

    var canAddNewEntry: Bool {
        true // ✅ Always allow adding new entries
    }

    func hasEntry(for date: Date) -> Bool {
        let calendar = Calendar.current
        return entries.contains { entry in
            calendar.isDate(entry.date, inSameDayAs: date)
        }
    }

    func saveEntries() {
        if let encoded = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(encoded, forKey: "journal_entries")
        }
    }

    func addOrUpdate(_ entry: JournalEntry) {
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[index] = entry
        } else {
            entries.append(entry)
        }
        saveEntries()
    }
}

