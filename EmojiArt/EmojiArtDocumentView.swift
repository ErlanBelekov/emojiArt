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
    
    @State private var steadyZoomScale: CGFloat = 1.0
    @GestureState private var gestureZoomScale: CGFloat = 1.0
    
    public var zoomScale: CGFloat {
        gestureZoomScale * steadyZoomScale
    }
    
    @State private var steadyStatePanOffset: CGSize = .zero
    @GestureState private var gesturePanOffset: CGSize = .zero
    
    private var panOffset: CGSize {
        (steadyStatePanOffset + gesturePanOffset) * zoomScale
    }
    
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
                        .foregroundColor(Color.white)
                        .overlay(
                            OptionalImage(uiImage: self.document.backgroundImage)
                        )
                        .gesture(self.doubleTapToZoom(in: geometry.size))
                        .scaleEffect(zoomScale)
                        .offset(panOffset)
                    ForEach(document.emojis) { emoji in
                        Text(emoji.text)
                            .font(animatableWithSize: emoji.fontSize * zoomScale)
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
                    .clipped()
                    .edgesIgnoringSafeArea([.bottom, .horizontal])
                    .gesture(self.panGesture())
                    .gesture(self.zoomGesture())
                    .onDrop(of: ["public.image", "public.text"], isTargeted: nil) {
                        providers, location in
                        
                        var location = geometry.convert(location, from: .global)
                        location = CGPoint(x: location.x - geometry.size.width/2, y: location.y - geometry.size.height/2)
                        location = CGPoint(x: location.x - panOffset.width, y: location.y - panOffset.height)
                        location = CGPoint(x: location.x / zoomScale, y: location.y / zoomScale)
                        return self.drop(providers: providers, at: location)
                    }
            }
        }
    }
    
    private func emojiTextToNSItemProvider(_ text: String) -> NSItemProvider {
        NSItemProvider(object: text as NSString)
    }
    
    private func zoomToFit(_ image: UIImage?, in size: CGSize) {
        if let image = image, image.size.width > 0, image.size.height > 0 {
            withAnimation {
                let hZoom = size.width / image.size.width
                let vZoom = size.height / image.size.height
                self.steadyStatePanOffset = .zero
                self.steadyZoomScale = min(hZoom, vZoom)
            }
        }
    }
    
    private func doubleTapToZoom(in size: CGSize) -> some Gesture {
        TapGesture(count: 2)
            .onEnded {
                self.zoomToFit(document.backgroundImage, in: size)
            }
    }
    
    private func zoomGesture() -> some Gesture {
        MagnificationGesture()
            .updating($gestureZoomScale) { latestGestureScale, gestureZoomScale, transaction in
                gestureZoomScale = latestGestureScale
            }
            .onEnded { (finalGestureScale) in
                self.steadyZoomScale *= finalGestureScale
            }
    }
    
    private func panGesture() -> some Gesture {
        DragGesture()
            .updating($gesturePanOffset) { latestDragGestureValue, gesturePanOffset, transaction in
                gesturePanOffset = latestDragGestureValue.translation / self.zoomScale
            }
            .onEnded { finalDragGestureValue in
                self.steadyStatePanOffset = self.steadyStatePanOffset + (finalDragGestureValue.translation / self.zoomScale)
            }
    }
    
    private func position(for emoji: EmojiArt.Emoji, in size: CGSize) -> CGPoint {
        var location = emoji.location
        location = CGPoint(x: emoji.location.x + size.width/2, y: emoji.location.y + size.height/2)
        location = CGPoint(x: location.x * zoomScale, y: location.y * zoomScale)
        location = CGPoint(x: location.x + panOffset.width, y: location.y + panOffset.height)
        return location
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
