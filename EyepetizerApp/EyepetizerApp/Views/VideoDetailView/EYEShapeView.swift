//
//  EYEShapeView.swift
//  EyepetizerApp
//
//  Created by 梁亦明 on 16/3/24.
//  Copyright © 2016年 xiaoming. All rights reserved.
//

import UIKit

class EYEShapeView: UIView, CAAnimationDelegate {
    
    var pathLayer : CAShapeLayer!
    
    // 做动画的字体
    var animationString : String! {
        didSet {
            let pathLayer = setupDefaultLayer()
            self.pathLayer = pathLayer
            
        }
    }
    // 字体
    var font : UIFont!
    // 字体大小 
    var fontSize : CGFloat!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        
        font = UIFont.customFont_FZLTXIHJW()
        fontSize = UIConstant.UI_FONT_12
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupDefaultLayer() -> CAShapeLayer {
        
        // 创建字体
        let letters = CGMutablePath()
        let font = CTFontCreateWithName("HelveticaNeue-UltraLight" as CFString, self.fontSize, nil)
        let attrString = NSAttributedString(string: animationString, attributes: [kCTFontAttributeName as NSAttributedStringKey: font])
        
        let line = CTLineCreateWithAttributedString(attrString)
        let runArray = CTLineGetGlyphRuns(line)
        // for each RUN
        for runIndex in 0..<CFArrayGetCount(runArray) {
            // Get FONT for this run
            let run = unsafeBitCast(CFArrayGetValueAtIndex(runArray, runIndex), to: CTRun.self)
            let runFont = unsafeBitCast(CFDictionaryGetValue(CTRunGetAttributes(run), unsafeBitCast(kCTFontAttributeName, to: UnsafePointer<Void>.self)), to: CTFont.self)
            // for each GLYPH in run
            for runGlyphIndex in 0..<CTRunGetGlyphCount(run) {
                let thisGlyphRange = CFRangeMake(runGlyphIndex, 1)
                var glyph : CGGlyph = CGGlyph()
                var position : CGPoint = CGPoint()
                CTRunGetGlyphs(run, thisGlyphRange, &glyph)
                CTRunGetPositions(run, thisGlyphRange, &position)
                // Get PATH of outline
                let letter = CTFontCreatePathForGlyph(runFont, glyph, nil)
                var t = CGAffineTransform(translationX: position.x, y: position.y)
//                CGPathAddPath(letters, &t, letter);
            }
        }
        
        // create path
        let path = UIBezierPath()
        path.move(to: CGPoint.zero)
        path.append(UIBezierPath(cgPath: letters))
        
        let pathLayer = CAShapeLayer()
        pathLayer.frame = self.bounds
        pathLayer.bounds = path.cgPath.boundingBox
        pathLayer.isGeometryFlipped = true
        pathLayer.path = path.cgPath
        pathLayer.strokeColor = UIColor.white.cgColor
        pathLayer.fillColor = nil
        pathLayer.strokeEnd = 1
        pathLayer.lineWidth = 1.0
        pathLayer.lineJoin = kCALineJoinBevel
        return pathLayer
    }
    
    /**
     动画
     */
    func startAnimation() {
        self.layer.addSublayer(pathLayer)
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.delegate = self
        animation.fromValue = 0.0
        animation.toValue = 1.0
        animation.duration = 0.5
        animation.isRemovedOnCompletion = false
        self.pathLayer.add(animation, forKey: animation.keyPath)
    }
    
    /**
     停止动画
     */
    func stopAnimation() {
        self.pathLayer.removeAllAnimations()
    }
}
