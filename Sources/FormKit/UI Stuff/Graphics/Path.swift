//
//  Path.swift
//  FW Device
//
//  Created by Justin Madewell on 11/16/18.
//  Copyright © 2018 Jmade Technologies. All rights reserved.
//

import UIKit

public struct Path {}

extension Path {
    
    static
        func makeChevronDownPath(_ size:CGFloat,_ length:CGFloat = 0.5) -> UIBezierPath {
        let path = UIBezierPath()
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        path.lineWidth = size/10
        let inset = (size - (size * length))/2
        let topInset = inset
        let bottomInset = size - inset
        let start = CGPoint(x:path.lineWidth, y: topInset+path.lineWidth)
        let mid = CGPoint(x: size/2, y: bottomInset)
        let end = CGPoint(x: size-path.lineWidth, y: topInset+path.lineWidth)
        path.move(to: start)
        path.addLine(to: mid)
        path.move(to: end)
        path.addLine(to: mid)
        path.close()
        return path
    }
    
    
    static
        func makeChevronRightPath(_ size:CGFloat,_ length:CGFloat = 0.5) -> UIBezierPath {
        let path = UIBezierPath()
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        path.lineWidth = size/10
        let inset = (size - (size * length))/2
        let start = CGPoint(x: inset, y: path.lineWidth)
        let mid = CGPoint(x: inset, y: size/2)
        let end = CGPoint(x: inset, y: size - path.lineWidth)
        path.move(to: start)
        path.addLine(to: mid)
        path.move(to: end)
        path.addLine(to: mid)
        path.close()
        return path
    }
    
    static
        func makeChevronLeftPath(_ size:CGFloat,_ length:CGFloat = 0.5) -> UIBezierPath {
        let path = UIBezierPath()
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        path.lineWidth = size/10
        let inset = (size - (size * length))/2
        let start = CGPoint(x: inset, y: path.lineWidth)
        let mid = CGPoint(x:size - inset, y: size/2)
        let end = CGPoint(x: inset, y: size - path.lineWidth)
        path.move(to: start)
        path.addLine(to: mid)
        path.move(to: end)
        path.addLine(to: mid)
        path.close()
        return path
    }
    
    
    static
        func makeNextChevronPath(_ size:CGFloat,_ length:CGFloat = 0.5) -> UIBezierPath {
        let path = UIBezierPath()
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        path.lineWidth = size/20
        let rect = CGRect(x: 0, y: 0, width: size * 2/3 , height: size).insetBy(dx: size/10, dy: size/10)
        path.move(to: rect.topLeft)
        path.addLine(to: rect.centerRight)
        path.move(to: rect.bottomLeft)
        path.addLine(to: rect.centerRight)
        path.close()
        return path
    }
    
    static
        func makePreviousChevronPath(_ size:CGFloat,_ length:CGFloat = 0.5) -> UIBezierPath {
        let path = UIBezierPath()
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        path.lineWidth = size/20
        let rect = CGRect(x: 0, y: 0, width: size * 2/3 , height: size).insetBy(dx: size/10, dy: size/10)
        path.move(to: rect.topRight)
        path.addLine(to: rect.centerLeft)
        path.move(to: rect.bottomRight)
        path.addLine(to: rect.centerLeft)
        path.close()
        return path
    }
    
    
    static
        func makeChevronPath(_ size:CGFloat,_ length:CGFloat = 0.5,_ lineWidth:CGFloat = 20.0) -> UIBezierPath {
        let path = UIBezierPath()
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        path.lineWidth = size/lineWidth
        let rect = CGRect(x: 0, y: 0, width: size * 2/3 , height: size).insetBy(dx: size/10, dy: size/10)
        path.move(to: rect.topLeft)
        path.addLine(to: rect.centerRight)
        path.move(to: rect.bottomLeft)
        path.addLine(to: rect.centerRight)
        path.close()
        return path
    }
}
