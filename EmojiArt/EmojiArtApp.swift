//
//  EmojiArtApp.swift
//  EmojiArt
//
//  Created by Erlan on 3/24/21.
//

import SwiftUI

@main
struct EmojiArtApp: App {
    let artDocument = EmojiArtDocument()
    
    var body: some Scene {
        WindowGroup {
            EmojiArtDocumentView(document: artDocument)
        }
    }
}
