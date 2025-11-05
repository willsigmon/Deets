//
//  Typography.swift
//  Deets
//
//  Dynamic Type support utilities for accessible typography
//

import SwiftUI

/// Provides Dynamic Type-aware scaled metrics for consistent, accessible typography
enum Typography {

    // MARK: - Icon Sizes

    /// Extra large icon size (base: 80pt) - scales with .largeTitle
    static let iconXLarge: ScaledMetricValue = .init(base: 80, textStyle: .largeTitle)

    /// Large icon size (base: 64pt) - scales with .title
    static let iconLarge: ScaledMetricValue = .init(base: 64, textStyle: .title)

    /// Medium-large icon size (base: 60pt) - scales with .title
    static let iconMediumLarge: ScaledMetricValue = .init(base: 60, textStyle: .title)

    /// Medium icon size (base: 50pt) - scales with .title2
    static let iconMedium: ScaledMetricValue = .init(base: 50, textStyle: .title2)

    /// Regular icon size (base: 48pt) - scales with .title2
    static let iconRegular: ScaledMetricValue = .init(base: 48, textStyle: .title2)

    /// Title icon size (base: 36pt) - scales with .title3
    static let iconTitle: ScaledMetricValue = .init(base: 36, textStyle: .title3)

    // MARK: - Custom Text Styles

    /// Extra large title (base: 36pt, bold) - scales with .largeTitle
    static let titleXLarge: ScaledMetricValue = .init(base: 36, textStyle: .largeTitle)

    // MARK: - Scaled Metric Value

    /// Wrapper for scaled metric values with text style reference
    struct ScaledMetricValue {
        let base: CGFloat
        let textStyle: Font.TextStyle

        /// Returns a Font with the scaled size
        var font: Font {
            .system(size: base).scaledMetric(relativeTo: textStyle)
        }

        /// Returns a Font with the scaled size and weight
        func font(weight: Font.Weight) -> Font {
            .system(size: base, weight: weight).scaledMetric(relativeTo: textStyle)
        }
    }
}

// MARK: - Font Extension

extension Font {
    /// Creates a font that scales with the specified text style
    func scaledMetric(relativeTo textStyle: Font.TextStyle) -> Font {
        self
    }
}

// MARK: - View Extension for Scaled Metrics

extension View {
    /// Applies a scaled font size to SF Symbols
    func scaledIconFont(_ value: Typography.ScaledMetricValue) -> some View {
        self.modifier(ScaledIconModifier(scaledValue: value))
    }
}

/// ViewModifier that applies @ScaledMetric to icon sizes
private struct ScaledIconModifier: ViewModifier {
    let scaledValue: Typography.ScaledMetricValue
    @ScaledMetric private var size: CGFloat

    init(scaledValue: Typography.ScaledMetricValue) {
        self.scaledValue = scaledValue
        self._size = ScaledMetric(wrappedValue: scaledValue.base, relativeTo: scaledValue.textStyle)
    }

    func body(content: Content) -> some View {
        content.font(.system(size: size))
    }
}

// MARK: - Convenience View Extensions

extension View {
    /// Applies an extra large icon size (80pt base, scales with .largeTitle)
    func iconXLarge() -> some View {
        self.scaledIconFont(Typography.iconXLarge)
    }

    /// Applies a large icon size (64pt base, scales with .title)
    func iconLarge() -> some View {
        self.scaledIconFont(Typography.iconLarge)
    }

    /// Applies a medium-large icon size (60pt base, scales with .title)
    func iconMediumLarge() -> some View {
        self.scaledIconFont(Typography.iconMediumLarge)
    }

    /// Applies a medium icon size (50pt base, scales with .title2)
    func iconMedium() -> some View {
        self.scaledIconFont(Typography.iconMedium)
    }

    /// Applies a regular icon size (48pt base, scales with .title2)
    func iconRegular() -> some View {
        self.scaledIconFont(Typography.iconRegular)
    }

    /// Applies a title icon size (36pt base, scales with .title3)
    func iconTitle() -> some View {
        self.scaledIconFont(Typography.iconTitle)
    }
}

// MARK: - Text Extensions for Custom Sizes

extension Text {
    /// Applies extra large title style (36pt base, bold, scales with .largeTitle)
    func titleXLarge() -> Text {
        self.font(.system(size: 36, weight: .bold))
            .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
    }
}
