//
//  SpriteLoaderKey.swift
//  Mewseum
//
//  Created by Vincent WANG on 2025/11/15.
//
import SwiftUI

private struct SpriteLoaderKey: EnvironmentKey {
    static let defaultValue: SpriteLoader = SpriteLoader()
}

extension EnvironmentValues {
    var spriteLoader: SpriteLoader {
        get { self[SpriteLoaderKey.self] }
        set { self[SpriteLoaderKey.self] = newValue }
    }
}
