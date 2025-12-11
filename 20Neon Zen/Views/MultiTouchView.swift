//
//  MultiTouchView.swift
//  20Neon Zen
//
//  Created by Роман Главацкий on 11.12.2025.
//

import SwiftUI
import UIKit

struct MultiTouchView: UIViewRepresentable {
    var onTouchesChanged: ([CGPoint]) -> Void
    var onTouchesEnded: () -> Void
    
    func makeUIView(context: Context) -> TouchableView {
        let view = TouchableView()
        view.onTouchesChanged = { [onTouchesChanged] locations in
            onTouchesChanged(locations)
        }
        view.onTouchesEnded = { [onTouchesEnded] in
            onTouchesEnded()
        }
        return view
    }
    
    func updateUIView(_ uiView: TouchableView, context: Context) {
        uiView.onTouchesChanged = { [onTouchesChanged] locations in
            onTouchesChanged(locations)
        }
        uiView.onTouchesEnded = { [onTouchesEnded] in
            onTouchesEnded()
        }
    }
}

class TouchableView: UIView {
    var onTouchesChanged: (([CGPoint]) -> Void)?
    var onTouchesEnded: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isMultipleTouchEnabled = true
        isUserInteractionEnabled = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleTouches(touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleTouches(touches)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let allTouches = event?.allTouches, allTouches.count == touches.count {
            onTouchesEnded?()
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        onTouchesEnded?()
    }
    
    private func handleTouches(_ touches: Set<UITouch>) {
        var locations: [CGPoint] = []
        for touch in touches {
            let location = touch.location(in: self)
            locations.append(location)
        }
        onTouchesChanged?(locations)
    }
}

