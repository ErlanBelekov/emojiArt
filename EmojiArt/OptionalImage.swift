//
//  OptionalImage.swift
//  EmojiArt
//
//  Created by Erlan on 3/24/21.
//

import SwiftUI

struct OptionalImage: View {
    var uiImage: UIImage?
    
    var body: some View {
        Group {
            if uiImage != nil {
                Image(uiImage: uiImage!)
            }
        }
    }
}
