//
//  EmojiArt.swift
//  EmojiArt
//
//  Created by Erlan on 3/24/21.
//

import Foundation

struct EmojiArt: Codable {
    // MARK: - Properties
    var backgroundURL: URL?
    var emojis = [Emoji]()
    private var uniqueEmojiId = 0
    
    var json: Data? {
        return try? JSONEncoder().encode(self)
    }
    
    struct Emoji: Identifiable, Codable, Hashable {
        let text: String
        let id: Int
        var x: Int // offset from center
        var y: Int // offset from center
        var size: Int
        
        fileprivate init(text: String, x: Int, y: Int, size: Int, id: Int) {
            self.text = text
            self.x = x
            self.y = y
            self.size = size
            self.id = id
        }
    }
    
    init?(json: Data?) {
        if json != nil, let decodedEmojiArt = try? JSONDecoder().decode(EmojiArt.self, from: json!) {
            self = decodedEmojiArt
        } else {
            return nil
        }
    }
    
    init() {}
    
    mutating func addEmoji(_ text: String, x: Int, y: Int, size: Int) {
        uniqueEmojiId += 1
        emojis.append(Emoji(text: text, x: x, y: y, size: size, id: uniqueEmojiId))
    }
}
