//  
//  Copyright © 2020 Jeff Watkins. All rights reserved.
//

import UIKit

@IBDesignable
open class Button: UIControl {

    @objc
    public enum ContentLayout: Int {
        /// Arrange content horizontally with the traditional layout of icon followed by title.
        case horizontal
        /// Arrange content horizontally with the reverse of the traditional layout with the title followed by the icon.
        case horizontalReversed
        /// Arrange content vertically with the icon followed by the title.
        case vertical
        /// Arrange content vertically with the title followed by the icon.
        case verticalReversed
    }

    /// The corner radius of a button.
    let cornerRadius = CGFloat(8)

    var imageView: UIImageView? = nil
    var titleLabel: UILabel? = nil
    var subtitleLabel: UILabel? = nil
    var backgroundView: UIView? = nil

    /// Overridden background colour to determine the pill background colour
    var _buttonBackgroundColor: UIColor?
    public override var backgroundColor: UIColor? {
        get { _buttonBackgroundColor }
        set {
            _buttonBackgroundColor = newValue
            self.updateBackgroundView()
        }
    }

    @IBInspectable
    public var borderColor: UIColor? {
        didSet {
            self.updateBackgroundView()
        }
    }

    @IBInspectable
    public var image: UIImage? {
        didSet {
            self.updateImageView()
        }
    }

    @IBInspectable
    public var title: String? {
        didSet {
            self.updateTitleViews()
        }
    }

    @IBInspectable
    public var subtitle: String? {
        didSet {
            self.updateTitleViews()
        }
    }

