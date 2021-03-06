//
//  Spinning.swift
//  EmojiArt
//
//  Created by Erlan on 3/25/21.
//

import SwiftUI

struct Spinning: ViewModifier {
    @State var isVisible: Bool = false
    
    func body(content: Content) -> some View {
        content
            .rotationEffect(Angle.degrees(isVisible ? 360 : 0))
            .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false))
            .onAppear {
                isVisible = true
            }
    }
}

extension View {
    func spinning() -> some View {
        self.modifier(Spinning())
    }
}
