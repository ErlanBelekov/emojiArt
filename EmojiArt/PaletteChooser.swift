//
//  PaletteChooser.swift
//  EmojiArt
//
//  Created by Erlan on 3/25/21.
//

import SwiftUI

struct PaletteChooser: View {
    @ObservedObject var document: EmojiArtDocument
    
    @Binding var chosenPalette: String
    
    var body: some View {
        HStack {
            Stepper(onIncrement: {
                self.chosenPalette = self.document.palette(after: self.chosenPalette)
            }, onDecrement: {
                self.chosenPalette = self.document.palette(before: self.chosenPalette)
            }, label: { EmptyView() })
            Text(self.document.paletteNames[chosenPalette] ?? "")
        }
            .fixedSize(horizontal: true, vertical: false)
    }
}

//struct PaletteChooser_Previews: PreviewProvider {
//    static var previews: some View {
//        PaletteChooser()
//    }
//}
