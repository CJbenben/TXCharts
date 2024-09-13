//
//  HMDrawLineChartView.swift
//  Demo
//
//  Created by powershare on 2024/1/19.
//  Copyright © 2024 ChenJie. All rights reserved.
//

import UIKit

@objc protocol SubviewTouchDelegate: AnyObject {
    func subviewTouchesBegan()
    func subviewTouchesMoved(moveY: CGFloat)
    func subviewTouchesEnded()
}

// 此 view 画了：x、y轴，x、y轴上的值，折线/曲线/梯形，线填充的渐变阴影
/// 画折线/柱状图
class HMDrawLineChartView: UIView {
    private var points: [[CGPoint]] = []
    private var fillPoints: [[CGPoint]] = []
    
    private var chartConfig: HMBaseChartConfig?
    private var chartData: HMChartData?
    
    // MARK: Public Method
    public func setChartData(_ chartData: HMChartData?, chartConfig: HMBaseChartConfig?) {
        self.chartConfig = chartConfig
        self.chartData = chartData
        self.setNeedsDisplay()
    }
    
    // MARK: Private Method
    /// 画 X Y 轴
    private func drawXandYAxis(_ context: CGContext, selfSize: CGSize, chartData: HMChartData, chartConfig: HMBaseChartConfig) {
        guard let xData = chartData.xlist else { return }
        guard !xData.isEmpty && !points.isEmpty && !points[0].isEmpty else {
            return
        }
        let chartWidth = selfSize.width - chartConfig.chartMargin.left - chartConfig.chartMargin.right
        let chartHeight = selfSize.height - chartConfig.chartMargin.top - chartConfig.chartMargin.bottom
        
        let axisPath = CGMutablePath()
        if chartConfig.xAxis.isEnabled {
            let startX = points[0][0].x + chartConfig.xAxis.offset.x
            let endX = points[0].last!.x - chartConfig.xAxis.offset.x
            switch chartConfig.xAxis.position {
            case .top:
                axisPath.move(to: CGPoint(x: startX, y: chartConfig.chartMargin.top + chartConfig.xAxis.offset.y))
                axisPath.addLine(to: CGPoint(x: endX, y: chartConfig.chartMargin.top + chartConfig.xAxis.offset.y))
            case .zero:
                let zeroY = HMChartUtil.getAxisZeroY(chartHeight, chartData: chartData)
                if let _zeroY = zeroY {
                    print("_zeroY 0 线位置 = \(_zeroY)")
                    axisPath.move(to: CGPoint(x: startX, y: _zeroY + chartConfig.chartMargin.top))
                    axisPath.addLine(to: CGPoint(x: endX, y: _zeroY + chartConfig.chartMargin.top))
                }
            case .bottom:
                axisPath.move(to: CGPoint(x: startX, y: chartConfig.chartMargin.top + chartHeight - chartConfig.xAxis.offset.y))
                axisPath.addLine(to: CGPoint(x: endX, y: chartConfig.chartMargin.top + chartHeight - chartConfig.xAxis.offset.y))
            }
            context.setStrokeColor(chartConfig.xAxis.axisColor.cgColor)
            if chartConfig.xAxis.style == .dash {
                context.setLineDash(phase: 0, lengths: [2, 2])
            } else {
                context.setLineDash(phase: 0, lengths: [])
            }
            context.setLineWidth(chartConfig.xAxis.axisWidth)
        }
        
        if chartConfig.yAxis.isEnabled {
            let startY = chartConfig.chartMargin.top + chartConfig.yAxis.offset.y
            let endY = chartConfig.chartMargin.top + chartHeight - chartConfig.yAxis.offset.y
            switch chartConfig.yAxis.position {
            case .right:
                axisPath.move(to: CGPoint(x: chartConfig.chartMargin.left + chartWidth - chartConfig.yAxis.offset.x, y: startY))
                axisPath.addLine(to: CGPoint(x: chartConfig.chartMargin.left + chartWidth - chartConfig.yAxis.offset.x, y: endY))
            default:
                axisPath.move(to: CGPoint(x: chartConfig.chartMargin.left + chartConfig.yAxis.offset.x, y: startY))
                axisPath.addLine(to: CGPoint(x: chartConfig.chartMargin.left + chartConfig.yAxis.offset.x, y: endY))
            }
            context.setStrokeColor(chartConfig.yAxis.axisColor.cgColor)
            if chartConfig.yAxis.style == .dash {
                context.setLineDash(phase: 0, lengths: [2, 2])
            } else {
                context.setLineDash(phase: 0, lengths: [])
            }
            context.setLineWidth(chartConfig.yAxis.axisWidth)
        }
        context.addPath(axisPath)
        context.strokePath()
    }
    
