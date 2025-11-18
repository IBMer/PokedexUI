//
//  HapticFeedbackKey.swift
//  Mewseum
//
//  Created by Vincent WANG on 2025/11/15.
//
import SwiftUI
import UIKit

private struct HapticFeedbackKey: EnvironmentKey {
    static let defaultValue: UIImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
}

extension EnvironmentValues {
    var hapticFeedback: UIImpactFeedbackGenerator {
        get { self[HapticFeedbackKey.self] }
        set { self[HapticFeedbackKey.self] = newValue }
    }
}
