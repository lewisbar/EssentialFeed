//
//  SnapshotTesting.swift
//  EssentialFeediOSTests
//
//  Created by LennartWisbar on 18.12.23.
//

import XCTest

extension UIViewController {
    func snapshot(for configuration: SnapshotConfiguration) -> UIImage {
        return SnapshotWindow(configuration: configuration, root: self).snapshot()
    }
}

struct SnapshotConfiguration {
    let size: CGSize
    let safeAreaInsets: UIEdgeInsets
    let layoutMargins: UIEdgeInsets
    let traitCollection: UITraitCollection

    static func iPhone15Pro(style: UIUserInterfaceStyle) -> SnapshotConfiguration {
        return SnapshotConfiguration(
            size: CGSize(width: 393, height: 852),
            safeAreaInsets: UIEdgeInsets(top: 59, left: 0, bottom: 34, right: 0),
            layoutMargins: UIEdgeInsets(top: 20, left: 16, bottom: 0, right: 16),
            traitCollection: UITraitCollection { traits in
                traits.forceTouchCapability = .available
                traits.layoutDirection = .leftToRight
                traits.preferredContentSizeCategory = .medium
                traits.userInterfaceIdiom = .phone
                traits.horizontalSizeClass = .compact
                traits.verticalSizeClass = .regular
                traits.displayScale = 2
                traits.displayGamut = .P3
                traits.userInterfaceStyle = style
            }
        )
    }
}

private final class SnapshotWindow: UIWindow {
    private var configuration: SnapshotConfiguration = .iPhone15Pro(style: .light)

    convenience init(configuration: SnapshotConfiguration, root: UIViewController) {
        self.init(frame: CGRect(origin: .zero, size: configuration.size))
        self.configuration = configuration
        self.layoutMargins = configuration.layoutMargins
        self.rootViewController = root
        self.isHidden = false
        root.view.layoutMargins = configuration.layoutMargins
    }

    override var safeAreaInsets: UIEdgeInsets {
        return configuration.safeAreaInsets
    }

    override var traitCollection: UITraitCollection {
        return super.traitCollection.modifyingTraits { traits in
            traits.forceTouchCapability = configuration.traitCollection.forceTouchCapability
            traits.layoutDirection = configuration.traitCollection.layoutDirection
            traits.preferredContentSizeCategory = configuration.traitCollection.preferredContentSizeCategory
            traits.userInterfaceIdiom = configuration.traitCollection.userInterfaceIdiom
            traits.horizontalSizeClass = configuration.traitCollection.horizontalSizeClass
            traits.verticalSizeClass = configuration.traitCollection.verticalSizeClass
            traits.displayScale = configuration.traitCollection.displayScale
            traits.displayGamut = configuration.traitCollection.displayGamut
            traits.userInterfaceStyle = configuration.traitCollection.userInterfaceStyle
        }
    }

    func snapshot() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds, format: .init(for: traitCollection))
        return renderer.image { action in
            layer.render(in: action.cgContext)
        }
    }
}
