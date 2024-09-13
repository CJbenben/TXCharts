//
//  HMDrawBgLineView.swift
//  Demo
//
//  Created by powershare on 2024/1/17.
//  Copyright © 2024 ChenJie. All rights reserved.
//

import UIKit

/// 背景线样式
public enum BgLineStyle: Int {
    case dash       // 虚线
    case solid      // 实线
}

class HMChartBgLineConfig: NSObject {
    /// 是否有背景线，默认：false
    public var enabled: Bool = false
    /// 背景线样式
    public var style: BgLineStyle = .dash
    /// 背景线距离父视图 margin
    public var margin: UIEdgeInsets = .init(top: 20, left: 10, bottom: 20, right: 10)
    /// 背景线水平方向线数量
    public var horizontalLineCount: Int = 5
    /// 背景线竖直方向线数量
    public var verticalLineCount: Int = 6
    /// 背景线宽度
    public var lineWidth: CGFloat = 0.5
    /// 背景线条颜色
    public var lineColor = UIColor(red: 197 / 255.0, green: 197 / 255.0, blue: 197 / 255.0, alpha: 1)
}

/// 画背景线
class HMDrawBgLineView: UIView {

    // MARK: Public Method
    public var bgLineConfig: HMChartBgLineConfig? {
        didSet {
            if let _ = bgLineConfig {
                self.setNeedsDisplay()
            }
        }
    }
    
    // MARK: Private Method
    internal func drawBgLine(_ context: CGContext, bgSize: CGSize, bgLineConfig: HMChartBgLineConfig) {
        context.setStrokeColor(bgLineConfig.lineColor.cgColor)
        if bgLineConfig.style == .dash {
            context.setLineDash(phase: 0, lengths: [5, 5])
        } else {
            context.setLineDash(phase: 0, lengths: [])
        }
        let top = bgLineConfig.margin.top
        let bottom = bgLineConfig.margin.bottom
        let left = bgLineConfig.margin.left
        let right = bgLineConfig.margin.right
        let bgLineWidth = bgSize.width - left - right
        let bgLineHeight = bgSize.height - top - bottom
        // 画背景横线
        if bgLineConfig.horizontalLineCount > 0 {
            if bgLineConfig.horizontalLineCount == 1 {
                let y = top + bgLineHeight / 2.0
                let linePath = UIBezierPath()
                linePath.move(to: CGPoint(x: left, y: y + top))
                linePath.addLine(to: CGPoint(x: left + bgLineWidth, y: y + top))
                linePath.lineWidth = bgLineConfig.lineWidth
                context.addPath(linePath.cgPath)
                context.strokePath()
            } else {
                let yHeightSpace: CGFloat = bgLineHeight / CGFloat(bgLineConfig.horizontalLineCount - 1)
                for i in 0 ..< bgLineConfig.horizontalLineCount {
                    let linePath = UIBezierPath()
                    linePath.move(to: CGPoint(x: left, y: CGFloat(i) * yHeightSpace + top))
                    linePath.addLine(to: CGPoint(x: left + bgLineWidth, y: CGFloat(i) * yHeightSpace + top))
                    linePath.lineWidth = bgLineConfig.lineWidth
                    context.addPath(linePath.cgPath)
                    context.strokePath()
                }
            }
        }
        // 画背景竖线
        if bgLineConfig.verticalLineCount > 0 {
            if bgLineConfig.verticalLineCount == 1 {
                let x = left + bgLineWidth / 2.0
                let linePath = UIBezierPath()
                linePath.move(to: CGPoint(x: x, y: top))
                linePath.addLine(to: CGPoint(x: x, y: bgLineHeight + top))
                linePath.lineWidth = bgLineConfig.lineWidth
                context.addPath(linePath.cgPath)
                context.strokePath()
            } else {
                let xWidthSpace = bgLineWidth / CGFloat(bgLineConfig.verticalLineCount - 1)
                for i in 0 ..< bgLineConfig.verticalLineCount {
                    let linePath = UIBezierPath()
                    linePath.move(to: CGPoint(x: CGFloat(i) * xWidthSpace + left, y: top))
                    linePath.addLine(to: CGPoint(x: CGFloat(i) * xWidthSpace + left, y: bgLineHeight + top))
                    linePath.lineWidth = bgLineConfig.lineWidth
                    context.addPath(linePath.cgPath)
                    context.strokePath()
                }
            }
        }
    }
    
    // MARK: Action
    
    // MARK: Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        guard let bgLineConfig = bgLineConfig, bgLineConfig.enabled else { return }
        
        drawBgLine(context, bgSize: rect.size, bgLineConfig: bgLineConfig)
    }
    
    // MARK: UI
    private func setupUI() {
        
    }
    
    // MARK: lazy

}
