import SwiftUI
import PencilKit

struct DrawingCanvas: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    var setup: (PKCanvasView) -> Void

    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        container.backgroundColor = .clear
        
        // 1. Add lines layer first
        let linesView = LineBackgroundView()
        linesView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(linesView)

        NSLayoutConstraint.activate([
            linesView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            linesView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            linesView.topAnchor.constraint(equalTo: container.topAnchor),
            linesView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])
        
        // 2. Add canvasView on top
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(canvasView)

        NSLayoutConstraint.activate([
            canvasView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            canvasView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            canvasView.topAnchor.constraint(equalTo: container.topAnchor),
            canvasView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])
        
        // Setup pencil behaviors
        setup(canvasView)
        
        return container
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

