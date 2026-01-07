import SwiftUI

struct CoachListView: View {
    @StateObject private var viewModel = CoachListViewModel()
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            List(viewModel.coaches) { coach in
                NavigationLink(destination: CoachDetailView(coach: coach)) {
                    VStack(alignment: .leading) {
                        Text(coach.name)
                            .font(.headline)
                        Text(coach.specialization)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("Рейтинг: \(String(format: "%.1f", coach.rating))")
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("Тренеры")
            .searchable(text: $searchText)
            .onChange(of: searchText) { newValue in
                viewModel.searchCoaches(query: newValue)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Рейтинг 4.5+") {
                            viewModel.filterByMinRating(4.5)
                        }
                        Button("Рейтинг 4.8+") {
                            viewModel.filterByMinRating(4.8)
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.loadCoaches()
            }
        }
    }
}

#Preview {
    CoachListView()
}
