import SwiftUI

struct CoachListView: View {

    // Навигация управляется из CoachFeature
    @Binding var path: NavigationPath

    // Единый источник данных
    @EnvironmentObject private var coachStore: CoachStore

    var body: some View {
        List {
            ForEach(coachStore.coaches) { coach in
                Button {
                    // Переход в детали тренера
                    path.append(
                        CoachRoute.detail(coachID: coach.id)
                    )
                } label: {
                    coachRow(coach)
                }
                .buttonStyle(.plain)
            }
        }
        .listStyle(.plain)
    }

    // MARK: - Row

    @ViewBuilder
    private func coachRow(_ coach: Coach) -> some View {
        VStack(alignment: .leading, spacing: 6) {

            Text(coach.name)
                .font(.headline)

            Text(coach.specialization)
                .font(.subheadline)
                .foregroundColor(.secondary)

            HStack(spacing: 8) {
                Label(
                    String(format: "%.1f", coach.rating),
                    systemImage: "star.fill"
                )
                .foregroundColor(.yellow)

                Text("(\(coach.reviewCount))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    NavigationStack {
        CoachListView(path: .constant(NavigationPath()))
            .environmentObject(CoachStore())
            .navigationTitle("Тренеры")
    }
}
