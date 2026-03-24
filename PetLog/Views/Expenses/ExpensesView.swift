import SwiftUI
import SwiftData
import Charts

struct ExpensesView: View {
    @Query(sort: \Pet.name) private var pets: [Pet]
    @Environment(\.modelContext) private var modelContext
    @State private var selectedPeriod: ExpensePeriod = .month
    @State private var showingAdd = false
    @State private var showingExport = false

    enum ExpensePeriod: String, CaseIterable, Identifiable {
        case month, year
        var id: String { rawValue }
        var displayName: String { rawValue.capitalized }
    }

    private var allExpenses: [Expense] {
        pets.flatMap { $0.expenses }
    }

    private var filteredExpenses: [Expense] {
        let calendar = Calendar.current
        let now = Date()
        switch selectedPeriod {
        case .month:
            let start = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
            return allExpenses.filter { $0.date >= start }
        case .year:
            let start = calendar.date(from: calendar.dateComponents([.year], from: now))!
            return allExpenses.filter { $0.date >= start }
        }
    }

    private var totalAmount: Double {
        filteredExpenses.reduce(0) { $0 + $1.amount }
    }

    private var categoryBreakdown: [(category: ExpenseCategory, amount: Double)] {
        var totals: [ExpenseCategory: Double] = [:]
        for expense in filteredExpenses {
            totals[expense.category, default: 0] += expense.amount
        }
        return totals.map { ($0.key, $0.value) }.sorted { $0.amount > $1.amount }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Picker("Period", selection: $selectedPeriod) {
                    ForEach(ExpensePeriod.allCases) { period in
                        Text(period.displayName).tag(period)
                    }
                }
                .pickerStyle(.segmented)

                // Total
                VStack(spacing: 4) {
                    Text(totalAmount.currencyFormatted)
                        .font(.system(size: 40, weight: .bold))
                        .foregroundStyle(Theme.primaryColor)
                    Text("Total \(selectedPeriod == .month ? "This Month" : "This Year")")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .cardStyle()

                // Pie Chart
                if !categoryBreakdown.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("By Category")
                            .font(.headline)

                        Chart(categoryBreakdown, id: \.category) { item in
                            SectorMark(
                                angle: .value("Amount", item.amount),
                                innerRadius: .ratio(0.55),
                                angularInset: 2
                            )
                            .foregroundStyle(item.category.color)
                            .cornerRadius(4)
                        }
                        .frame(height: 200)

                        ForEach(categoryBreakdown, id: \.category) { item in
                            HStack(spacing: 8) {
                                Image(systemName: item.category.icon)
                                    .foregroundStyle(item.category.color)
                                    .frame(width: 24)
                                Text(item.category.displayName)
                                    .font(.subheadline)
                                Spacer()
                                Text(item.amount.currencyFormatted)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                        }
                    }
                    .cardStyle()
                }

                // Recent Expenses
                VStack(alignment: .leading, spacing: 12) {
                    Text("Recent Expenses")
                        .font(.headline)

                    ForEach(filteredExpenses.sorted { $0.date > $1.date }.prefix(20)) { expense in
                        HStack(spacing: 12) {
                            Image(systemName: expense.category.icon)
                                .foregroundStyle(expense.category.color)
                                .frame(width: 32, height: 32)
                                .background(expense.category.color.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))

                            VStack(alignment: .leading, spacing: 2) {
                                Text(expense.expenseDescription.isEmpty ? expense.category.displayName : expense.expenseDescription)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text(expense.date.shortDate)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Text(expense.amountFormatted)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                modelContext.delete(expense)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .cardStyle()
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Expenses")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        showingAdd = true
                    } label: {
                        Label("Add Expense", systemImage: "plus")
                    }
                    Button {
                        exportCSV()
                    } label: {
                        Label("Export CSV", systemImage: "square.and.arrow.up")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingAdd) {
            if let pet = pets.first {
                AddExpenseView(pet: pet)
            }
        }
    }

    private func exportCSV() {
        guard let url = DataExportService.shared.exportExpensesCSV(expenses: filteredExpenses) else { return }
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}

#Preview {
    NavigationStack {
        ExpensesView()
    }
    .modelContainer(for: [Pet.self, Expense.self], inMemory: true)
}
