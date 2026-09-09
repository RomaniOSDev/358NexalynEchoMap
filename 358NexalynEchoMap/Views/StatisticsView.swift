import SwiftUI
import Charts

struct StatisticsView: View {
    @EnvironmentObject private var store: DataStore
    @StateObject private var viewModel = StatisticsViewModel()

    var body: some View {
        let stats = viewModel.snapshot(from: store)
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                BrushSectionTitle(title: "Statistics")
                if stats.isEmpty {
                    EmptyStateCard(
                        systemImage: "chart.bar",
                        message: "Pin frames and captions to see the studio pulse"
                    )
                } else {
                    overview(stats)
                    if !stats.framesByTheme.isEmpty {
                        chartCard(title: "Frames by theme", items: stats.framesByTheme)
                    }
                    if stats.frameCount > 0 {
                        chartCard(title: "Stills in use", items: stats.framesByStill)
                    }
                    if !stats.topTags.isEmpty {
                        chartCard(title: "Tags", items: stats.topTags)
                    }
                    chartCard(title: "Annotations", items: stats.annotationCoverage)
                    if stats.favouriteCount > 0 {
                        chartCard(title: "Favourites", items: stats.favouritesByCollection)
                    }
                }
            }
            .padding(20)
        }
        .studioCanvas()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Statistics")
                    .font(.system(.headline, design: .serif).italic())
                    .foregroundColor(Color("AppTextPrimary"))
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
    }

    private func overview(_ stats: StudioStatsSnapshot) -> some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                statTile(title: "Themes", value: stats.themeCount)
                statTile(title: "Frames", value: stats.frameCount)
            }
            HStack(spacing: 10) {
                statTile(title: "Captions", value: stats.annotationCount)
                statTile(title: "Favourites", value: stats.favouriteCount)
            }
            HStack(spacing: 10) {
                statTile(title: "Words", value: stats.wordCount)
                statTile(title: "Tagged", value: stats.taggedFrameCount)
            }
        }
    }

    private func statTile(title: String, value: Int) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(.caption, design: .serif).italic())
                .foregroundColor(Color("AppTextSecondary"))
            Text("\(value)")
                .font(.system(.title, design: .serif).italic())
                .foregroundColor(Color("AppTextPrimary"))
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color("AppSurface"))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func chartCard(title: String, items: [StatBar]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(.headline, design: .serif).italic())
                .foregroundColor(Color("AppTextSecondary"))
            Chart(items) { item in
                BarMark(
                    x: .value("Count", item.value),
                    y: .value("Name", item.label)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color("AppPrimary"), Color("AppAccent")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .annotation(position: .trailing, alignment: .center, spacing: 6) {
                    Text("\(item.value)")
                        .font(.caption2)
                        .foregroundColor(Color("AppTextSecondary"))
                }
            }
            .chartXScale(domain: 0...(max(1, items.map(\.value).max() ?? 1)))
            .chartLegend(.hidden)
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 4)) { _ in
                    AxisGridLine()
                        .foregroundStyle(Color("AppTextSecondary").opacity(0.22))
                    AxisValueLabel()
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }
            .chartYAxis {
                AxisMarks { _ in
                    AxisValueLabel()
                        .foregroundStyle(Color("AppTextPrimary"))
                }
            }
            .padding(.trailing, 20)
            .frame(height: chartHeight(for: items.count))
        }
        .padding(16)
        .background(Color("AppSurface"))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func chartHeight(for count: Int) -> CGFloat {
        CGFloat(max(120, count * 36 + 24))
    }
}
