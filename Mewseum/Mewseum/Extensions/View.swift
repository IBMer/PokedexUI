//
//  View.swift
//  Mewseum
//
//  Created by Vincent WANG on 2025/11/15.
//
import SwiftUI

extension View {
    /// A conditional view modifier that applies a transformation only when a condition is true.
    ///
    /// - Parameters:
    ///   - condition: A boolean value indicating whether to apply the transformation.
    ///   - modify: A closure that transforms the view.
    /// - Returns: Either the modified view or the original view, depending on the condition.
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, modify: (Self) -> Content) -> some View {
        if condition {
            modify(self)
        } else {
            self
        }
    }
}