    @IBInspectable
    public var contentLayout: ContentLayout = ContentLayout.horizontal {
        didSet {
            self.setNeedsUpdateConstraints()
        }
    }

    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        self.title = "Title"
        self.subtitle = "Subtitle"
        self.image = UIImage(systemName: "questionmark.circle.fill")
        self.backgroundColor = self.tintColor
        self.tintColor = UIColor.systemBackground
    }
    
    /// The current background colour based on the active state
    var currentBackgroundColor: UIColor? {
        guard let backgroundColor = self._buttonBackgroundColor else { return nil }

        guard self.isEnabled else { return UIColor.quaternaryLabel }
        if self.isHighlighted {
            return backgroundColor.withAlphaComponent(0.5)
        }
        return backgroundColor
    }

    var currentBorderColor: UIColor? {
        guard let borderColor = self.borderColor else { return nil }

        guard self.isEnabled else { return UIColor.tertiaryLabel }
        if self.isHighlighted {
            return borderColor.withAlphaComponent(0.75)
        }
        return borderColor
    }

    var currentTextColor: UIColor {
        let textColor = self.tintColor!

        guard self.isEnabled else { return UIColor.tertiaryLabel }
        if self.isHighlighted {
            return textColor.withAlphaComponent(0.75)
        }
        return textColor
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.accessibilityTraits = UIAccessibilityTraits.button
        self.isAccessibilityElement = true
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        if let title = coder.decodeObject(forKey: "title") as? String {
            self.title = title
        }
        if let subtitle = coder.decodeObject(forKey: "subtitle") as? String {
            self.subtitle = subtitle
        }
        if let image = coder.decodeObject(of: UIImage.self, forKey: "image") {
            self.image = image
        }
        if let borderColor = coder.decodeObject(of: UIColor.self, forKey: "borderColor") {
            self.borderColor = borderColor
        }
        self.accessibilityTraits = UIAccessibilityTraits.button
        self.isAccessibilityElement = true
    }

    public override func encode(with coder: NSCoder) {
        super.encode(with: coder)
        coder.encodeConditionalObject(self.title, forKey: "title")
        coder.encodeConditionalObject(self.subtitle, forKey: "subtitle")
        coder.encodeConditionalObject(self.image, forKey: "image")
        coder.encodeConditionalObject(self.borderColor, forKey: "borderColor")
    }
    
    func updateBackgroundView() {
        if self.backgroundView == nil {
            let backgroundView = UIView()
            backgroundView.isUserInteractionEnabled = false
            backgroundView.translatesAutoresizingMaskIntoConstraints = false
            if let last = self.subviews.last {
                self.insertSubview(backgroundView, belowSubview: last)
            } else {
                self.addSubview(backgroundView)
            }
            NSLayoutConstraint.activate([
                backgroundView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                backgroundView.topAnchor.constraint(equalTo: self.topAnchor),
                backgroundView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                backgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
            ])

            self.backgroundView = backgroundView
        }

        guard let backgroundView = self.backgroundView else { return }
        backgroundView.layer.cornerRadius = self.cornerRadius

        if let buttonBackgroundColor = self.currentBackgroundColor {
            backgroundView.backgroundColor = buttonBackgroundColor
        } else {
            backgroundView.backgroundColor = nil
        }

        if let borderColor = self.currentBorderColor {
            backgroundView.layer.borderWidth = 1
            backgroundView.layer.borderColor = borderColor.cgColor
            backgroundView.layer.cornerCurve = .continuous
        } else {
            backgroundView.layer.borderColor = nil
        }
    }

    var imageConstraints = [NSLayoutConstraint]()
    var imageWidthConstraint: NSLayoutConstraint?

    func updateImageHeightConstraint() {
        guard let imageView = self.imageView else { return }
        guard let image = imageView.image else { return }

        let titleFont: UIFont

        if let titleLabel = self.titleLabel {
            titleFont = titleLabel.font
        } else {
            titleFont = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)
        }

        let lineHeight = titleFont.lineHeight

        let size = image.size
        let aspectRatio = size.width / size.height
        let width = lineHeight * aspectRatio

        if self.imageWidthConstraint == nil {
            self.imageWidthConstraint = imageView.widthAnchor.constraint(equalToConstant: width)
            self.imageWidthConstraint?.priority = UILayoutPriority.defaultHigh
            self.imageWidthConstraint?.isActive = true
        } else {
            self.imageWidthConstraint?.constant = width
        }
    }

    func updateImageView() {
        if self.imageView == nil {
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.tintColor = self.currentTextColor
            imageView.setContentCompressionResistancePriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)

            if let backgroundView = self.backgroundView {
                self.insertSubview(imageView, aboveSubview: backgroundView)
            } else {
                self.addSubview(imageView)
            }
            self.setNeedsUpdateConstraints()
            self.imageView = imageView
        }

        guard let imageView = self.imageView else { return }

        NSLayoutConstraint.deactivate(self.imageConstraints)

        if let image = self.image {
            imageView.image = image
            let size = image.size
            let aspectRatio = size.height / size.width
            self.imageConstraints = [
                imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: aspectRatio)
            ]
            NSLayoutConstraint.activate(self.imageConstraints)
            self.updateImageHeightConstraint()
        } else {
            imageView.image = nil
        }

    }

    let largestContentSizeCategory = UITraitCollection(preferredContentSizeCategory: UIContentSizeCategory.accessibilityMedium)
    let normalContentSizeCategory = UITraitCollection(preferredContentSizeCategory: UIContentSizeCategory.large)

    var titleFont: UIFont {
        let largestFont = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body, compatibleWith: self.largestContentSizeCategory)
        let baseFont = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body, compatibleWith: self.normalContentSizeCategory)

        return UIFontMetrics(forTextStyle: UIFont.TextStyle.body).scaledFont(for: baseFont, maximumPointSize: largestFont.pointSize, compatibleWith: self.normalContentSizeCategory)
    }

    var subtitleFont: UIFont {
        let largestFont = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.footnote, compatibleWith: self.largestContentSizeCategory)
        let baseFont = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.footnote, compatibleWith: self.normalContentSizeCategory)

        return UIFontMetrics(forTextStyle: UIFont.TextStyle.footnote).scaledFont(for: baseFont, maximumPointSize: largestFont.pointSize, compatibleWith: self.normalContentSizeCategory)
    }

    func updateTitleViews() {
        var accessibilityParts = [String]()

        if self.title != nil && self.titleLabel == nil {
            let titleLabel = UILabel()
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.font = self.titleFont
            titleLabel.adjustsFontForContentSizeCategory = true
            titleLabel.setContentCompressionResistancePriority(UILayoutPriority.defaultHigh - 10, for: NSLayoutConstraint.Axis.horizontal)
            titleLabel.textColor = self.currentTextColor
            titleLabel.textAlignment = NSTextAlignment.center
            titleLabel.numberOfLines = 0
            self.titleLabel = titleLabel
            if let backgroundView = self.backgroundView {
                self.insertSubview(titleLabel, aboveSubview: backgroundView)
            } else {
                self.addSubview(titleLabel)
            }
        }

        if self.subtitle != nil && self.subtitleLabel == nil {
            let subtitleLabel = UILabel()
            subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
            subtitleLabel.setContentCompressionResistancePriority(UILayoutPriority.defaultHigh - 10, for: NSLayoutConstraint.Axis.horizontal)
            subtitleLabel.font = self.subtitleFont
            subtitleLabel.adjustsFontForContentSizeCategory = true
            subtitleLabel.textColor = self.currentTextColor
            subtitleLabel.textAlignment = NSTextAlignment.center
            subtitleLabel.numberOfLines = 0
            self.subtitleLabel = subtitleLabel
            if let backgroundView = self.backgroundView {
                self.insertSubview(subtitleLabel, aboveSubview: backgroundView)
            } else {
                self.addSubview(subtitleLabel)
            }
        }

        if let title = self.title, let titleLabel = self.titleLabel {
            titleLabel.text = title
            accessibilityParts.append(title)
        }

        if let subtitle = self.subtitle, let subtitleLabel = self.subtitleLabel {
            subtitleLabel.text = subtitle
            accessibilityParts.append(subtitle)
        }

        self.accessibilityLabel = accessibilityParts.joined(separator: "\n\n")
    }

    // MARK: - constraint handling
    lazy var titleLayoutGuide: UILayoutGuide = {
        let guide = UILayoutGuide()
        guide.identifier = "title layout guide"
        self.addLayoutGuide(guide)
        return guide
    }()

    lazy var contentLayoutGuide: UILayoutGuide = {
        let guide = UILayoutGuide()
        guide.identifier = "content layout guide"
        self.addLayoutGuide(guide)
        return guide
    }()

    var buttonConstraints = [NSLayoutConstraint]()

    public override func setNeedsUpdateConstraints() {
        NSLayoutConstraint.deactivate(self.buttonConstraints)
        self.buttonConstraints = []
        super.setNeedsUpdateConstraints()
    }

    func constraintsForTitleLabelsInLayoutGuide() -> [NSLayoutConstraint] {
        let titleLayoutGuide = self.titleLayoutGuide
        var constraints: [NSLayoutConstraint] = []

        if let titleLabel = self.titleLabel {
            constraints += [
                titleLabel.topAnchor.constraint(equalTo: titleLayoutGuide.topAnchor),
                titleLabel.leadingAnchor.constraint(equalTo: titleLayoutGuide.leadingAnchor),
                titleLabel.trailingAnchor.constraint(equalTo: titleLayoutGuide.trailingAnchor),
            ]

            // When there's a title & subtitle, make them the same width and constrain their baselines. Othewise, constrain the bottom of the title label
            if let subtitleLabel = self.subtitleLabel {
                constraints += [
                    titleLabel.widthAnchor.constraint(equalTo: subtitleLabel.widthAnchor, multiplier: 1),
                    subtitleLabel.firstBaselineAnchor.constraint(equalToSystemSpacingBelow: titleLabel.lastBaselineAnchor, multiplier: 1)
                ]
            } else {
                constraints += [
                    titleLabel.bottomAnchor.constraint(equalTo: titleLayoutGuide.bottomAnchor)
                ]
            }
        }

        if let subtitleLabel = self.subtitleLabel {
            constraints += [
                subtitleLabel.leadingAnchor.constraint(equalTo: titleLayoutGuide.leadingAnchor),
                subtitleLabel.trailingAnchor.constraint(equalTo: titleLayoutGuide.trailingAnchor),
                subtitleLabel.bottomAnchor.constraint(equalTo: titleLayoutGuide.bottomAnchor)
            ]

            // If titleLabel is nil, we'll need to constrain subtitle label to the top of titleLayoutGuide
            if self.titleLabel == nil {
                constraints += [
                    subtitleLabel.topAnchor.constraint(equalTo: titleLayoutGuide.topAnchor)
                ]
            }
        }

        // Ensure the titleLayoutGuide is within the contentLayoutGuide and within the button.
        constraints += [
            titleLayoutGuide.leadingAnchor.constraint(greaterThanOrEqualTo: self.leadingAnchor),
            titleLayoutGuide.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor),
            titleLayoutGuide.topAnchor.constraint(greaterThanOrEqualTo: contentLayoutGuide.topAnchor),
            titleLayoutGuide.bottomAnchor.constraint(lessThanOrEqualTo: contentLayoutGuide.bottomAnchor),
            titleLayoutGuide.topAnchor.constraint(greaterThanOrEqualTo: self.topAnchor),
            titleLayoutGuide.bottomAnchor.constraint(lessThanOrEqualTo: self.bottomAnchor),
        ]

        return constraints
    }

    func constraintsForContentLayoutGuide() -> [NSLayoutConstraint] {
        let contentLayoutGuide = self.contentLayoutGuide
        return [
            contentLayoutGuide.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            contentLayoutGuide.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            contentLayoutGuide.topAnchor.constraint(greaterThanOrEqualTo: self.topAnchor),
            contentLayoutGuide.leadingAnchor.constraint(greaterThanOrEqualTo: self.leadingAnchor),
            contentLayoutGuide.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor),
            contentLayoutGuide.bottomAnchor.constraint(lessThanOrEqualTo: self.bottomAnchor)
        ]
    }

    func constraintsForBackgroundView() -> [NSLayoutConstraint] {
        guard let backgroundView = self.backgroundView else { return [] }

        let cornerRadius = self.cornerRadius
        let halfRadius = CGFloat.floorToPixel(cornerRadius / 2.0)
        let contentLayoutGuide = self.contentLayoutGuide

        return [
            contentLayoutGuide.leadingAnchor.constraint(greaterThanOrEqualTo: backgroundView.leadingAnchor, constant: cornerRadius),
            contentLayoutGuide.topAnchor.constraint(greaterThanOrEqualTo: backgroundView.topAnchor, constant: halfRadius),
            backgroundView.trailingAnchor.constraint(greaterThanOrEqualTo: contentLayoutGuide.trailingAnchor, constant: cornerRadius),
            backgroundView.bottomAnchor.constraint(greaterThanOrEqualTo: contentLayoutGuide.bottomAnchor, constant: halfRadius)
        ]
    }

    func createHorizontalConstraints() {
        var constraints: [NSLayoutConstraint] = []

        let contentLayoutGuide = self.contentLayoutGuide
        let reversed = (self.contentLayout == .horizontalReversed)

        if let imageView = self.imageView {
            if reversed {
                constraints += [
                    imageView.trailingAnchor.constraint(equalTo: contentLayoutGuide.trailingAnchor)
                ]
            } else {
                constraints += [
                    imageView.leadingAnchor.constraint(equalTo: contentLayoutGuide.leadingAnchor)
                ]
            }

            constraints += [
                imageView.leadingAnchor.constraint(greaterThanOrEqualTo: self.leadingAnchor),
                imageView.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor),
                imageView.topAnchor.constraint(greaterThanOrEqualTo: self.topAnchor),
                imageView.bottomAnchor.constraint(lessThanOrEqualTo: self.bottomAnchor)
            ]

            // When there's a title or subtitle, we need to constrain the image against the titleLayoutGuide, otherwise, fully constrain the image against the contentLayoutGuide
            if self.titleLabel != nil || self.subtitleLabel != nil {
                let titleLayoutGuide = self.titleLayoutGuide
                if reversed {
                    constraints += [
                        imageView.leadingAnchor.constraint(equalToSystemSpacingAfter: titleLayoutGuide.trailingAnchor, multiplier: 1),
                        titleLayoutGuide.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
                    ]
                } else {
                    constraints += [
                        titleLayoutGuide.leadingAnchor.constraint(equalToSystemSpacingAfter: imageView.trailingAnchor, multiplier: 1),
                        titleLayoutGuide.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
                    ]
                }
            } else {
                constraints += [
                    imageView.centerYAnchor.constraint(equalTo: contentLayoutGuide.centerYAnchor),
                    imageView.leadingAnchor.constraint(equalTo: contentLayoutGuide.leadingAnchor)
                ]
            }
        }

        if self.titleLabel != nil || self.subtitleLabel != nil {
            let titleLayoutGuide = self.titleLayoutGuide
            constraints += self.constraintsForTitleLabelsInLayoutGuide()

            // Now constrain titleLayoutGuide against contentLayoutGuide
            constraints += [
                titleLayoutGuide.centerYAnchor.constraint(greaterThanOrEqualTo: contentLayoutGuide.centerYAnchor)
            ]

            if reversed {
                constraints += [
                    titleLayoutGuide.leadingAnchor.constraint(equalTo: contentLayoutGuide.leadingAnchor)
                ]
            } else {
                constraints += [
                    titleLayoutGuide.trailingAnchor.constraint(equalTo: contentLayoutGuide.trailingAnchor)
                ]
            }

            // If there's no image then constrain against the remaining edge to the content layout guide
            if self.imageView == nil {
                if reversed {
                    constraints += [
                        titleLayoutGuide.trailingAnchor.constraint(equalTo: contentLayoutGuide.trailingAnchor)
                    ]
                } else {
                    constraints += [
                        titleLayoutGuide.leadingAnchor.constraint(equalTo: contentLayoutGuide.leadingAnchor)
                    ]
                }
            }
        }

        constraints += self.constraintsForContentLayoutGuide()
        constraints += self.constraintsForBackgroundView()

        NSLayoutConstraint.activate(constraints)
        self.buttonConstraints = constraints
    }

    func createVerticalConstraints() {
        var constraints: [NSLayoutConstraint] = []

        let contentLayoutGuide = self.contentLayoutGuide
        let reversed = (self.contentLayout == .verticalReversed)

        if let imageView = self.imageView {
            constraints += [
                imageView.leadingAnchor.constraint(greaterThanOrEqualTo: self.leadingAnchor),
                imageView.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor),
                imageView.topAnchor.constraint(greaterThanOrEqualTo: self.topAnchor),
                imageView.bottomAnchor.constraint(lessThanOrEqualTo: self.bottomAnchor),
                imageView.centerXAnchor.constraint(equalTo: contentLayoutGuide.centerXAnchor)
            ]

            if reversed {
                constraints += [
                    imageView.bottomAnchor.constraint(equalTo: contentLayoutGuide.bottomAnchor)
                ]
            } else {
                constraints += [
                    imageView.topAnchor.constraint(equalTo: contentLayoutGuide.topAnchor)
                ]
            }

            // Apply constraints appropriate to an image with a title and/or subtitle
            if self.titleLabel != nil || self.subtitleLabel != nil {
                let titleLayoutGuide = self.titleLayoutGuide

                constraints += [
                    imageView.centerXAnchor.constraint(equalTo: titleLayoutGuide.centerXAnchor)
                ]

                if reversed {
                    if let lastBaselineLabel = self.subtitleLabel ?? self.titleLabel {
                        constraints += [
                            imageView.topAnchor.constraint(equalToSystemSpacingBelow: lastBaselineLabel.lastBaselineAnchor, multiplier: 1)
                        ]
                    }
                } else {
                    if let firstBaselineLabel = self.titleLabel ?? self.subtitleLabel {
                        constraints += [
                            firstBaselineLabel.firstBaselineAnchor.constraint(equalToSystemSpacingBelow: imageView.bottomAnchor, multiplier: 1)
                        ]
                    }
                }
            }
        }

        if self.titleLabel != nil || self.subtitleLabel != nil {
            let titleLayoutGuide = self.titleLayoutGuide
            constraints += self.constraintsForTitleLabelsInLayoutGuide()

            // Now constrain titleLayoutGuide against contentLayoutGuide
            constraints += [
                titleLayoutGuide.centerXAnchor.constraint(greaterThanOrEqualTo: contentLayoutGuide.centerXAnchor),
                titleLayoutGuide.leadingAnchor.constraint(equalTo: contentLayoutGuide.leadingAnchor),
                titleLayoutGuide.trailingAnchor.constraint(equalTo: contentLayoutGuide.trailingAnchor)
            ]

            if reversed {
                constraints += [
                    titleLayoutGuide.topAnchor.constraint(equalTo: contentLayoutGuide.topAnchor)
                ]
            } else {
                constraints += [
                    titleLayoutGuide.bottomAnchor.constraint(equalTo: contentLayoutGuide.bottomAnchor)
                ]
            }

            if imageView == nil {
                if reversed {
                    constraints += [
                        titleLayoutGuide.bottomAnchor.constraint(equalTo: contentLayoutGuide.bottomAnchor)
                    ]
                } else {
                    constraints += [
                        titleLayoutGuide.topAnchor.constraint(equalTo: contentLayoutGuide.topAnchor)
                    ]
                }
            }
        }

        constraints += self.constraintsForContentLayoutGuide()
        constraints += self.constraintsForBackgroundView()

        NSLayoutConstraint.activate(constraints)
        self.buttonConstraints = constraints
    }

    public override func updateConstraints() {
        guard self.buttonConstraints.isEmpty else { super.updateConstraints(); return }

        // Update constraints
        switch self.contentLayout {
            case .horizontal, .horizontalReversed:
                self.createHorizontalConstraints()
            case .vertical, .verticalReversed:
                self.createVerticalConstraints()
        }

        super.updateConstraints()
    }


    func updateColors() {
        let textColor = self.currentTextColor
        if let imageView = self.imageView {
            imageView.tintColor = textColor
        }
        if let titleLabel = self.titleLabel {
            titleLabel.textColor = textColor
        }
        if let subtitleLabel = self.subtitleLabel {
            subtitleLabel.textColor = textColor
        }
        if self.backgroundView != nil {
            self.updateBackgroundView()
        }
    }

    public override func tintColorDidChange() {
        super.tintColorDidChange()
        self.updateColors()
    }

    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        guard previousTraitCollection?.preferredContentSizeCategory != self.traitCollection.preferredContentSizeCategory else { return }
        self.updateImageHeightConstraint()
    }

    // MARK: - control overrides
    public override var isHighlighted: Bool {
        didSet {
            self.updateColors()
        }
    }

    public override var isEnabled: Bool {
        didSet {
            self.updateColors()
        }
    }

    @objc public var _controlEventsForActionTriggered: UIControl.Event {
        return [UIControl.Event.touchUpInside]
    }

}
