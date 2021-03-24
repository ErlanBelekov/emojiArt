//
//  EmojiArtDocumentView.swift
//  EmojiArt
//
//  Created by Erlan on 3/24/21.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    // MARK: - Properties
    @ObservedObject var document: EmojiArtDocument
    
    @State private var currentPosition: CGSize = .zero
    @State private var newPosition: CGSize = .zero
    
    // MARK: - Drawing Constraints
    private let emojiFontSize: CGFloat = 40.0
    private let defaultEmojiSize: CGFloat = 40.0
    
    var body: some View {
        VStack {
            ScrollView(.horizontal) {
                HStack {
                    ForEach(EmojiArtDocument.palette.map { String($0)}, id: \.self) { emoji in
                        Text(emoji)
                            .font(Font.system(size: emojiFontSize))
                            .onDrag {
                                emojiTextToNSItemProvider(emoji)
                            }
                    }
                }
            }.padding(.horizontal)
            GeometryReader { geometry in
                ZStack {
                    Rectangle()
                        .foregroundColor(Color.yellow)
                        .edgesIgnoringSafeArea([.bottom, .horizontal])
                        .overlay(
                            Group {
                                if self.document.backgroundImage != nil {
                                    Image(uiImage: self.document.backgroundImage!)
                                }
                            }
                        )
                        .onDrop(of: ["public.image", "public.text"], isTargeted: nil) {
                            providers, location in
                            
                            var location = geometry.convert(location, from: .global)
                            location = CGPoint(x: location.x - geometry.size.width/2, y: location.y - geometry.size.height/2)
                            return self.drop(providers: providers, at: location)
                        }
                    ForEach(document.emojis) { emoji in
                        Text(emoji.text)
                            .font(self.font(for: emoji))
                            .position(self.position(for: emoji, in: geometry.size))
                            .offset(x: self.currentPosition.width, y: self.currentPosition.height)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        self.currentPosition = CGSize(width: value.translation.width + self.newPosition.width, height: value.translation.height + self.newPosition.height)
                                    }
                                    .onEnded { value in
                                        self.currentPosition = CGSize(width: value.translation.width + self.newPosition.width, height: value.translation.height + self.newPosition.height)
                                        print(self.newPosition.width)
                                        self.newPosition = self.currentPosition
                                    }
                            )
                    }
                }
            }
        }
    }
    
    private func emojiTextToNSItemProvider(_ text: String) -> NSItemProvider {
        NSItemProvider(object: text as NSString)
    }
    
    private func position(for emoji: EmojiArt.Emoji, in size: CGSize) -> CGPoint {
        CGPoint(x: emoji.location.x + size.width/2, y: emoji.location.y + size.height/2)
    }
    
    private func font(for emoji: EmojiArt.Emoji) -> Font {
        return Font.system(size: emoji.fontSize)
    }
    
    private func drop(providers: [NSItemProvider], at location: CGPoint) -> Bool {
        var found = providers.loadFirstObject(ofType: URL.self) { url in
            self.document.setBackgroundUrl(url)
        }

        if !found {
            found = providers.loadObjects(ofType: String.self) { string in
                self.document.addEmoji(string, at: location, size: self.defaultEmojiSize)
            }
        }
        
        return found
    }
}
