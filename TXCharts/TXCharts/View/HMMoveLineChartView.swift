//
//  HMMoveLineChartView.swift
//  Demo
//
//  Created by powershare on 2023/12/7.
//

import UIKit

class HMMoveLineChartView: UIView, MaskViewTouchDelegate {
    
    // MARK: MaskViewTouchDelegate
    func maskViewTouchesBegan(touchLocation: CGPoint) {
        guard let chartData = chartData, let ylist = chartData.ylist, !ylist.isEmpty else { return }
        
        isSelectShow = true
        initSelect(touchLocation.x)
        if let slideCallBack = slideChartCallBack, selectPos != -1 {
            slideCallBack(selectPos)
        }
        if delegate != nil {
            delegate!.subviewTouchesBegan()
        }
        setNeedsDisplay()
    }
    
    func maskViewTouchesMoved(touchLocation: CGPoint) {
        guard let chartData = chartData, let ylist = chartData.ylist, !ylist.isEmpty else { return }
        
        isSelectShow = true
        initSelect(touchLocation.x)
        if let slideCallBack = slideChartCallBack, selectPos != -1 {
            slideCallBack(selectPos)
        }
        if delegate != nil {
            delegate!.subviewTouchesBegan()
        }
        setNeedsDisplay()
    }
    
    func maskViewTouchesEnded(touchLocation: CGPoint) {
        guard let chartData = chartData, let ylist = chartData.ylist, !ylist.isEmpty else { return }
        
        isSelectShow = false
        initSelect(touchLocation.x)
        if let slideCallBack = slideChartCallBack, selectPos != -1 {
            slideCallBack(selectPos)
        }
        if delegate != nil {
            delegate!.subviewTouchesEnded()
        }
        
        setNeedsDisplay()
    }
    
    weak var delegate: SubviewTouchDelegate?
    
    private var lineIndex: Int = 0
    
    private var selectPos: Int = -1
    private var isSelectShow: Bool = false
    
    private var bgLineConfig: HMChartBgLineConfig?
    private var lineChartConfig: HMBaseChartConfig?
    
    private var chartData: HMChartData?
    private var points: [[CGPoint]] = []
    private var fillPoints: [[CGPoint]] = []
    
    // UIView 相关
    private var touchMaskView: HMTouchMaskView = HMTouchMaskView()
    /// x轴选中label
    private var xListLabel: UILabel = UILabel()
    /// 气泡视图
    private var bubbleView: HMChartBubbleView = HMChartBubbleView()
    
    public var slideChartCallBack: ((_ selectedPos: Int) -> Void)?
    public var bubbleContent: NSAttributedString?
    
    public var isDisableSlide: Bool = false {
        didSet {
            touchMaskView.isHidden = isDisableSlide
            touchMaskView.delegate = isDisableSlide ? nil : self
        }
    }
    
    // MARK: LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        touchMaskView.frame = self.bounds
        self.setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        guard let lineChartConfig = lineChartConfig, let chartData = chartData, let ylist = chartData.ylist, !ylist.isEmpty else { return }
        
        guard let linePoint = HMChartUtil.initLinePoint(rect.size, chartData: chartData, chartConfig: lineChartConfig) else { return }
        points = linePoint.points
        fillPoints = linePoint.fillPoints
        
        // 初始化点
        // initPoint(lineChartConfig, mSelfWidth: mSelfWidth, mSelfHeight: mSelfHeight)
        // 画选中时的背景阴影
        initBgShadow(context, selfSize: rect.size, lineChartConfig: lineChartConfig, chartData: chartData)
        // 滑动时画 X 值
        drawSlideXValue(rect.height, chartData: chartData, lineChartConfig: lineChartConfig, chartConfig: lineChartConfig)
        