    /// 画 X 轴值
    private func drawXAxisValues(_ selfSize: CGSize, chartData: HMChartData, chartConfig: HMBaseChartConfig) {
        guard let xData = chartData.xlist else { return }
        guard !xData.isEmpty && !points.isEmpty && !points[0].isEmpty else {
            return
        }
        // 如果 x 轴 和 y 轴数据长度不一致时，按最小长度画 x 轴值
        var minCount = xData.count
        if xData.count != points[0].count {
            minCount = min(xData.count, points[0].count)
        }
        let chartHeight = selfSize.height - chartConfig.chartMargin.top - chartConfig.chartMargin.bottom
        
        switch chartConfig.xAxis.position {
        case .top, .bottom:
            switch chartConfig.xAxis.xValueStyle {
            case .all:
                for i in 0..<minCount {
                    let xText = xData[i]
                    let attributedString = NSAttributedString(string: xText, attributes: [.foregroundColor: chartConfig.xAxis.textColor, .font: chartConfig.xAxis.textFont])
                    var xValueX = points[0][i].x
                    if let chartConfig = chartConfig as? HMLineChartConfig {
                        if chartConfig.chartStyle == .stepped {
                            xValueX = fillPoints[0][i*3+1].x
                        }
                    }
                    if i == 0 {
                        drawXValue(xValueX, chartHeight: chartHeight, xText: xText, chartConfig: chartConfig)
                    } else if i == xData.count - 1 {
                        drawXValue(xValueX - attributedString.size().width, chartHeight: chartHeight, xText: xText, chartConfig: chartConfig)
                    } else {
                        drawXValue(xValueX - attributedString.size().width/2.0, chartHeight: chartHeight, xText: xText, chartConfig: chartConfig)
                    }
                }
            case .minMax:
                if minCount < 2 {
                    return
                }
                drawXValue(points[0].first!.x, chartHeight: chartHeight, xText: xData.first, chartConfig: chartConfig)
                drawXValue(points[0][minCount-1].x, chartHeight: chartHeight, xText: xData[minCount-1], chartConfig: chartConfig)
            default:
                
                break
            }
        default:
            guard let firstText = xData.first, !firstText.isEmpty else { return }
            let attributedStringFirst = NSAttributedString(string: firstText, attributes: [.foregroundColor: chartConfig.xAxis.textColor, .font: chartConfig.xAxis.textFont])
            drawXValue(points[0].first!.x - attributedStringFirst.size().width + chartConfig.xAxis.offset.x - chartConfig.xAxis.valueOffSet, chartHeight: chartHeight, xText: firstText, chartConfig: chartConfig)
            guard !xData[minCount-1].isEmpty else { return }
            // let attributedStringLast = NSAttributedString(string: lastText, attributes: [.foregroundColor: chartConfig.xAxis.textColor, .font: chartConfig.xAxis.textFont])
            drawXValue(points[0].last!.x - chartConfig.xAxis.offset.x + chartConfig.xAxis.valueOffSet, chartHeight: chartHeight, xText: xData[minCount-1], chartConfig: chartConfig)
        }
    }
    
    /// 画 Y 轴值
    private func drawYAxisValues(_ selfSize: CGSize, chartData: HMChartData?, chartConfig: HMBaseChartConfig) {
        guard let chartData = chartData, let ylist = chartData.ylist, !ylist.isEmpty else { return }
        
        let chartWidth = selfSize.width - chartConfig.chartMargin.left - chartConfig.chartMargin.right
        let chartHeight = selfSize.height - chartConfig.chartMargin.top - chartConfig.chartMargin.bottom
        if chartConfig.yAxis.showValueCount <= 0 || chartHeight <= 0 {
            return
        }
        
        if chartConfig.yAxis.showValueCount == 1 {
            let value = (chartData.maxValue + chartData.minValue)/2.0
            let y = chartConfig.chartMargin.top + chartHeight/2.0
            drawYValue(y, chartWidth: chartWidth, yValue: value, chartConfig: chartConfig)
        } else {
            // y轴实际值的密度
            let yDensityValue = (chartData.maxValue - chartData.minValue) / CGFloat(chartConfig.yAxis.showValueCount - 1)
            // y轴图标高度的密度
            let yDensityChart = chartHeight / CGFloat(chartConfig.yAxis.showValueCount - 1)
            for i in 0..<chartConfig.yAxis.showValueCount {
                let value = CGFloat(chartData.maxValue) - yDensityValue * CGFloat(i)
                let y = chartConfig.chartMargin.top + yDensityChart * CGFloat(i)
                drawYValue(y, chartWidth: chartWidth, yValue: value, chartConfig: chartConfig)
            }
        }
    }
    
