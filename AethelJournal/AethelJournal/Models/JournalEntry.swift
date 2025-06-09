import Foundation
import PencilKit

struct JournalEntry: Identifiable, Codable {
    let id: UUID
    var title: String
    var content: String
    var date: Date
    var drawing: Data?
    var isStarred: Bool
    
    init(id: UUID = UUID(), title: String = "", content: String = "", date: Date = Date(), drawing: Data? = nil, isStarred: Bool = false) {
        self.id = id
        self.title = title
        self.content = content
        self.date = date
        self.drawing = drawing
        self.isStarred = isStarred
    }
    
    enum CodingKeys: String, CodingKey {
        case id, title, content, date, drawing, isStarred
    }
}
