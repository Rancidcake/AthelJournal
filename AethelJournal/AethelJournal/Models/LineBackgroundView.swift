//
//  LineBackgroundView.swift
//  AethelJournal
//
//  Created by Mayank Hete on 06/06/25.
//


import UIKit

class LineBackgroundView: UIView {
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        context.setStrokeColor(UIColor.white.cgColor)

        context.setLineWidth(0.5)

        let lineSpacing: CGFloat = 40 // Adjust spacing between lines

        var y: CGFloat = 0
        while y < rect.height {
            context.move(to: CGPoint(x: 0, y: y))
            context.addLine(to: CGPoint(x: rect.width, y: y))
            y += lineSpacing
        }

        context.strokePath()
    }
}