        if let lineChartConfig = lineChartConfig as? HMLineChartConfig {
            // 画竖线&横线
            drawVerticalLine(context, mSelfWidth: rect.width, mSelfHeight: rect.height, chartData: chartData, lineChartConfig: lineChartConfig, chartStyle: lineChartConfig.chartStyle)
            // 画选中点样式
            drawSelectedPointStyle(context, lineChartConfig: lineChartConfig)
            // 画气泡
            showBubble(rect.width, lineChartConfig: lineChartConfig, bgLineConfig: bgLineConfig ?? HMChartBgLineConfig(), chartStyle: lineChartConfig.chartStyle)
        } else if let lineChartConfig = lineChartConfig as? HMBarChartConfig {
            // 画竖线&横线
            drawVerticalLine(context, mSelfWidth: rect.width, mSelfHeight: rect.height, chartData: chartData, lineChartConfig: lineChartConfig, chartStyle: .curve)
            // 画气泡
            showBubble(rect.width, lineChartConfig: lineChartConfig, bgLineConfig: bgLineConfig ?? HMChartBgLineConfig(), chartStyle: .curve)
        }
    }
    
    // MARK: Public Method
    public func setChartConfig(_ bgLineConfig: HMChartBgLineConfig?, lineChartConfig: HMBaseChartConfig?) {
        self.bgLineConfig = bgLineConfig
        self.lineChartConfig = lineChartConfig
    }
    
    public func setChartData(_ chartData: HMChartData?, lineIndex: Int) {
        setChartData(chartData, lineIndex: lineIndex, isRecursive: false)
    }
    
    public func setChartData(_ chartData: HMChartData?, lineIndex: Int, isRecursive: Bool) {
        guard let chartData = chartData, let xlist = chartData.xlist, let ylist = chartData.ylist else { return }
        guard let lineChartConfig = lineChartConfig else { return }
        
        bubbleView.bgColor = lineChartConfig.bubbleBackgroudColor
        bubbleView.cornerRadius = lineChartConfig.bubbleRadius
        // 异常情况，线的数量 > 线颜色的数量，自动拼接黑色线进去
//        if ylist.count > lineColors.count {
//            var newLineColors: [UIColor] = Array(lineColors)
//            for _ in newLineColors.count..<ylist.count {
//                newLineColors.append(UIColor.black)
//            }
//            chartData.lineColors = newLineColors
//        }
        
        // 异常情况，线的数量 > 线上面选中点的位置数量，自动拼接 .none 进去
//        if ylist.count > lineChartConfig.pointDescPositionList.count {
//            var newPointDescPositionList = Array(lineChartConfig.pointDescPositionList)
//            for _ in newPointDescPositionList.count..<ylist.count {
//                newPointDescPositionList.append(.none)
//            }
//            lineChartConfig.pointDescPositionList = newPointDescPositionList
//        }
        
        self.lineIndex = lineIndex
        self.chartData = chartData
        
        let yMinLength = HMChartUtil.getArrayMinLength(ylist)
        // 防止 lineIndex 越界
        if lineIndex < 0 || lineIndex >= xlist.count || lineIndex >= yMinLength {
            selectPos = 0
            self.lineIndex = yMinLength - 1
        } else {
            if isRecursive {
                if let index = HMChartUtil.recursiveSearchNoNullIndex(ylist, currIndex: lineIndex, originalIndex: lineIndex) {
                    selectPos = index
                }
                print("递归查询到的 selectPos = \(selectPos)")
            } else {
                let recursiveSelectPods = HMChartUtil.recursiveSearchNoNullIndex(ylist, currIndex: lineIndex, originalIndex: lineIndex)
                print("递归查询到的 recursiveSelectPods = \(recursiveSelectPods) 原始：lineIndex = \(lineIndex)")
                if recursiveSelectPods != lineIndex {
                    selectPos = -1
                } else {
                    selectPos = lineIndex
                }
            }
        }
        setNeedsDisplay()
    }
    
    // MARK: UI
    private func setupView() {
        touchMaskView.delegate = self
        
        self.backgroundColor = .white
        self.addSubview(touchMaskView)
        self.addSubview(xListLabel)
        self.addSubview(bubbleView)
    }
    
    // MARK: Private Method - 构造数据
    private func initSelect(_ x: CGFloat) {
        guard !points.isEmpty else { return }
        guard let chartData = chartData, let ylist = chartData.ylist, let xData = chartData.xlist, !ylist.isEmpty else { return }
        
        for i in 0..<points[0].count {
            if i == 0 && points[0][i].x > x {
                if ylist[0][i] != CGFloat.greatestFiniteMagnitude && i < xData.count && i < ylist[0].count {
                    selectPos = i
                }
                return
            } else {
                if points[0][i].x > x && x > points[0][i - 1].x {
                    if ylist[0][i] != CGFloat.greatestFiniteMagnitude && i < xData.count && i < ylist[0].count {
                        selectPos = i
                    }
                    return
                }
            }
        }
    }
    
    func initSelect(_ x: CGFloat, isShow: Bool) {
        isSelectShow = isShow
        for i in 0..<points[0].count {
            if i == 0 && points[0][i].x > x {
                selectPos = i
                return
            } else {
                if points[0][i].x > x && x > points[0][i - 1].x {
                    selectPos = i
                    return
                }
            }
        }
    }
    
    // MARK: Private Method - 画线
    /// 控制显示气泡
    func showBubble(_ mSelfWidth: CGFloat, lineChartConfig: HMBaseChartConfig?, bgLineConfig: HMChartBgLineConfig, chartStyle: HMLineChartConfig.LineChartStyle) {
        guard let lineChartConfig = lineChartConfig else { return }
        guard let chartData = self.chartData, let xData = chartData.xlist, !xData.isEmpty, let ylist = chartData.ylist, !ylist.isEmpty else { return }
        guard !ylist[0].isEmpty && !points[0].isEmpty else { return }
        
        // 不显示气泡：如果 y 值数据是 CGFLOAT_MAX 也不显示气泡
        if !lineChartConfig.isShowBubble || selectPos == -1 || HMChartUtil.judgmentElementHaveNull(ylist, selectIndex: selectPos) {
            bubbleView.isHidden = true
            return
        } else {
            bubbleView.isHidden = false
            bubbleView.margin = lineChartConfig.bubbleMargin
        }
        
        var x = 0.0
        var point: CGPoint = .zero
        if chartStyle == .stepped {
            point = fillPoints[0][selectPos*3+1]
        } else {
            point = points[0][selectPos]
        }
        if isSelectShow {
            bubbleView.content = bubbleContent
            let textSize = bubbleView.getBubbleViewSize()
            if point.x + textSize.width/2 > mSelfWidth - bgLineConfig.margin.right {
                // 超出最右边视图
                x = mSelfWidth - bgLineConfig.margin.right - textSize.width
                bubbleView.centerOffset = point.x - (x + textSize.width/2)
            } else if point.x - textSize.width/2 < bgLineConfig.margin.left {
                // 超出最左边边视图
                x = bgLineConfig.margin.left
                bubbleView.centerOffset = point.x - (x + textSize.width/2)
            } else {
                x = point.x - textSize.width/2
                bubbleView.centerOffset = 0
            }
            bubbleView.frame = CGRect(x: x, y: lineChartConfig.chartMargin.top - 10, width: textSize.width, height: textSize.height)
        } else {
            bubbleView.content = bubbleContent
            let textSize = bubbleView.getBubbleViewSize()
            if point.x + textSize.width/2 > mSelfWidth - bgLineConfig.margin.right {
                // 超出最右边视图
                x = mSelfWidth - bgLineConfig.margin.right - textSize.width
                bubbleView.centerOffset = point.x - (x + textSize.width/2)
            } else if point.x - textSize.width/2 < bgLineConfig.margin.left {
                // 超出最左边边视图
                x = bgLineConfig.margin.left
                bubbleView.centerOffset = point.x - (x + textSize.width/2)
            } else {
                x = point.x - textSize.width/2
            }
            bubbleView.frame = CGRect(x: x, y: lineChartConfig.chartMargin.top - 10, width: textSize.width, height: textSize.height)
        }
    }
    
    /// 动态滑动时，画 竖线&横线
    private func drawVerticalLine(_ context: CGContext, mSelfWidth: CGFloat, mSelfHeight: CGFloat, chartData: HMChartData, lineChartConfig: HMBaseChartConfig, chartStyle: HMLineChartConfig.LineChartStyle) {
        if points.isEmpty || selectPos == -1 {
            return
        }
        
        let chartWidth = mSelfWidth - lineChartConfig.chartMargin.left - lineChartConfig.chartMargin.right
        let chartHeight = mSelfHeight - lineChartConfig.chartMargin.top - lineChartConfig.chartMargin.bottom
        if lineChartConfig.isShowVerticalSeletedLine {
            if chartStyle == .stepped {
                let pvPath = CGMutablePath()
                pvPath.move(to: CGPoint(x: fillPoints[0][selectPos * 3 + 1].x, y: lineChartConfig.chartMargin.top))
                pvPath.addLine(to: CGPoint(x: fillPoints[0][selectPos * 3 + 1].x, y: chartHeight + lineChartConfig.chartMargin.top))
                context.setStrokeColor(UIColor.black.cgColor)
                context.setLineWidth(1)
                if !isSelectShow {
                    context.setLineDash(phase: 0, lengths: [5, 5])
                }
                context.addPath(pvPath)
                context.strokePath()
            } else {
                let pvPath = CGMutablePath()
                pvPath.move(to: CGPoint(x: points[0][selectPos].x, y: lineChartConfig.chartMargin.top))
                pvPath.addLine(to: CGPoint(x: points[0][selectPos].x, y: chartHeight + lineChartConfig.chartMargin.top))
                context.setStrokeColor(UIColor.black.cgColor)
                context.setLineWidth(1)
                if !isSelectShow {
                    context.setLineDash(phase: 0, lengths: [5, 5])
                }
                context.addPath(pvPath)
                context.strokePath()
            }
        }
        if lineChartConfig.isShowHorizontalSeletedLine, points.count == 1 {
            if chartStyle == .stepped {
                let pvPath = CGMutablePath()
                pvPath.move(to: CGPoint(x: lineChartConfig.chartMargin.left, y: fillPoints[0][selectPos * 3 + 1].y))
                pvPath.addLine(to: CGPoint(x: chartWidth + lineChartConfig.chartMargin.left, y: fillPoints[0][selectPos * 3 + 1].y))
                context.setStrokeColor(UIColor.black.cgColor)
                context.setLineWidth(1)
                if !isSelectShow {
                    context.setLineDash(phase: 0, lengths: [5, 5])
                }
                context.addPath(pvPath)
                context.strokePath()
            } else {
                let pvPath = CGMutablePath()
                pvPath.move(to: CGPoint(x: lineChartConfig.chartMargin.left, y: points[0][selectPos].y))
                pvPath.addLine(to: CGPoint(x: chartWidth + lineChartConfig.chartMargin.left, y: points[0][selectPos].y))
                context.setStrokeColor(UIColor.black.cgColor)
                context.setLineWidth(1)
                if !isSelectShow {
                    context.setLineDash(phase: 0, lengths: [5, 5])
                }
                context.addPath(pvPath)
                context.strokePath()
            }
        }
    }
    
    private func drawSelectedPointStyle(_ context: CGContext, lineChartConfig: HMLineChartConfig) {
        switch lineChartConfig.selectPointStyle {
        case .hollow:
            for i in 0 ..< points.count {
//                var lineColor = lineColors[i]
                var lineColor: UIColor = lineChartConfig.lineStyleConfigs?[i].last?.lineColor ?? .clear
                if let lineStyleConfigs = lineChartConfig.lineStyleConfigs {
                    for lineStyleConfig in lineStyleConfigs[i] {
                        if lineStyleConfig.startIndex <= selectPos && selectPos < lineStyleConfig.endIndex {
                            lineColor = lineStyleConfig.lineColor
                            break
                        }
                    }
                }
                if lineChartConfig.chartStyle == .stepped {
                    if fillPoints[i] [selectPos * 3 + 1].y != CGFloat.greatestFiniteMagnitude {
                        context.setFillColor(lineColor.cgColor)
                        context.fillEllipse(in: CGRect(x: fillPoints[i] [selectPos * 3 + 1].x - lineChartConfig.selectPointRadius,
                                                       y: fillPoints[i] [selectPos * 3 + 1].y - lineChartConfig.selectPointRadius,
                                                       width: 2 * lineChartConfig.selectPointRadius,
                                                       height: 2 * lineChartConfig.selectPointRadius))

                        context.setFillColor(UIColor.white.cgColor)
                        context.fillEllipse(in: CGRect(x: fillPoints[i] [selectPos * 3 + 1].x - lineChartConfig.selectPointRadius + 2,
                                                       y: fillPoints[i] [selectPos * 3 + 1].y - lineChartConfig.selectPointRadius + 2,
                                                       width: 2 * (lineChartConfig.selectPointRadius - 2),
                                                       height: 2 * (lineChartConfig.selectPointRadius - 2)))
                    }
                } else {
                    if points[i] [selectPos].y != CGFloat.greatestFiniteMagnitude {
                        context.setFillColor(lineColor.cgColor)
                        context.fillEllipse(in: CGRect(x: points[i] [selectPos].x - lineChartConfig.selectPointRadius,
                                                       y: points[i] [selectPos].y - lineChartConfig.selectPointRadius,
                                                       width: 2 * lineChartConfig.selectPointRadius,
                                                       height: 2 * lineChartConfig.selectPointRadius))

                        context.setFillColor(UIColor.white.cgColor)
                        context.fillEllipse(in: CGRect(x: points[i] [selectPos].x - lineChartConfig.selectPointRadius + 2,
                                                       y: points[i] [selectPos].y - lineChartConfig.selectPointRadius + 2,
                                                       width: 2 * (lineChartConfig.selectPointRadius - 2),
                                                       height: 2 * (lineChartConfig.selectPointRadius - 2)))
                    }
                }

            }
        case .solid:
            for i in 0 ..< points.count {
//                var lineColor = lineColors[i]
            var lineColor: UIColor = lineChartConfig.lineStyleConfigs?[i].last?.lineColor ?? .clear
            if let lineStyleConfigs = lineChartConfig.lineStyleConfigs {
                for lineStyleConfig in lineStyleConfigs[i] {
                    if lineStyleConfig.startIndex <= selectPos && selectPos < lineStyleConfig.endIndex {
                        lineColor = lineStyleConfig.lineColor
                        break
                    }
                }
            }
            if lineChartConfig.chartStyle == .stepped {
                if fillPoints[i] [selectPos * 3 + 1].y != CGFloat.greatestFiniteMagnitude {
                    context.setFillColor(UIColor.white.cgColor)
                    context.fillEllipse(in: CGRect(x: fillPoints[i] [selectPos * 3 + 1].x - lineChartConfig.selectPointRadius,
                                                   y: fillPoints[i] [selectPos * 3 + 1].y - lineChartConfig.selectPointRadius,
                                                   width: 2 * lineChartConfig.selectPointRadius,
                                                   height: 2 * lineChartConfig.selectPointRadius))

                    context.setFillColor(lineColor.cgColor)
                    context.fillEllipse(in: CGRect(x: fillPoints[i] [selectPos * 3 + 1].x - lineChartConfig.selectPointRadius + 2,
                                                   y: fillPoints[i] [selectPos * 3 + 1].y - lineChartConfig.selectPointRadius + 2,
                                                   width: 2 * (lineChartConfig.selectPointRadius - 2),
                                                   height: 2 * (lineChartConfig.selectPointRadius - 2)))
                }
            } else {
                if points[i] [selectPos].y != CGFloat.greatestFiniteMagnitude {
                    context.setFillColor(UIColor.white.cgColor)
                    context.fillEllipse(in: CGRect(x: points[i] [selectPos].x - lineChartConfig.selectPointRadius,
                                                   y: points[i] [selectPos].y - lineChartConfig.selectPointRadius,
                                                   width: 2 * lineChartConfig.selectPointRadius,
                                                   height: 2 * lineChartConfig.selectPointRadius))

                    context.setFillColor(lineColor.cgColor)
                    context.fillEllipse(in: CGRect(x: points[i] [selectPos].x - lineChartConfig.selectPointRadius + 2,
                                                   y: points[i] [selectPos].y - lineChartConfig.selectPointRadius + 2,
                                                   width: 2 * (lineChartConfig.selectPointRadius - 2),
                                                   height: 2 * (lineChartConfig.selectPointRadius - 2)))
                }
            }

        }
            
        default:
            
            break
        }
    }
    
    /// 动态滑动时，画 X 轴值
    private func drawSlideXValue(_ mSelfHeight: CGFloat, chartData: HMChartData, lineChartConfig: HMBaseChartConfig, chartConfig: HMBaseChartConfig) {
        guard let chartData = self.chartData, let xData = chartData.xlist, let ylist = chartData.ylist, !ylist.isEmpty else { return }
        if lineChartConfig.isHiddenSlideXValue || selectPos == -1 {
            xListLabel.isHidden = true
        } else {
            xListLabel.isHidden = false
            xListLabel.font = chartConfig.xAxis.textFont
            xListLabel.textColor = chartConfig.xAxis.selectTextColor
            if selectPos == 0 {
                var attributedText = NSAttributedString()
                
                attributedText = NSAttributedString(string: xData.first!, attributes: [.foregroundColor: chartConfig.xAxis.selectTextColor, .font: chartConfig.xAxis.selectTextFont])
                let textSize = attributedText.size()
                xListLabel.text = xData.first!
                xListLabel.textAlignment = .left
                xListLabel.frame = CGRect(x: points[0].first!.x, y: mSelfHeight - lineChartConfig.chartMargin.bottom + lineChartConfig.xAxis.valueOffSet, width: textSize.width, height: textSize.height)
            } else if selectPos == xData.count - 1 {
                var attributedText = NSAttributedString()
                attributedText = NSAttributedString(string: xData.last!, attributes: [.foregroundColor: chartConfig.xAxis.selectTextColor, .font: chartConfig.xAxis.selectTextFont])
                let textSize = attributedText.size()
                xListLabel.text = xData.last!
                xListLabel.textAlignment = .right
                xListLabel.frame = CGRect(x: points[0].last!.x - textSize.width, y: mSelfHeight - lineChartConfig.chartMargin.bottom + lineChartConfig.xAxis.valueOffSet, width: textSize.width, height: textSize.height)
            } else {
                var attributedText = NSAttributedString()
                attributedText = NSAttributedString(string: xData[selectPos], attributes: [.foregroundColor: chartConfig.xAxis.selectTextColor, .font: chartConfig.xAxis.selectTextFont])
                let textSize = attributedText.size()
                xListLabel.text = xData[selectPos]
                xListLabel.textAlignment = .center
                xListLabel.frame = CGRect(x: points[0][selectPos].x - textSize.width/2, y: mSelfHeight - lineChartConfig.chartMargin.bottom + lineChartConfig.xAxis.valueOffSet, width: textSize.width, height: textSize.height)
            }
        }
    }
    
    /// 画背景选中时阴影
    private func initBgShadow(_ context: CGContext, selfSize: CGSize, lineChartConfig: HMBaseChartConfig, chartData: HMChartData) {
        guard let xData = chartData.xlist, !points.isEmpty else { return }
        guard selectPos < points[0].count && selectPos != -1 else { return }
        
        let chartWidth = selfSize.width - lineChartConfig.chartMargin.left - lineChartConfig.chartMargin.right
        if lineChartConfig.isShowSelectShadow {
            var width = chartWidth/CGFloat((xData.count - 1))
            if let selectShadowWidth = lineChartConfig.selectShadowWidth {
                width = selectShadowWidth
            }
            context.setFillColor(lineChartConfig.selectShadowColor.cgColor)
            let selectRect = CGRect(x: points[0][selectPos].x - width/2,
                                    y: 0,
                                    width: width,
                                    height: selfSize.height)
            context.beginPath()
            context.addPath(UIBezierPath(roundedRect: selectRect, cornerRadius: 0).cgPath)
            context.closePath()
            context.fillPath()
        }
    }
    
    // MARK: Private Method - 私有方法
    
}