    /// 开始画折线
    private func drawLineChart(_ context: CGContext, selfSize: CGSize, lineChartConfig: HMLineChartConfig?) {
        guard !points.isEmpty else { return }
        guard let lineChartConfig = lineChartConfig else { return }
        guard let chartData = self.chartData, let ylist = chartData.ylist, !ylist.isEmpty else { return }
        
        var newLineStyleConfigs: [[HMLineStyleConfig]] = []
        if var lineStyleConfigs = lineChartConfig.lineStyleConfigs, lineStyleConfigs.count > 0 {
            print("############### - lineStyleConfigs.count = \(lineStyleConfigs.count), points.count = \(points.count)")
//            if points.count != lineStyleConfigs.count {
//                print("线的数量 points = \(points.count) 和标记位数量 lineStyleConfigs = \(lineStyleConfigs.count) 不一致")
//            }
//            for index in 0..<ylist.count {
//                let yValueAry = ylist[index]
//                let markAry = markArray[index]
//                if yValueAry.count != markAry.count {
//                    print("第 \(index) 条线上点的数量和标记点数量不一致 yValueAry.count = \(yValueAry.count), markAry.count = \(markAry.count)")
//                    return
//                }
//            }
            for i in 0..<min(points.count, lineStyleConfigs.count) {
                var newLineStyleConfigArray: [HMLineStyleConfig] = []
                for index in 0..<lineStyleConfigs[i].count {
                    let currLineStyleConfig = lineStyleConfigs[i][index]
                    // 异常情况，标记点数量 > 真实点数量，只处理真实点数据
                    if currLineStyleConfig.startIndex >= points[i].count {
                        currLineStyleConfig.startIndex = points[i].count - 1
                    }
                    if currLineStyleConfig.endIndex >= points[i].count {
                        currLineStyleConfig.endIndex = points[i].count - 1
                    }
                    // 起始点和终点都是 null
                    if points[i][currLineStyleConfig.startIndex].y == CGFloat.greatestFiniteMagnitude &&
                        points[i][currLineStyleConfig.endIndex].y == CGFloat.greatestFiniteMagnitude {
                        if i == points.count - 1 {
                            if let nonEmptyIndex = HMChartUtil.returnNoNullIndexAfter(points[i], fromIndex: currLineStyleConfig.startIndex) {
                                currLineStyleConfig.startIndex = nonEmptyIndex
                            }
                            if let nonEmptyIndex = HMChartUtil.returnNoNullIndexAfter(points[i], fromIndex: currLineStyleConfig.endIndex) {
                                currLineStyleConfig.endIndex = nonEmptyIndex
                            }
                        }
                    }
                    // 起始点为 null
                    else if points[i][currLineStyleConfig.startIndex].y == CGFloat.greatestFiniteMagnitude {
                        if i == points.count - 1 {
                            if let nonEmptyIndex = HMChartUtil.returnNoNullIndexAfter(points[i], fromIndex: currLineStyleConfig.startIndex) {
                                currLineStyleConfig.startIndex = nonEmptyIndex
                            }
                        }
                    }
                    // 终点为 null
                    else if points[i][currLineStyleConfig.endIndex].y == CGFloat.greatestFiniteMagnitude {
                        if i == points.count - 1 {
                            if let nonEmptyIndex = HMChartUtil.returnNoNullIndexAfter(points[i], fromIndex: currLineStyleConfig.endIndex) {
                                currLineStyleConfig.endIndex = nonEmptyIndex
                            }
                        }
                    } else {
                        newLineStyleConfigArray.append(currLineStyleConfig)
                        continue
                    }
                    if currLineStyleConfig.endIndex > currLineStyleConfig.startIndex {
                        newLineStyleConfigArray.append(currLineStyleConfig)
                    }
                }
                lineStyleConfigs[i] = newLineStyleConfigArray
            }
            newLineStyleConfigs = lineStyleConfigs
        } else {
            var lineStyleConfigs: [[HMLineStyleConfig]] = []
            for index in 0..<points.count {
                let beforeLineStyleConfig = HMLineStyleConfig()
//                beforeLineStyleConfig.lineWidth = beforeLineStyleConfig.lineWidth
//                beforeLineStyleConfig.lineStyle = beforeLineStyleConfig.lineStyle
//                beforeLineStyleConfig.lineColor = lineColors[index]
                beforeLineStyleConfig.startIndex = 0
                if chartData.lineIndex >= points[index].count {
                    beforeLineStyleConfig.endIndex = points[index].count - 1
                } else {
                    beforeLineStyleConfig.endIndex = chartData.lineIndex
                }
//                beforeLineStyleConfig.isNeedFillColor = lineChartConfig.isNeedFillColor
                
                let afterLineStyleConfig = HMLineStyleConfig()
//                afterLineStyleConfig.lineChartWidth = lineChartConfig.lineWidth
//                afterLineStyleConfig.lineStyle = lineChartConfig.lineStyle
//                afterLineStyleConfig.lineColor = lineColors[index]
                if chartData.lineIndex >= points[index].count {
                    continue
                } else {
                    afterLineStyleConfig.startIndex = chartData.lineIndex
                }
                afterLineStyleConfig.endIndex = points[index].count - 1
                afterLineStyleConfig.isNeedFillColor = false
                lineStyleConfigs.append([beforeLineStyleConfig, afterLineStyleConfig])
            }
            lineChartConfig.lineStyleConfigs = lineStyleConfigs
            newLineStyleConfigs = lineStyleConfigs
        }
        
        // for 循环设置每一条线
        for i in 0..<min(points.count, newLineStyleConfigs.count) {
            // 每一段相同配置线就是一个 path，一条线有 N 个 path
            var pathArray: [UIBezierPath] = []
            let lineStyleConfigArray = newLineStyleConfigs[i]
            
            // for 循环每一段相同配置线
            for index in 0..<lineStyleConfigArray.count {
                let currItemLineStyleConfig = lineStyleConfigArray[index]
                
                let path = UIBezierPath()
                var currPointIndex = currItemLineStyleConfig.startIndex
                if currPointIndex < 0 || currPointIndex >= points[i].count {
                    return
                }
                if points[i][currItemLineStyleConfig.startIndex].y == CGFloat.greatestFiniteMagnitude {
                    if let index = HMChartUtil.recursiveSearchNoNullIndexUp(ylist, originalIndex: currPointIndex) {
                        currPointIndex = index
                    } else {
                        continue
                    }
                }
                if lineChartConfig.chartStyle == .stepped {
                    path.move(to: fillPoints[i][currPointIndex * 3 + 1])
                } else {
                    path.move(to: points[i][currPointIndex])
                }
                // for 循环当前段 一个个 addLine
                var haveEmpthValue = false
                for j in currItemLineStyleConfig.startIndex..<currItemLineStyleConfig.endIndex + 1 {
                    switch lineChartConfig.chartStyle {
                    case .curve, .straight:
                        if j >= points[i].count {
                            return
                        }
                        let currentPoint = points[i][j]
                        if j == currItemLineStyleConfig.startIndex || currentPoint.y == CGFloat.greatestFiniteMagnitude {
                            continue
                        }
                        if lineChartConfig.chartStyle == .curve {
                            // 先递归查询上一个有值的点，再画线
                            if let noEmpthIndex = HMChartUtil.returnNoNullIndexBefore(points[i], fromIndex: j-1) {
                                let previousPoint = points[i][noEmpthIndex]
                                let controlPoint1 = CGPoint(x: previousPoint.x + (currentPoint.x - previousPoint.x) / 2,
                                                            y: previousPoint.y)
                                let controlPoint2 = CGPoint(x: currentPoint.x - (currentPoint.x - previousPoint.x) / 2,
                                                            y: currentPoint.y)
                                path.addCurve(to: CGPoint(x: currentPoint.x, y: currentPoint.y), controlPoint1: controlPoint1, controlPoint2: controlPoint2)
                            }
                        } else {
                            path.addLine(to: CGPoint(x: currentPoint.x, y: currentPoint.y))
                        }
                    case .stepped:
                        if j * 3 >= fillPoints[i].count {
                            return
                        }
                        let firstPoint = fillPoints[i][currItemLineStyleConfig.startIndex * 3]
                        let currentPoint = fillPoints[i][j * 3]
                        let currentPoint1 = fillPoints[i][j * 3 + 1]
                        let currentPoint2 = fillPoints[i][j * 3 + 2]
                        if currentPoint.y == CGFloat.greatestFiniteMagnitude {
                            haveEmpthValue = true
                        } else {
                            // 第一个，或者不是每一段的开始
                            if j == currItemLineStyleConfig.startIndex && index == 0 {
                                path.move(to: firstPoint)
                            }
                            // 如果之前有空数据（线断节了）绘制空值这一段的线
                            if haveEmpthValue {
                                haveEmpthValue = false
                                let noEmptyIndex = HMChartUtil.returnNoNullIndexBefore(fillPoints[i], fromIndex: j * 3 - 1)
                                if let noEmptyIndex = noEmptyIndex {
                                    path.addLine(to: fillPoints[i][noEmptyIndex])
                                    path.addLine(to: CGPoint(x: fillPoints[i][j * 3].x, y: fillPoints[i][noEmptyIndex].y))
                                    path.addLine(to: CGPoint(x: fillPoints[i][j * 3].x, y: fillPoints[i][j * 3].y))
                                }
                            }
                            if j == currItemLineStyleConfig.endIndex {
                                path.addLine(to: currentPoint1)
                            } else {
                                path.addLine(to: currentPoint2)
                                let currentPoint3 = fillPoints[i][j * 3 + 3]
                                if currentPoint3.y == CGFloat.greatestFiniteMagnitude {
                                    
                                } else {
                                    path.addLine(to: currentPoint3)
                                }
                            }
                            // 每条线最后一段
                            if j * 3 + 3 == fillPoints[i].count {
                                let lastPoint = fillPoints[i].last!
                                path.addLine(to: lastPoint)
                            }
                        }
                    }
                    context.addPath(path.cgPath)
                    context.setLineWidth(lineStyleConfigArray[index].lineWidth)
                    context.setStrokeColor(lineStyleConfigArray[index].lineColor.cgColor)
                    if lineStyleConfigArray[index].lineStyle == .solid {
                        context.setLineDash(phase: 0, lengths: [])
                    } else {
                        context.setLineDash(phase: 0, lengths: [2, 2])
                    }
                    context.strokePath()
                }
                pathArray.append(path)
            }
            
            drawLineDownGradient(context, selfSize: selfSize, pathArray: pathArray, yList: ylist[i], pointsList: points[i], fillPointsList: fillPoints[i], lineChartConfig: lineChartConfig, lineStyleConfigs: lineStyleConfigArray)
        }
    }
    
