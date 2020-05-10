//  
//  Copyright © 2020 Jeff Watkins. All rights reserved.
//

import UIKit

extension UIEdgeInsets {
    init(all dimension: CGFloat) {
        self.init(top: dimension, left: dimension, bottom: dimension, right: dimension)
    }
}

extension CGFloat {
    static var onePixel: CGFloat = {
        let screenScale = UIScreen.main.scale
        return 1.0 / screenScale
    }()

    static func floorToPixel(_ value: CGFloat) -> CGFloat {
        let screenScale = UIScreen.main.scale
        return floor(value * screenScale) / screenScale
    }

    static func ceilToPixel(_ value: CGFloat) -> CGFloat {
        let screenScale = UIScreen.main.scale
        return ceil(value * screenScale) / screenScale
    }
}

extension CGSize {
    static var onePixel: CGSize = {
        return CGSize(width: .onePixel, height: .onePixel)
    }()

    func floorToPixel() -> CGSize {
        return CGSize(width: CGFloat.floorToPixel(self.width), height: CGFloat.floorToPixel(self.height))
    }

    func ceilToPixel() -> CGSize {
        return CGSize(width: CGFloat.ceilToPixel(self.width), height: CGFloat.ceilToPixel(self.height))
    }
}

extension CGPoint {
    static var onePixel: CGPoint = {
        return CGPoint(x: .onePixel, y: .onePixel)
    }()

    func floorToPixel() -> CGPoint {
        return CGPoint(x: CGFloat.floorToPixel(self.x), y: CGFloat.floorToPixel(self.y))
    }

    func ceilToPixel() -> CGPoint {
        return CGPoint(x: CGFloat.ceilToPixel(self.x), y: CGFloat.ceilToPixel(self.y))
    }
}

extension CGRect {
    static var onePixel: CGRect = {
        return CGRect(x: .onePixel, y: .onePixel, width: .onePixel, height: .onePixel)
    }()

    func floorToPixel() -> CGRect {
        return CGRect(x: CGFloat.floorToPixel(self.minX), y: CGFloat.floorToPixel(self.minY), width: CGFloat.floorToPixel(self.width), height: CGFloat.floorToPixel(self.height))
    }

    func ceilToPixel() -> CGRect {
        return CGRect(x: CGFloat.ceilToPixel(self.minX), y: CGFloat.ceilToPixel(self.minY), width: CGFloat.ceilToPixel(self.width), height: CGFloat.ceilToPixel(self.height))
    }
}
