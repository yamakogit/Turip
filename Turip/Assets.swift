// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif
#if canImport(SwiftUI)
  import SwiftUI
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "ColorAsset.Color", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetColorTypeAlias = ColorAsset.Color
@available(*, deprecated, renamed: "ImageAsset.Image", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetImageTypeAlias = ImageAsset.Image

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Asset {
  internal static let accentColor = ColorAsset(name: "AccentColor")
  internal static let simbol = ImageAsset(name: "Simbol")
  internal static let colorBlue = ColorAsset(name: "colorBlue")
  internal static let colorDarkGray = ColorAsset(name: "colorDarkGray")
  internal static let colorDarkGreen = ColorAsset(name: "colorDarkGreen")
  internal static let colorGray = ColorAsset(name: "colorGray")
  internal static let colorLightGray = ColorAsset(name: "colorLightGray")
  internal static let colorLightGreen = ColorAsset(name: "colorLightGreen")
  internal static let colorLineYellow = ColorAsset(name: "colorLineYellow")
  internal static let colorYellow = ColorAsset(name: "colorYellow")
  internal static let barGreen = ImageAsset(name: "barGreen")
  internal static let barlightGlay = ImageAsset(name: "barlightGlay")
  internal static let blackRectangle = ImageAsset(name: "blackRectangle")
  internal static let blueBack = ImageAsset(name: "blueBack")
  internal static let blueRectangle = ImageAsset(name: "blueRectangle")
  internal static let brownBack = ImageAsset(name: "brownBack")
  internal static let brownRectangle = ImageAsset(name: "brownRectangle")
  internal static let glaf0 = ImageAsset(name: "glaf_0")
  internal static let glaf1 = ImageAsset(name: "glaf_1")
  internal static let glaf10 = ImageAsset(name: "glaf_10")
  internal static let glaf2 = ImageAsset(name: "glaf_2")
  internal static let glaf3 = ImageAsset(name: "glaf_3")
  internal static let glaf4 = ImageAsset(name: "glaf_4")
  internal static let glaf5 = ImageAsset(name: "glaf_5")
  internal static let glaf6 = ImageAsset(name: "glaf_6")
  internal static let glaf7 = ImageAsset(name: "glaf_7")
  internal static let glaf8 = ImageAsset(name: "glaf_8")
  internal static let glaf9 = ImageAsset(name: "glaf_9")
  internal static let greenRectangle = ImageAsset(name: "greenRectangle")
  internal static let iPhone = ImageAsset(name: "iPhone-")
  internal static let iPhone0 = ImageAsset(name: "iPhone0")
  internal static let iPhone1 = ImageAsset(name: "iPhone1")
  internal static let iPhone2 = ImageAsset(name: "iPhone2")
  internal static let iPhone3 = ImageAsset(name: "iPhone3")
  internal static let iPhone4 = ImageAsset(name: "iPhone4")
  internal static let iPhone6 = ImageAsset(name: "iPhone6")
  internal static let iPhone7 = ImageAsset(name: "iPhone7")
  internal static let leafDarkGreen = ImageAsset(name: "leafDarkGreen")
  internal static let leafLightGreen = ImageAsset(name: "leafLightGreen")
  internal static let leafRed = ImageAsset(name: "leafRed")
  internal static let leafYellow = ImageAsset(name: "leafYellow")
  internal static let question = ImageAsset(name: "question")
  internal static let redRectangle = ImageAsset(name: "redRectangle")
  internal static let simpleDarkLeaf = ImageAsset(name: "simpleDarkLeaf")
  internal static let simpleLightLeaf = ImageAsset(name: "simpleLightLeaf")
  internal static let simpleRedLeaf = ImageAsset(name: "simpleRedLeaf")
  internal static let simpleYellowLeaf = ImageAsset(name: "simpleYellowLeaf")
  internal static let stemGreen = ImageAsset(name: "stemGreen")
  internal static let stemRed = ImageAsset(name: "stemRed")
  internal static let stemSmallGreen = ImageAsset(name: "stemSmallGreen")
  internal static let stemYellow = ImageAsset(name: "stemYellow")
  internal static let tableaf = ImageAsset(name: "tableaf")
  internal static let currentPlace = ImageAsset(name: "currentPlace")
  internal static let goal = ImageAsset(name: "goal")
  internal static let start = ImageAsset(name: "start")
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

internal final class ColorAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Color = NSColor
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Color = UIColor
  #endif

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  internal private(set) lazy var color: Color = {
    guard let color = Color(asset: self) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }()

  #if os(iOS) || os(tvOS)
  @available(iOS 11.0, tvOS 11.0, *)
  internal func color(compatibleWith traitCollection: UITraitCollection) -> Color {
    let bundle = BundleToken.bundle
    guard let color = Color(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }
  #endif

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
  internal private(set) lazy var swiftUIColor: SwiftUI.Color = {
    SwiftUI.Color(asset: self)
  }()
  #endif

  fileprivate init(name: String) {
    self.name = name
  }
}

internal extension ColorAsset.Color {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  convenience init?(asset: ColorAsset) {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
internal extension SwiftUI.Color {
  init(asset: ColorAsset) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle)
  }
}
#endif

internal struct ImageAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Image = UIImage
  #endif

  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, macOS 10.7, *)
  internal var image: Image {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    let name = NSImage.Name(self.name)
    let image = (bundle == .main) ? NSImage(named: name) : bundle.image(forResource: name)
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }

  #if os(iOS) || os(tvOS)
  @available(iOS 8.0, tvOS 9.0, *)
  internal func image(compatibleWith traitCollection: UITraitCollection) -> Image {
    let bundle = BundleToken.bundle
    guard let result = Image(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }
  #endif

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
  internal var swiftUIImage: SwiftUI.Image {
    SwiftUI.Image(asset: self)
  }
  #endif
}

internal extension ImageAsset.Image {
  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, *)
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init?(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = BundleToken.bundle
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
internal extension SwiftUI.Image {
  init(asset: ImageAsset) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle)
  }

  init(asset: ImageAsset, label: Text) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle, label: label)
  }

  init(decorative asset: ImageAsset) {
    let bundle = BundleToken.bundle
    self.init(decorative: asset.name, bundle: bundle)
  }
}
#endif

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
