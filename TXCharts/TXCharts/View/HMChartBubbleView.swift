//
//  HMChartBubbleView.swift
//  Demo
//
//  Created by powershare on 2023/12/12.
//

import UIKit
import SnapKit

/// 气泡上箭头 view
private class HMBubbleArrowView: UIView {
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.setFillColor(UIColor(red: 30/255.0, green: 29/255.0, blue: 29/255.0, alpha: 1).cgColor)
        context.beginPath()
        // 起点位置
        context.move(to: CGPoint(x: rect.width / 2, y: rect.height))
        context.addLine(to: CGPoint(x: 0, y: 0))
        context.addLine(to: CGPoint(x: rect.width, y: 0))
        context.closePath()
        context.fillPath()
    }
}

/// 图表上的气泡
class HMChartBubbleView: UIView {

    // MARK: Public Method
    public var centerOffset: CGFloat = 0 {
        didSet {
            // print("centerOffset = \(centerOffset)")
            bubbleArrowView.snp.updateConstraints { make in
                make.centerX.equalTo(self).offset(centerOffset)
            }
        }
    }
    
    /// 气泡距离父视图 margin
    public var margin: UIEdgeInsets = UIEdgeInsets() {
        didSet {
            lblBubble.snp.updateConstraints { make in
                make.top.equalTo(self).offset(margin.top)
                make.leading.equalTo(self).offset(margin.left)
                make.bottom.equalTo(self).offset(-margin.bottom)
                make.trailing.equalTo(self).offset(-margin.right)
            }
        }
    }
    
    public var bgColor: UIColor? {
        didSet {
            self.backgroundColor = bgColor
        }
    }
    
    public var cornerRadius: CGFloat? {
        didSet {
            if let cornerRadius = cornerRadius {
                self.layer.cornerRadius = cornerRadius
            }
        }
    }
    
    /// 气泡内容
    public var content: NSAttributedString? {
        didSet {
            lblBubble.attributedText = content
        }
    }
    
    /// 获取 bubbleView 的大小（内部已经计算了边距）
    public func getBubbleViewSize() -> CGSize {
        let textSize = lblBubble.attributedText?.string.size(withAttributes: [.font: lblBubble.font!]) ?? CGSize.zero
        return CGSize(width: textSize.width + margin.left + margin.right + 2, height: textSize.height + margin.top + margin.bottom + 2)
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
    
    // MARK: UI
    private func setupUI() {
        self.isHidden = true
        
        self.addSubview(lblBubble)
        lblBubble.snp.makeConstraints { make in
            make.top.equalTo(self)
            make.leading.equalTo(self)
            make.bottom.equalTo(self)
            make.trailing.equalTo(self)
        }
        
        // 在使用箭头的视图控制器中添加以下代码
        self.addSubview(bubbleArrowView)
        bubbleArrowView.snp.makeConstraints { make in
            make.bottom.equalTo(self).offset(4)
            make.centerX.equalTo(self)
            make.width.equalTo(8)
            make.height.equalTo(4)
        }
    }
    
    // MARK: lazy
    private lazy var lblBubble: UILabel = {
        let label = UILabel.init()
        label.numberOfLines = 0
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: "RobotoCondensed-Bold", size: 10)
        return label
    }()
    
    private lazy var bubbleArrowView: HMBubbleArrowView = {
        let arrowView = HMBubbleArrowView()
        arrowView.backgroundColor = .clear
        return arrowView
    }()
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
