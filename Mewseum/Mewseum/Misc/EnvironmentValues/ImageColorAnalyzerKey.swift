//
//  ImageColorAnalyzerKey.swift
//  Mewseum
//
//  Created by Vincent WANG on 2025/11/15.
//
import SwiftUI

private struct ImageColorAnalyzerKey: EnvironmentKey {
    static let defaultValue: ImageColorAnalyzer = ImageColorAnalyzer()
}

extension EnvironmentValues {
    var imageColorAnalyzer: ImageColorAnalyzer {
        get { self[ImageColorAnalyzerKey.self] }
        set { self[ImageColorAnalyzerKey.self] = newValue }
    }
}
