import SwiftUI

enum InkTool: String, Hashable {
    case pencil
    case marker

    var width: CGFloat { self == .marker ? 14 : 3 }
    var opacity: Double { self == .marker ? 0.42 : 1 }
}

struct InkCanvas: View {
    @Binding var strokes: [InkStroke]
    var tool: InkTool
    var isEditable: Bool = true

    @State private var live: [CGPoint] = []

    var body: some View {
        GeometryReader { geo in
            Canvas { context, size in
                for stroke in strokes {
                    let points = stroke.points.map {
                        CGPoint(x: $0.x * size.width, y: $0.y * size.height)
                    }
                    draw(points, marker: stroke.isMarker, in: &context)
                }
                if live.count > 1 {
                    draw(live, marker: tool == .marker, in: &context)
                }
            }
            .contentShape(Rectangle())
            .highPriorityGesture(drag(in: geo.size), including: isEditable ? .all : .none)
        }
    }

    private func drag(in size: CGSize) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                live.append(value.location)
            }
            .onEnded { _ in
                let width = max(size.width, 1)
                let height = max(size.height, 1)
                let points = live.map { InkPoint(x: $0.x / width, y: $0.y / height) }
                if points.count > 1 {
                    strokes.append(InkStroke(points: points, isMarker: tool == .marker))
                }
                live = []
            }
    }

    private func draw(_ points: [CGPoint], marker: Bool, in context: inout GraphicsContext) {
        guard points.count > 1 else { return }
        var path = Path()
        path.move(to: points[0])
        for point in points.dropFirst() {
            path.addLine(to: point)
        }
        let style = StrokeStyle(lineWidth: marker ? 14 : 3, lineCap: .round, lineJoin: .round)
        let color = marker ? Color("AppAccent").opacity(0.42) : Color("AppPrimary")
        context.stroke(path, with: .color(color), style: style)
    }
}