    /// 画折线下阴影
    private func drawLineDownGradient(_ context: CGContext,
                                      selfSize: CGSize,
                                      pathArray: [UIBezierPath],
                                      yList: [CGFloat],
                                      pointsList: [CGPoint],
                                      fillPointsList: [CGPoint],
                                      lineChartConfig: HMLineChartConfig,
                                      lineStyleConfigs: [HMLineStyleConfig]) {
        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) else {
            return
        }
        for index in 0..<pathArray.count {
            let path = pathArray[index]
            let lineStyleConfig = lineStyleConfigs[index]
            // 不要填充颜色
            if lineStyleConfig.isNeedFillColor == false {
                continue
            }
            let colors: [CGColor] = [
                lineStyleConfig.lineColor.withAlphaComponent(0.6).cgColor,
                lineStyleConfig.lineColor.withAlphaComponent(0).cgColor
            ]
            let locations: [CGFloat] = [0.0, 1.0]
            let beforeGradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: locations)!
            
            let chartHeight = selfSize.height - lineChartConfig.chartMargin.top - lineChartConfig.chartMargin.bottom
            let maxMinAndIndex = HMChartUtil.getMaxMinValueAndIndex(yList)
            var topY = lineChartConfig.chartMargin.top
            var bottomY = chartHeight + lineChartConfig.chartMargin.top
            if let _maxMinAndIndex = maxMinAndIndex {
                topY = pointsList[_maxMinAndIndex.maxIndex].y
                bottomY = pointsList[_maxMinAndIndex.minIndex].y
            }
            var endY = chartHeight + lineChartConfig.chartMargin.top
            
            switch lineChartConfig.xAxis.position {
            case .top:
                endY = lineChartConfig.chartMargin.top
            case .bottom:
                endY = chartHeight + lineChartConfig.chartMargin.top
            default:
                let zeroY = HMChartUtil.getAxisZeroY(chartHeight, chartData: chartData)
                if let _zeroY = zeroY {
                    endY = _zeroY + lineChartConfig.chartMargin.top
                }
            }
            
            var firstPoint: CGPoint = .zero
            var lastPoint: CGPoint = .zero
            switch lineChartConfig.chartStyle {
            case .curve, .straight:
                if pointsList[lineStyleConfig.startIndex].y == CGFloat.greatestFiniteMagnitude {
                    let nonEmptyIndex = HMChartUtil.returnNoNullIndexAfter(pointsList, fromIndex: lineStyleConfig.startIndex)
                    guard let nonEmptyIndex = nonEmptyIndex else { return }
                    firstPoint = pointsList[nonEmptyIndex]
                } else {
                    firstPoint = pointsList[lineStyleConfig.startIndex]
                }
                if pointsList[lineStyleConfig.endIndex].y == CGFloat.greatestFiniteMagnitude {
                    let nonEmptyIndex = HMChartUtil.returnNoNullIndexBefore(pointsList, fromIndex: lineStyleConfig.endIndex)
                    guard let nonEmptyIndex = nonEmptyIndex else { return }
                    lastPoint = pointsList[nonEmptyIndex]
                } else {
                    lastPoint = pointsList[lineStyleConfig.endIndex]
                }
            case .stepped:
                if fillPointsList[lineStyleConfig.startIndex * 3].y == CGFloat.greatestFiniteMagnitude {
                    let nonEmptyIndex = HMChartUtil.returnNoNullIndexAfter(fillPointsList, fromIndex: lineStyleConfig.startIndex * 3)
                    guard let nonEmptyIndex = nonEmptyIndex else { return }
                    firstPoint = fillPointsList[nonEmptyIndex]
                } else {
                    // 第一段 path
                    if index == 0 {
                        firstPoint = fillPointsList[lineStyleConfig.startIndex * 3]
                    } else {
                        firstPoint = fillPointsList[lineStyleConfig.startIndex * 3 + 1]
                    }
                }
                if fillPointsList[lineStyleConfig.endIndex * 3].y == CGFloat.greatestFiniteMagnitude {
                    let nonEmptyIndex = HMChartUtil.returnNoNullIndexBefore(fillPointsList, fromIndex: lineStyleConfig.endIndex * 3)
                    guard let nonEmptyIndex = nonEmptyIndex else { return }
                    lastPoint = fillPointsList[nonEmptyIndex]
                } else {
                    // 最后一段 path
                    if index == pathArray.count - 1 {
                        lastPoint = fillPointsList[lineStyleConfig.endIndex * 3 + 2]
                    } else {
                        lastPoint = fillPointsList[lineStyleConfig.endIndex * 3 + 1]
                    }
                }
            }
            
