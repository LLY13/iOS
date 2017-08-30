//
//  ShapePath.swift
//  EasyDraw
//
//  Created by Longyi Li on 17/08/17.
//  Copyright © 2017 Longyi Li. All rights reserved.
//

import UIKit

class ShapePath: UIBezierPath
{
    //function to draw oval
    func oval(startPoint: CGPoint, translationPoint: CGPoint) -> UIBezierPath
    {
        return UIBezierPath(ovalIn: CGRect(x: startPoint.x, y: startPoint.y, width: translationPoint.x, height: translationPoint.y))
    }
    
    //function to draw rectangle
    func rectangle(startPoint: CGPoint, translationPoint: CGPoint) -> UIBezierPath {
        return UIBezierPath(rect: CGRect(x: startPoint.x, y: startPoint.y, width: translationPoint.x, height: translationPoint.y))
    }
    
    //function to draw line
    func line(startPoint: CGPoint, endPoint: CGPoint) -> UIBezierPath
    {
        let linePath = UIBezierPath()
        linePath.move(to: startPoint)
        linePath.addLine(to: endPoint)
        return linePath
    }
    
    func triangle(startPoint: CGPoint, endPoint: CGPoint) -> UIBezierPath{
        let linePath = UIBezierPath()
        linePath.move(to: CGPoint(x: startPoint.x, y: endPoint.y))
        linePath.addLine(to: endPoint)
        linePath.addLine(to: CGPoint(x: (startPoint.x + endPoint.x)/2, y: startPoint.y))
        linePath.addLine(to: CGPoint(x: startPoint.x, y: endPoint.y))
        return linePath
    }
    
    func star(startPoint: CGPoint, translationPoint: CGPoint) -> UIBezierPath{
        let linePath = UIBezierPath()
        linePath.move(to: CGPoint(x: startPoint.x + translationPoint.x/2 , y: startPoint.y))
        linePath.addLine(to: CGPoint(x: startPoint.x + translationPoint.x/3*2, y: startPoint.y + translationPoint.y/3))
        linePath.addLine(to: CGPoint(x: startPoint.x + translationPoint.x, y: startPoint.y + translationPoint.y/2))
        linePath.addLine(to: CGPoint(x: startPoint.x + translationPoint.x/3*2, y: startPoint.y + translationPoint.y/3*2))
        linePath.addLine(to: CGPoint(x: startPoint.x + translationPoint.x/2, y: startPoint.y + translationPoint.y))
        linePath.addLine(to: CGPoint(x: startPoint.x + translationPoint.x/3, y: startPoint.y + translationPoint.y/3*2))
        linePath.addLine(to: CGPoint(x: startPoint.x, y: startPoint.y + translationPoint.y/2))
        linePath.addLine(to: CGPoint(x: startPoint.x + translationPoint.x/3, y: startPoint.y + translationPoint.y/3))
        linePath.addLine(to: CGPoint(x: startPoint.x + translationPoint.x/2 , y: startPoint.y))
        return linePath
    }
    
}
