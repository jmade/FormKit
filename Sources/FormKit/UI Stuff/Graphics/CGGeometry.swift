//
//  CGGeometry.swift
//  FW Device
//
//  Created by Justin Madewell on 11/16/18.
//  Copyright © 2018 Jmade Technologies. All rights reserved.
//

import UIKit


//: MARK: - Gometery -


//: MARK: - CGFloat -
extension CGFloat {
    
    public func toRadians() -> CGFloat {
        return self * (.pi/180.0)
    }
    
    public func squaredSize() -> CGSize {
        return CGSize(self, self)
    }
    
    public func squaredRect() -> CGRect {
        return CGRect(origin: .zero, size: self.squaredSize())
    }
    
}


// MARK: - CGPoint -
extension CGPoint {
    
    /// Creates a point with unnamed arguments.
    public init(_ x: CGFloat, _ y: CGFloat) {
        self.init()
        self.x = x
        self.y = y
    }
    
    /// Returns a copy with the x value changed.
    public func with(x: CGFloat) -> CGPoint {
        return CGPoint(x: x, y: y)
    }
    /// Returns a copy with the y value changed.
    public func with(y: CGFloat) -> CGPoint {
        return CGPoint(x: x, y: y)
    }
    
    public func distanceSquared(from: CGPoint, to: CGPoint) -> CGFloat {
        return (from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y);
    }
    
    public func distance(from: CGPoint, to: CGPoint) -> CGFloat {
        return sqrt(distanceSquared(from: from, to: to));
    }
    
}

// MARK: CGSize
extension CGSize {
    
    /// Creates a size with unnamed arguments.
    public init(_ width: CGFloat, _ height: CGFloat) {
        self.init()
        self.width = width
        self.height = height
    }
    
    /// Returns a copy with the width value changed.
    public func with(width: CGFloat) -> CGSize {
        return CGSize(width: width, height: height)
    }
    /// Returns a copy with the height value changed.
    public func with(height: CGFloat) -> CGSize {
        return CGSize(width: width, height: height)
    }
    
    
    public func rect() -> CGRect {
        return  CGRect(origin: .zero, size: self)
    }
    
}

// MARK: CGRect
extension CGRect {
    
    /// Creates a rect with unnamed arguments.
    public init(_ origin: CGPoint, _ size: CGSize) {
        self.init()
        self.origin = origin
        self.size = size
    }
    
    /// Creates a rect with unnamed arguments.
    public init(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) {
        self.init()
        self.origin = CGPoint(x: x, y: y)
        self.size = CGSize(width: width, height: height)
    }
    
    // MARK: access shortcuts
    /// Alias for origin.x.
    public var x: CGFloat {
        get {return origin.x}
        set {origin.x = newValue}
    }
    /// Alias for origin.y.
    public var y: CGFloat {
        get {return origin.y}
        set {origin.y = newValue}
    }
    
    /// Accesses origin.x + 0.5 * size.width.
    public var centerX: CGFloat {
        get {return x + width * 0.5}
        set {x = newValue - width * 0.5}
    }
    /// Accesses origin.y + 0.5 * size.height.
    public var centerY: CGFloat {
        get {return y + height * 0.5}
        set {y = newValue - height * 0.5}
    }
    
    // MARK: edges
    /// Alias for origin.x.
    public var left: CGFloat {
        get {return origin.x}
        set {origin.x = newValue}
    }
    /// Accesses origin.x + size.width.
    public var right: CGFloat {
        get {return x + width}
        set {x = newValue - width}
    }
    
    /// Alias for origin.y.
    public var top: CGFloat {
        get {return y}
        set {y = newValue}
    }
    /// Accesses origin.y + size.height.
    public var bottom: CGFloat {
        get {return y + height}
        set {y = newValue - height}
    }
    
    // MARK: points
    /// Accesses the point at the top left corner.
    public var topLeft: CGPoint {
        get {return CGPoint(x: left, y: top)}
        set {left = newValue.x; top = newValue.y}
    }
    /// Accesses the point at the middle of the top edge.
    public var topCenter: CGPoint {
        get {return CGPoint(x: centerX, y: top)}
        set {centerX = newValue.x; top = newValue.y}
    }
    /// Accesses the point at the top right corner.
    public var topRight: CGPoint {
        get {return CGPoint(x: right, y: top)}
        set {right = newValue.x; top = newValue.y}
    }
    
    /// Accesses the point at the middle of the left edge.
    public var centerLeft: CGPoint {
        get {return CGPoint(x: left, y: centerY)}
        set {left = newValue.x; centerY = newValue.y}
    }
    /// Accesses the point at the center.
    public var center: CGPoint {
        get {return CGPoint(x: centerX, y: centerY)}
        set {centerX = newValue.x; centerY = newValue.y}
    }
    /// Accesses the point at the middle of the right edge.
    public var centerRight: CGPoint {
        get {return CGPoint(x: right, y: centerY)}
        set {right = newValue.x; centerY = newValue.y}
    }
    
    /// Accesses the point at the bottom left corner.
    public var bottomLeft: CGPoint {
        get {return CGPoint(x: left, y: bottom)}
        set {left = newValue.x; bottom = newValue.y}
    }
    /// Accesses the point at the middle of the bottom edge.
    public var bottomCenter: CGPoint {
        get {return CGPoint(x: centerX, y: bottom)}
        set {centerX = newValue.x; bottom = newValue.y}
    }
    /// Accesses the point at the bottom right corner.
    public var bottomRight: CGPoint {
        get {return CGPoint(x: right, y: bottom)}
        set {right = newValue.x; bottom = newValue.y}
    }
    
    // MARK: with
    /// Returns a copy with the origin value changed.
    public func with(origin: CGPoint) -> CGRect {
        return CGRect(origin: origin, size: size)
    }
    /// Returns a copy with the x and y values changed.
    public func with(x: CGFloat, y: CGFloat) -> CGRect {
        return with(origin: CGPoint(x: x, y: y))
    }
    /// Returns a copy with the x value changed.
    public func with(x: CGFloat) -> CGRect {
        return with(x: x, y: y)
    }
    /// Returns a copy with the y value changed.
    public func with(y: CGFloat) -> CGRect {
        return with(x: x, y: y)
    }
}