            path.addLine(to: CGPoint(x: lastPoint.x, y: endY))
            path.addLine(to: CGPoint(x: firstPoint.x, y: endY))
            path.addLine(to: firstPoint)
            path.close()
            context.addPath(path.cgPath)
            
            context.saveGState()
            context.clip()
            if topY < endY {
                context.drawLinearGradient(beforeGradient, start: CGPoint(x: selfSize.width/2.0, y: topY), end: CGPoint(x: selfSize.width/2, y: endY), options: [])
            }
            if bottomY > endY {
                context.drawLinearGradient(beforeGradient, start: CGPoint(x: selfSize.width/2.0, y: bottomY), end: CGPoint(x: selfSize.width/2.0, y: endY), options: [])
            }
            context.restoreGState()
            context.strokePath()
        }
    }
    
    /// 画柱状图
    private func drawBarChart(_ context: CGContext, selfSize: CGSize, barChartConfig: HMBarChartConfig?) {
        guard !points.isEmpty else { return }
        guard let barChartConfig = barChartConfig else { return }
        guard let chartData = self.chartData, let ylist = chartData.ylist, !ylist.isEmpty else { return }
        
        let chartHeight = selfSize.height - barChartConfig.chartMargin.top - barChartConfig.chartMargin.bottom

        var newLineStyleConfigs: [[HMLineStyleConfig]] = []
        if var lineStyleConfigs = barChartConfig.lineStyleConfigs, lineStyleConfigs.count > 0 {
            print("############### - lineStyleConfigs.count = \(lineStyleConfigs.count), points.count = \(points.count)")
            for i in 0..<min(points.count, lineStyleConfigs.count) {
                var newLineStyleConfigArray: [HMLineStyleConfig] = []
                for index in 0..<lineStyleConfigs[i].count {
                    let currLineStyleConfig = lineStyleConfigs[i][index]
                    // 异常情况，标记点数量 > 真实点数量，只处理真实点数据
                    if currLineStyleConfig.startIndex >= points[i].count {
                        currLineStyleConfig.startIndex = points[i].count - 1
                    }
                    if currLineStyleConfig.endIndex >= points[i].count {
                        currLineStyleConfig.endIndex = points[i].count - 1
                    }
                    // 起始点和终点都是 null
                    if points[i][currLineStyleConfig.startIndex].y == CGFloat.greatestFiniteMagnitude &&
                        points[i][currLineStyleConfig.endIndex].y == CGFloat.greatestFiniteMagnitude {
                        if i == points.count - 1 {
                            if let nonEmptyIndex = HMChartUtil.returnNoNullIndexAfter(points[i], fromIndex: currLineStyleConfig.startIndex) {
                                currLineStyleConfig.startIndex = nonEmptyIndex
                            }
                            if let nonEmptyIndex = HMChartUtil.returnNoNullIndexAfter(points[i], fromIndex: currLineStyleConfig.endIndex) {
                                currLineStyleConfig.endIndex = nonEmptyIndex
                            }
                        }
                    }
                    // 起始点为 null
                    else if points[i][currLineStyleConfig.startIndex].y == CGFloat.greatestFiniteMagnitude {
                        if i == points.count - 1 {
                            if let nonEmptyIndex = HMChartUtil.returnNoNullIndexAfter(points[i], fromIndex: currLineStyleConfig.startIndex) {
                                currLineStyleConfig.startIndex = nonEmptyIndex
                            }
                        }
                    }
                    // 终点为 null
                    else if points[i][currLineStyleConfig.endIndex].y == CGFloat.greatestFiniteMagnitude {
                        if i == points.count - 1 {
                            if let nonEmptyIndex = HMChartUtil.returnNoNullIndexAfter(points[i], fromIndex: currLineStyleConfig.endIndex) {
                                currLineStyleConfig.endIndex = nonEmptyIndex
                            }
                        }
                    } else {
                        newLineStyleConfigArray.append(currLineStyleConfig)
                        continue
                    }
                    if currLineStyleConfig.endIndex > currLineStyleConfig.startIndex {
                        newLineStyleConfigArray.append(currLineStyleConfig)
                    }
                }
                lineStyleConfigs[i] = newLineStyleConfigArray
            }
            newLineStyleConfigs = lineStyleConfigs
        } else {
            var lineStyleConfigs: [[HMLineStyleConfig]] = []
            for index in 0..<points.count {
                let beforeLineStyleConfig = HMLineStyleConfig()
//                beforeLineStyleConfig.lineWidth = beforeLineStyleConfig.lineWidth
//                beforeLineStyleConfig.lineStyle = beforeLineStyleConfig.lineStyle
//                beforeLineStyleConfig.lineColor = lineColors[index]
                beforeLineStyleConfig.startIndex = 0
                if chartData.lineIndex >= points[index].count {
                    beforeLineStyleConfig.endIndex = points[index].count - 1
                } else {
                    beforeLineStyleConfig.endIndex = chartData.lineIndex
                }
//                beforeLineStyleConfig.isNeedFillColor = lineChartConfig.isNeedFillColor
                
                let afterLineStyleConfig = HMLineStyleConfig()
//                afterLineStyleConfig.lineChartWidth = lineChartConfig.lineWidth
//                afterLineStyleConfig.lineStyle = lineChartConfig.lineStyle
//                afterLineStyleConfig.lineColor = lineColors[index]
                if chartData.lineIndex >= points[index].count {
                    continue
                } else {
                    afterLineStyleConfig.startIndex = chartData.lineIndex
                }
                afterLineStyleConfig.endIndex = points[index].count - 1
                afterLineStyleConfig.isNeedFillColor = false
                lineStyleConfigs.append([beforeLineStyleConfig, afterLineStyleConfig])
            }
            barChartConfig.lineStyleConfigs = lineStyleConfigs
            newLineStyleConfigs = lineStyleConfigs
        }
        
        // for 循环设置每一条线
        for i in 0..<min(points.count, newLineStyleConfigs.count) {
            // 每一段相同配置线就是一个 path，一条线有 N 个 path
            var pathArray: [UIBezierPath] = []
            let lineStyleConfigArray = newLineStyleConfigs[i]
            
            // for 循环每一段相同配置线
            for index in 0..<lineStyleConfigArray.count {
                let currItemLineStyleConfig = lineStyleConfigArray[index]
                
                let path = UIBezierPath()
                var currPointIndex = currItemLineStyleConfig.startIndex
                if currPointIndex < 0 || currPointIndex >= points[i].count {
                    return
                }
                if points[i][currItemLineStyleConfig.startIndex].y == CGFloat.greatestFiniteMagnitude {
                    if let index = HMChartUtil.recursiveSearchNoNullIndexUp(ylist, originalIndex: currPointIndex) {
                        currPointIndex = index
                    } else {
                        continue
                    }
                }
                path.move(to: points[i][currPointIndex])
                
                // for 循环当前段 一个个 addLine
                for j in currItemLineStyleConfig.startIndex..<currItemLineStyleConfig.endIndex + 1 {
                    if j >= points[i].count {
                        return
                    }
                    switch barChartConfig.direction {
                    case .up:
                        let currentPoint = points[i][j]
                        path.addLine(to: CGPoint(x: currentPoint.x - 5.0, y: currentPoint.y))
                        path.addLine(to: CGPoint(x: currentPoint.x - 5.0, y: selfSize.height - barChartConfig.chartMargin.bottom))
                        path.addLine(to: CGPoint(x: currentPoint.x + 5.0, y: selfSize.height - barChartConfig.chartMargin.bottom))
                        path.addLine(to: CGPoint(x: currentPoint.x + 5.0, y: currentPoint.y))
                        path.addLine(to: CGPoint(x: currentPoint.x - 5.0, y: currentPoint.y))
                        if j+1 < points[i].count {
                            let nextPoint = points[i][j+1]
                            path.move(to: CGPoint(x: nextPoint.x, y: nextPoint.y))
                        }
                    case .down:
                        break
                    case .auto:
                        let zeroY = HMChartUtil.getAxisZeroY(chartHeight, chartData: chartData)
                        if let _zeroY = zeroY {
                            print("_zeroY = \(_zeroY)")
                            let currentPoint = points[i][j]
                            path.addLine(to: CGPoint(x: currentPoint.x - 5.0, y: currentPoint.y))
                            path.addLine(to: CGPoint(x: currentPoint.x - 5.0, y: _zeroY + barChartConfig.chartMargin.top))
                            path.addLine(to: CGPoint(x: currentPoint.x + 5.0, y: _zeroY + barChartConfig.chartMargin.top))
                            path.addLine(to: CGPoint(x: currentPoint.x + 5.0, y: currentPoint.y))
                            path.addLine(to: CGPoint(x: currentPoint.x - 5.0, y: currentPoint.y))
                            if j+1 < points[i].count {
                                let nextPoint = points[i][j+1]
                                path.move(to: CGPoint(x: nextPoint.x, y: nextPoint.y))
                            }
                        }
                    }
                    
                    UIColor.gray.setFill()
                    path.fill()
                    
                    context.addPath(path.cgPath)
                    context.setLineWidth(lineStyleConfigArray[index].lineWidth)
                    context.setStrokeColor(lineStyleConfigArray[index].lineColor.cgColor)
                    if lineStyleConfigArray[index].lineStyle == .solid {
                        context.setLineDash(phase: 0, lengths: [])
                    } else {
                        context.setLineDash(phase: 0, lengths: [2, 2])
                    }
                    context.strokePath()
                }
                pathArray.append(path)
            }
        }
    }
    
    /// 画折线上的点
    private func drawLinePoint(_ context: CGContext, lineChartConfig: HMLineChartConfig?) {
        guard !points.isEmpty else { return }
        guard let chartData = self.chartData, let ylist = chartData.ylist, let lineChartConfig = lineChartConfig, let lineStyleConfigs = lineChartConfig.lineStyleConfigs, !ylist.isEmpty else { return }
        
        switch lineChartConfig.normalPointStyle {
        case .hollow:
            for i in 0 ..< points.count {
                let lineStyleConfigArray = lineStyleConfigs[i]
                for j in 0 ..< points[i].count {
                    var lineColor: UIColor = lineStyleConfigArray.last?.lineColor ?? .clear
                    for lineStyleConfig in lineStyleConfigArray {
                        if j >= lineStyleConfig.startIndex && j < lineStyleConfig.endIndex {
                            lineColor = lineStyleConfig.lineColor
                            break
                        }
                    }
                    var point: CGPoint = .zero
                    if lineChartConfig.chartStyle == .stepped {
                        point = fillPoints[i] [j * 3 + 1]
                    } else {
                        point = points[i] [j]
                    }
                    context.setFillColor(lineColor.cgColor)
                    context.fillEllipse(in: CGRect(x: point.x - lineChartConfig.selectPointRadius,
                                                   y: point.y - lineChartConfig.selectPointRadius,
                                                   width: 2 * lineChartConfig.selectPointRadius,
                                                   height: 2 * lineChartConfig.selectPointRadius))

                    context.setFillColor(UIColor.white.cgColor)
                    context.fillEllipse(in: CGRect(x: point.x - lineChartConfig.selectPointRadius + 2,
                                                   y: point.y - lineChartConfig.selectPointRadius + 2,
                                                   width: 2 * (lineChartConfig.selectPointRadius - 2),
                                                   height: 2 * (lineChartConfig.selectPointRadius - 2)))
                }
            }
        case .solid:
            for i in 0 ..< points.count {
                let lineStyleConfigArray = lineStyleConfigs[i]
                for j in 0 ..< points[i].count {
                    var lineColor: UIColor = lineStyleConfigArray.last?.lineColor ?? .clear
                    for lineStyleConfig in lineStyleConfigArray {
                        if j >= lineStyleConfig.startIndex && j < lineStyleConfig.endIndex {
                            lineColor = lineStyleConfig.lineColor
                            break
                        }
                    }
                    var point: CGPoint = .zero
                    if lineChartConfig.chartStyle == .stepped {
                        point = fillPoints[i] [j * 3 + 1]
                    } else {
                        point = points[i] [j]
                    }
                    context.setFillColor(UIColor.white.cgColor)
                    context.fillEllipse(in: CGRect(x: point.x - lineChartConfig.selectPointRadius,
                                                   y: point.y - lineChartConfig.selectPointRadius,
                                                   width: 2 * lineChartConfig.selectPointRadius,
                                                   height: 2 * lineChartConfig.selectPointRadius))

                    context.setFillColor(lineColor.cgColor)
                    context.fillEllipse(in: CGRect(x: point.x - lineChartConfig.selectPointRadius + 2,
                                                   y: point.y - lineChartConfig.selectPointRadius + 2,
                                                   width: 2 * (lineChartConfig.selectPointRadius - 2),
                                                   height: 2 * (lineChartConfig.selectPointRadius - 2)))
                }
            }
        case .none:
            break
        }
        
        if lineChartConfig.pointDescOnlyMaxAndMin {
            for i in 0..<points.count {
                let maxMinIndex = HMChartUtil.getMaxMinValueAndIndex(ylist[i])
                if let _maxMinIndex = maxMinIndex {
                    var textColor: UIColor = lineStyleConfigs[i].last?.lineColor ?? .clear
                    if let pointDescTextColor = lineChartConfig.pointDescTextColor {
                        textColor = pointDescTextColor
                    } else {
                        let lineStyleConfigArray = lineStyleConfigs[i]
                        for lineStyleConfig in lineStyleConfigArray {
                            if lineStyleConfig.startIndex <= _maxMinIndex.maxIndex && _maxMinIndex.maxIndex < lineStyleConfig.endIndex {
                                textColor = lineStyleConfig.lineColor
                                break
                            }
                        }
                    }
                    
                    var maxPoint: CGPoint = .zero
                    if lineChartConfig.chartStyle == .stepped {
                        maxPoint = fillPoints[i][_maxMinIndex.maxIndex*3+1]
                    } else {
                        maxPoint = points[i][_maxMinIndex.maxIndex]
                    }
                    var attributedTextMax = NSAttributedString()
                    if let pointDescMaxValue = lineChartConfig.pointDescMaxValue {
                        attributedTextMax = NSAttributedString(string: pointDescMaxValue.string, attributes: [.foregroundColor: textColor, .font: lineChartConfig.pointDescTextFont])
                    } else {
                        attributedTextMax = NSAttributedString(string: String(format: "%@%@", HMChartUtil.decimalFloatValue(Float(ylist[i][_maxMinIndex.maxIndex])), lineChartConfig.pointDescUnit), attributes: [.foregroundColor: textColor, .font: lineChartConfig.pointDescTextFont])
                    }
                    attributedTextMax.draw(at: CGPoint(x: maxPoint.x - attributedTextMax.size().width/2, y: maxPoint.y - attributedTextMax.size().height - lineChartConfig.selectPointRadius))
                    
                    var minPoint: CGPoint = .zero
                    if lineChartConfig.chartStyle == .stepped {
                        minPoint = fillPoints[i][_maxMinIndex.minIndex*3+1]
                    } else {
                        minPoint = points[i][_maxMinIndex.minIndex]
                    }
                    var attributedTextMin = NSAttributedString()
                    if let pointDescMinValue = lineChartConfig.pointDescMinValue {
                        attributedTextMin = NSAttributedString(string: pointDescMinValue.string, attributes: [.foregroundColor: textColor, .font: lineChartConfig.pointDescTextFont])
                    } else {
                        attributedTextMin = NSAttributedString(string: String(format: "%@%@", HMChartUtil.decimalFloatValue(Float(ylist[i][_maxMinIndex.minIndex])), lineChartConfig.pointDescUnit), attributes: [.foregroundColor: textColor, .font: lineChartConfig.pointDescTextFont])
                    }
                    attributedTextMin.draw(at: CGPoint(x: minPoint.x - attributedTextMin.size().width/2, y: minPoint.y + lineChartConfig.selectPointRadius))
                }
            }
        } else {
            for i in 0..<points.count {
//                let textColor = lineChartConfig.pointDescTextColor ?? lineColors[i]
//                let pointDescPosition = lineChartConfig.pointDescPositionList[i]
                for j in 0..<points[i].count {
                    var textColor: UIColor = lineStyleConfigs[i].last?.lineColor ?? .clear
                    var pointDescPosition: HMLineStyleConfig.LineChartPointDescPosition = lineStyleConfigs[i].last?.pointDescPosition ?? .none
                    
                    let lineStyleConfigArray = lineStyleConfigs[i]
                    for lineStyleConfig in lineStyleConfigArray {
                        if lineStyleConfig.startIndex <= j && j < lineStyleConfig.endIndex {
                            textColor = lineStyleConfig.lineColor
                            pointDescPosition = lineStyleConfig.pointDescPosition
                            break
                        }
                    }
                    if let pointDescTextColor = lineChartConfig.pointDescTextColor {
                        textColor = pointDescTextColor
                    }
                    let currentPoint = points[i][j]
                    if currentPoint.y == CGFloat.greatestFiniteMagnitude {
                        continue
                    }
                    var attributedTextFirst = NSAttributedString()
                    attributedTextFirst = NSAttributedString(string: String(format: "%@%@", HMChartUtil.decimalFloatValue(Float(ylist[i][j])), lineChartConfig.pointDescUnit), attributes: [.foregroundColor: textColor, .font: lineChartConfig.pointDescTextFont])
                    var tmpPointDescPosition: HMLineStyleConfig.LineChartPointDescPosition = pointDescPosition
                    if tmpPointDescPosition == .auto {
                        if j + 1 < points[i].count {
                            let nextPoint = points[i][j + 1]
                            if currentPoint.y < nextPoint.y {
                                tmpPointDescPosition = .top
                            } else {
                                tmpPointDescPosition = .bottom
                            }
                        } else {
                            tmpPointDescPosition = .top
                        }
                    }
                    switch tmpPointDescPosition {
                    case .none:
                        break
                    case .top:
                        attributedTextFirst.draw(at: CGPoint(x: currentPoint.x - attributedTextFirst.size().width/2, y: currentPoint.y - attributedTextFirst.size().height - lineChartConfig.selectPointRadius))
                    case .bottom:
                        attributedTextFirst.draw(at: CGPoint(x: currentPoint.x - attributedTextFirst.size().width/2, y: currentPoint.y + lineChartConfig.selectPointRadius))
                    case .auto:
                        break
                    }
                    
                }
            }
        }
        
    }
    
    // MARK: Private Method - 内部使用
    private func drawXValue(_ x: CGFloat, chartHeight: CGFloat, xText: String?, chartConfig: HMBaseChartConfig?) {
        guard let xText = xText, let chartConfig = chartConfig else { return }
        
        let valueOffSet = chartConfig.xAxis.valueOffSet
        let attributedString = NSAttributedString(string: xText, attributes: [.foregroundColor: chartConfig.xAxis.textColor, .font: chartConfig.xAxis.textFont])
        var xValueY = 0.0
        if chartConfig.xAxis.position == .top {
            if chartConfig.xAxis.valuePosition == .top {
                xValueY = chartConfig.chartMargin.top - attributedString.size().height - valueOffSet
            } else if chartConfig.xAxis.valuePosition == .bottom {
                xValueY = chartConfig.chartMargin.top + valueOffSet
            }
        } else if chartConfig.xAxis.position == .bottom {
            if chartConfig.xAxis.valuePosition == .top {
                xValueY = chartConfig.chartMargin.top + chartHeight - attributedString.size().height - valueOffSet
            } else if chartConfig.xAxis.valuePosition == .bottom {
                xValueY = chartConfig.chartMargin.top + chartHeight + valueOffSet
            }
        } else if chartConfig.xAxis.position == .zero {
            let zeroY = HMChartUtil.getAxisZeroY(chartHeight, chartData: chartData)
            guard let zeroY = zeroY else { return }
            xValueY = chartConfig.chartMargin.top + zeroY - attributedString.size().height/2.0
        }
        attributedString.draw(at: CGPoint(x: x, y: xValueY))
    }
    
    private func drawYValue(_ y: CGFloat, chartWidth: CGFloat, yValue: CGFloat, chartConfig: HMBaseChartConfig?) {
        guard let chartConfig = chartConfig else { return }
        
        let yText = String(format: "%@", HMChartUtil.decimalFloatValue(Float(yValue)))
        let valueOffSet = chartConfig.yAxis.valueOffSet
        let attributedString = NSAttributedString(string: yText, attributes: [.foregroundColor: chartConfig.yAxis.textColor, .font: chartConfig.yAxis.textFont])
        let textSize = attributedString.size()
        var yValueX = 0.0
        if chartConfig.yAxis.position == .left {
            if chartConfig.yAxis.valuePosition == .left {
                yValueX = chartConfig.chartMargin.left - attributedString.size().width - valueOffSet
            } else if chartConfig.yAxis.valuePosition == .right {
                yValueX = chartConfig.chartMargin.left + valueOffSet
            }
        } else if chartConfig.yAxis.position == .right {
            if chartConfig.yAxis.valuePosition == .left {
                yValueX = chartConfig.chartMargin.left + chartWidth - attributedString.size().width - valueOffSet
            } else if chartConfig.yAxis.valuePosition == .right {
                yValueX = chartConfig.chartMargin.left + chartWidth + valueOffSet
            }
        }
        attributedString.draw(at: CGPoint(x: yValueX, y: y - textSize.height/2.0))
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
        guard let chartConfig = chartConfig, let chartData = chartData else { return }
        // initPoint(rect.size, chartData: chartData, chartConfig: chartConfig)
        guard let linePoint = HMChartUtil.initLinePoint(rect.size, chartData: chartData, chartConfig: chartConfig) else { return }
        points = linePoint.points
        fillPoints = linePoint.fillPoints
        /// 画 x、y 轴
        drawXandYAxis(context, selfSize: rect.size, chartData: chartData, chartConfig: chartConfig)
        /// 画 x 轴上的值
        drawXAxisValues(rect.size, chartData: chartData, chartConfig: chartConfig)
        /// 画 y 轴上的值
        drawYAxisValues(rect.size, chartData: chartData, chartConfig: chartConfig)
        
        if let lineChartConfig = chartConfig as? HMLineChartConfig {
            // 画折线
            drawLineChart(context, selfSize: rect.size, lineChartConfig: lineChartConfig)
            // 画折线上的点
            drawLinePoint(context, lineChartConfig: lineChartConfig)
        } else if let barChartConfig = chartConfig as? HMBarChartConfig {
            // 画柱状图
            drawBarChart(context, selfSize: rect.size, barChartConfig: barChartConfig)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setNeedsDisplay()
    }
    
    // MARK: UI
    private func setupUI() {
        
    }
    
    // MARK: lazy

}
