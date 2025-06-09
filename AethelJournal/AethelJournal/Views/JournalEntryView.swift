import SwiftUI
import PencilKit

struct JournalEntryView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var store: JournalStore
    @State var entry: JournalEntry
    @State private var canvasView = PKCanvasView()
    @State private var toolPicker = PKToolPicker()
    @State private var isShowingAlert = false
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 16) {
                TextField("Title", text: $entry.title)
                    .font(.custom("Courier", size: 24))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                
                DrawingCanvas(canvasView: $canvasView) { canvas in
                    toolPicker.addObserver(canvas)
                    toolPicker.setVisible(true, forFirstResponder: canvas)
                    canvas.backgroundColor = .clear
                    canvas.becomeFirstResponder()
                    
                    // Only allow Apple Pencil
                    canvas.drawingPolicy = .pencilOnly
                }
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .frame(maxHeight: .infinity)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    Button {
                        entry.isStarred.toggle()
                    } label: {
                        Image(systemName: entry.isStarred ? "star.fill" : "star")
                            .foregroundColor(.orange)
                    }
                    
                    Button("Save") {
                        if let drawing = try? canvasView.drawing.dataRepresentation() {
                            entry.drawing = drawing
                        }
                        store.addOrUpdate(entry) // ✅ cleaner saving
                        dismiss()
                    }

                    .foregroundColor(.orange)
                }
            }
        }
        .onAppear {
            if let drawingData = entry.drawing,
               let drawing = try? PKDrawing(data: drawingData) {
                canvasView.drawing = drawing
            }
        }
    }
}
