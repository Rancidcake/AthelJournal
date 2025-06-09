import SwiftUI

struct ContentView: View {
    @StateObject private var store = JournalStore()
    @State private var showingNewEntry = false
    @State private var stoicQuote = "Loading wisdom..."
    @State private var selectedDate = Date()
    @State private var selectedMonth: Int = Calendar.current.component(.month, from: Date())
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())

    private let calendar = Calendar.current
    private let daysInWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)

                HStack(spacing: 0) {
                    // Calendar Sidebar
                    VStack(spacing: 8) {
                        HStack(spacing: 8) {
                            Button(action: { selectedYear -= 1 }) {
                                Image(systemName: "chevron.left")
                                    .foregroundColor(.white)
                            }
                            Text("\(selectedYear)")
                                .font(.custom("Courier", size: 16))
                                .foregroundColor(.orange)
                            Button(action: { selectedYear += 1 }) {
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.top, 8)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(1...12, id: \.self) { month in
                                    Button(action: {
                                        selectedMonth = month
                                        updateSelectedDate()
                                    }) {
                                        Text(DateFormatter().monthSymbols[month - 1])
                                            .font(.custom("Courier", size: 14))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 6)
                                            .background(selectedMonth == month ? Color.orange.opacity(0.3) : Color.clear)
                                            .cornerRadius(8)
                                    }
                                }
                            }
                            .padding(.horizontal, 8)
                        }

                        HStack {
                            ForEach(daysInWeek, id: \.self) { day in
                                Text(day)
                                    .font(.custom("Courier", size: 12))
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(.horizontal, 8)

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                            ForEach(calendarDays(), id: \.self) { date in
                                VStack(spacing: 4) {
                                    if store.hasEntry(for: date) {
                                        Circle()
                                            .fill(Color.orange)
                                            .frame(width: 4, height: 4)
                                    }

                                    Text("\(calendar.component(.day, from: date))")
                                        .font(.custom("Courier", size: 14))
                                        .foregroundColor(.white)
                                }
                                .frame(height: 40)
                                .background(
                                    calendar.isDate(date, inSameDayAs: selectedDate) ?
                                        Color.orange.opacity(0.2) : Color.clear
                                )
                                .cornerRadius(6)
                                .onTapGesture {
                                    selectedDate = date
                                }
                            }
                        }
                        .padding(.horizontal, 8)

                        Spacer()
                    }
                    .frame(width: UIScreen.main.bounds.width * 0.35)
                    .background(Color.gray.opacity(0.1))

                    // Entries Column
                    ScrollView {
                        VStack(spacing: 20) {
                            Text(stoicQuote)
                                .font(.custom("Courier", size: 16))
                                .foregroundColor(.orange)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(12)

                            ForEach(filteredEntries) { entry in
                                NavigationLink(destination: JournalEntryView(store: store, entry: entry)) {
                                    JournalEntryRow(entry: entry)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Aethel Journal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if store.canAddNewEntry {
                            showingNewEntry.toggle()
                        }
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(.orange)
                    }
                    .disabled(!store.canAddNewEntry)
                }
            }
            .sheet(isPresented: $showingNewEntry) {
                NavigationStack {
                    JournalEntryView(store: store, entry: JournalEntry(date: selectedDate))
                }
            }
        }
        .task {
            await fetchStoicQuote()
        }
    }

    private var filteredEntries: [JournalEntry] {
        store.entries.filter { calendar.isDate($0.date, inSameDayAs: selectedDate) }
    }

    private func calendarDays() -> [Date] {
        let components = DateComponents(year: selectedYear, month: selectedMonth)
        guard let start = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: start) else {
            return []
        }

        return range.compactMap { day in
            calendar.date(byAdding: .day, value: day - 1, to: start)
        }
    }

    private func updateSelectedDate() {
        let components = DateComponents(year: selectedYear, month: selectedMonth, day: 1)
        if let newDate = calendar.date(from: components) {
            selectedDate = newDate
        }
    }

    func fetchStoicQuote() async {
        let quotes = [
            "The greatest power we have is the power of choice. – Seneca",
            "He who fears death will never do anything worthy of a living man. – Seneca",
            "We suffer more often in imagination than in reality. – Seneca",
            "If it is not right, do not do it. If it is not true, do not say it. – Marcus Aurelius",
            "You have power over your mind – not outside events. Realize this, and you will find strength. – Marcus Aurelius",
            "It is not that we have a short time to live, but that we waste a lot of it. – Seneca",
            "Man conquers the world by conquering himself. – Zeno of Citium",
            "The best revenge is not to be like your enemy. – Marcus Aurelius",
            "How long are you going to wait before you demand the best for yourself? – Epictetus",
            "Don't explain your philosophy. Embody it. – Epictetus"
        ]

        if let randomQuote = quotes.randomElement() {
            stoicQuote = randomQuote
        }
    }

}

struct JournalEntryRow: View {
    let entry: JournalEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(entry.title)
                    .font(.custom("Courier", size: 20))
                    .foregroundColor(.white)

                Spacer()

                if entry.isStarred {
                    Image(systemName: "star.fill")
                        .foregroundColor(.orange)
                }
            }

            Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                .font(.custom("Courier", size: 14))
                .foregroundColor(.orange)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}
