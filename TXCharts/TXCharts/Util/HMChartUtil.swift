//
//  HMChartUtil.swift
//  Demo
//
//  Created by powershare on 2023/12/7.
//

import UIKit

/// 图表工具类
class HMChartUtil: NSObject {
    // MARK: Public Method
    public class func maxNumberConvert(_ originNumer: CGFloat) -> Int? {
        return self.numberConvert(originNumer, isMax: true, isMin: false)
    }
    
    public class func minNumberConvert(_ originNumer: CGFloat) -> Int? {
        return self.numberConvert(originNumer, isMax: false, isMin: true)
    }
    
    public class func maxNumberConvert(_ originNumer: CGFloat, multiple: Int) -> Int? {
        return self.numberConvert(originNumer, multiple: multiple, isMax: true, isMin: false)
    }
    
    public class func minNumberConvert(_ originNumer: CGFloat, multiple: Int) -> Int? {
        return self.numberConvert(originNumer, multiple: multiple, isMax: false, isMin: true)
    }
    
    /// 获取原始数据的最大值，最小值
    public class func getMaxAndMinValue(_ values: [[CGFloat]]) -> (max: CGFloat, min: CGFloat) {
        var maxElement: CGFloat = -CGFloat.greatestFiniteMagnitude// values[0][0]
        var minElement: CGFloat = CGFloat.greatestFiniteMagnitude// values[0][0]
        for row in values {
            for value in row {
                if value == CGFloat.greatestFiniteMagnitude || value == -CGFloat.greatestFiniteMagnitude {
                    continue
                }
                if value > maxElement {
                    maxElement = value
                } else if value < minElement {
                    minElement = value
                }
            }
        }
        return (maxElement, minElement)
    }
    
    public class func getConvertMaxAndMinValue(_ maxValue: CGFloat, minValue: CGFloat) -> (max: CGFloat, min: CGFloat) {
        var newMaxValue = maxValue
        var newMinValue = minValue
        // 最大值小于最小值
        if maxValue < minValue {
            newMaxValue = minValue
            newMinValue = maxValue
        }
        if newMaxValue == 0 && newMaxValue == 0 {
            newMaxValue = 1
            newMinValue = 0
            return (newMaxValue, newMinValue)
        }
        // 最大值取 原始最大值和最小值绝对值的最大值
        newMaxValue = max(abs(newMaxValue), abs(newMinValue))
        // 最小值大于0，取0
        if newMinValue > 0 {
            newMinValue = 0
        }
        // 把新最大值最小值，转为 5/4 倍数，保持图标上下有间距
        newMaxValue = newMaxValue * 5 / 4
        newMinValue = newMinValue * 5 / 4
        return (newMaxValue, newMinValue)
    }
    
    static func getMaxMinValueAndIndex(_ array: [CGFloat]) -> (maxValue: CGFloat, maxIndex: Int, minValue: CGFloat, minIndex: Int)? {
        guard !array.isEmpty else {
            return nil
        }
        var maxValue = -CGFloat.greatestFiniteMagnitude
        var minValue = CGFloat.greatestFiniteMagnitude
        var maxValueIndex = 0
        var minValueIndex = 0
        
        for (index, value) in array.enumerated() {
            if value == CGFloat.greatestFiniteMagnitude {
                continue
            }
            if value > maxValue {
                maxValue = value
                maxValueIndex = index
            }
            if value < minValue {
                minValue = value
                minValueIndex = index
            }
        }
        return (maxValue: maxValue, maxIndex: maxValueIndex, minValue: minValue, minIndex: minValueIndex)
    }

    /// 递归查询非空的下标值，向下没有查询到会从原始值向上递归，返回 -1 表示未找到
    public class func recursiveSearchNoNullIndex(_ yLists: [[CGFloat]], currIndex: Int, originalIndex: Int) -> Int? {
        guard !yLists.isEmpty else {
            return nil
        }
        if currIndex < 0 {
            // 达到最小下标时仍未找到，开始向上递归
            return recursiveSearchNoNullIndexUp(yLists, originalIndex: originalIndex)
        }
//        print("向下递归 -> recursiveSearchNoNullIndex currIndex = \(currIndex)")
        for row in yLists {
            if currIndex >= row.count {
//                print("递归方法 -> recursiveSearchNoNullIndex 越界")
                return nil
            }
            if row[currIndex] == CGFloat.greatestFiniteMagnitude {
                return recursiveSearchNoNullIndex(yLists, currIndex: currIndex - 1, originalIndex: originalIndex)
            } else {
                return currIndex
            }
        }
        return nil
    }
    
    /// 向上递归查询
    public class func recursiveSearchNoNullIndexUp(_ yLists: [[CGFloat]], originalIndex: Int) -> Int? {
        if originalIndex >= yLists[0].count {
            // 达到最大下标时仍未找到，开始向上递归
            return nil
        }
//        print("向上递归 -> recursiveSearchNoNullIndex originalIndex = \(originalIndex)")
        for row in yLists {
            if originalIndex >= row.count {
//                print("递归方法 -> recursiveSearchNoNullIndexUp 越界")
                return nil
            }
            if row[originalIndex] == CGFloat.greatestFiniteMagnitude {
                return recursiveSearchNoNullIndexUp(yLists, originalIndex: originalIndex + 1)
            } else {
                return originalIndex
            }
        }
        return nil
    }
    
    /// 向后查询第一个不是 null 的下标，从 fromIndex 开始查找
    public class func returnNoNullIndexAfter(_ points: [CGPoint]?, fromIndex: Int) -> Int? {
        guard let points = points, !points.isEmpty else { return nil }
        if fromIndex > points.count - 1 {
//            print("chart - 向后递归没有查询到非 null 下标：points = \(points)")
            return nil
        }
        let currPoint = points[fromIndex]
        if self.isEmptyOrMaxValue(currPoint.y) {
            return returnNoNullIndexAfter(points, fromIndex: fromIndex+1)
        }
        return fromIndex
    }
    
    /// 向前查询第一个不是 null 的下标，从 fromIndex 开始查找
    public class func returnNoNullIndexBefore(_ points: [CGPoint]?, fromIndex: Int) -> Int? {
        guard let points = points, !points.isEmpty else { return nil }
        if fromIndex < 0 {
//            print("chart - 向前递归没有查询到非 null 下标：points = \(points)")
            return nil
        }
        let currPoint = points[fromIndex]
        if self.isEmptyOrMaxValue(currPoint.y) {
            return returnNoNullIndexBefore(points, fromIndex: fromIndex-1)
        }
        return fromIndex
    }
    
    // 判断一个二维数组里面 value 是否有 CGFLOAT_MAX
    public class func judgmentElementHaveNull(_ values: [[CGFloat]], selectIndex: Int) -> Bool {
        for row in values {
            if row.count <= selectIndex || row[selectIndex] == CGFloat.greatestFiniteMagnitude {
                return true
            }
        }
        return false
    }
    
    public class func isEmptyOrMaxValue(_ value: CGFloat?) -> Bool {
        guard let value = value else { return true }
        if value == CGFloat.greatestFiniteMagnitude || value == -CGFloat.greatestFiniteMagnitude {
            return true
        }
        return false
    }
    
    /// 传入一个二维数组，求元素最小长度
    public class func getArrayMinLength(_ values: [[CGFloat]]) -> Int {
        guard !values.isEmpty else {
            return 0
        }
        var minLength = values[0].count
        for value in values {
            if value.count < minLength {
                minLength = value.count
            }
        }
        return minLength
    }
    
    /// float 千分位转换
    public class func decimalFloatValue(_ value: Float) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
//        let country = HEMSLanguageUtil.getSystemLanguageStrFromCompanyLanguageStr()
//        formatter.locale = Locale.init(identifier: country)
        formatter.minimumFractionDigits = self.numberOfDecimalPlaces(for: value)
        formatter.maximumFractionDigits = self.numberOfDecimalPlaces(for: value)
        return formatter.string(from: NSNumber(value: value)) ?? ""
    }
    
    public class func decimalFloatValue(_ value: Float, digits: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
//        let country = HEMSLanguageUtil.getSystemLanguageStrFromCompanyLanguageStr()
//        formatter.locale = Locale.init(identifier: country)
        formatter.minimumFractionDigits = digits
        formatter.maximumFractionDigits = digits
        return formatter.string(from: NSNumber(value: value)) ?? ""
    }
    
    // MARK: 折线图使用方法
    public class func initLinePoint(_ selfSize: CGSize, chartData: HMChartData?, chartConfig: HMBaseChartConfig?) -> (points: [[CGPoint]], fillPoints: [[CGPoint]])? {
        guard let chartData = chartData, let chartConfig = chartConfig, let ylist = chartData.ylist else { return nil }
        // 如果没有设置 最大值，最小值，通过 ylist 自己算最大值，最小值
        if chartData.maxValue == CGFloat.greatestFiniteMagnitude || chartData.minValue == -CGFloat.greatestFiniteMagnitude {
            let maxAndMinValue = HMChartUtil.getMaxAndMinValue(ylist)
            if chartData.maxValue == CGFloat.greatestFiniteMagnitude {
                chartData.maxValue = maxAndMinValue.max
            } else if chartData.minValue == -CGFloat.greatestFiniteMagnitude {
                chartData.minValue = maxAndMinValue.min
            }
        }
        // 防止：0线跑出图表 frame
        if chartConfig.xAxis.position == .zero {
            if chartData.maxValue < 0 {
                chartData.maxValue = 0
            }
            if chartData.minValue > 0 {
                chartData.minValue = 0
            }
        }
        let chartWidth = selfSize.width - chartConfig.chartMargin.left - chartConfig.chartMargin.right
        let chartHeight = selfSize.height - chartConfig.chartMargin.top - chartConfig.chartMargin.bottom
        var points: [[CGPoint]] = []
        var fillPoints: [[CGPoint]] = []
        for i in 0..<ylist.count {
            if ylist[i].isEmpty {
                continue
            }
            var proportionWidth = chartWidth / CGFloat(ylist[i].count - 1)
            if let chartConfig = chartConfig as? HMLineChartConfig {
                if chartConfig.chartStyle == .stepped {
                    proportionWidth = chartWidth / CGFloat(ylist[i].count)
                }
            }
            var proportionHeight = 0.0
            let valeHeight = chartData.maxValue - chartData.minValue
            if chartData.maxValue != CGFloat.greatestFiniteMagnitude {
                proportionHeight = chartHeight / valeHeight
            }
            var circleCenterX = chartConfig.chartMargin.left
            var circleCenterY = chartConfig.chartMargin.top
            var point: [CGPoint] = []
            var temFillPoint: [CGPoint] = []
            for j in 0..<ylist[i].count {
                if ylist[i][j] != CGFloat.greatestFiniteMagnitude {
                    let currentProportionHeight = (ylist[i][j] - chartData.minValue) * proportionHeight
                    circleCenterY = chartHeight - currentProportionHeight + chartConfig.chartMargin.top
                } else {
                    circleCenterY = CGFLOAT_MAX
                }
                let circleCenter = CGPoint(x: circleCenterX, y: circleCenterY)
                let circleCenterNext =  CGPoint(x: circleCenterX + proportionWidth/2.0, y: circleCenterY)
                let circleCenterNext2 =  CGPoint(x: circleCenterX + proportionWidth, y: circleCenterY)
                point.append(circleCenter)
                temFillPoint.append(circleCenter)
                temFillPoint.append(circleCenterNext)
                temFillPoint.append(circleCenterNext2)
                circleCenterX += proportionWidth
            }
            points.append(point)
            fillPoints.append(temFillPoint)
//            print("通过 Y 值计算出中心 points 坐标 yLists -> points = \(points), \n fillPoints = \(fillPoints)")
//            print("chartHeight = \(chartHeight)")
        }
        return (points, fillPoints)
    }
    
    // 获取 x 轴零线 y 轴坐标值
    public class func getAxisZeroY(_ chartHeight: CGFloat, chartData: HMChartData?) -> CGFloat? {
        guard let chartData = chartData, chartData.maxValue != chartData.minValue else { return nil }
        
        let yDensityValue = chartData.maxValue - chartData.minValue // chartHeight
        // chartData.maxValue - 0 // ?
        let zeroY = chartHeight * chartData.maxValue / yDensityValue
        return zeroY
    }
    
    // MARK: Private Method
    /// 把 CGFloat 转化为指定倍数的数字，此方法会自动计算倍数，12.2 就是 10 倍，213.2 就是 100 倍，1866.2 就是 1000 倍
    private class func numberConvert(_ originNumer: CGFloat, isMax: Bool, isMin: Bool) -> Int? {
        if originNumer == CGFloat.greatestFiniteMagnitude || originNumer == -CGFloat.greatestFiniteMagnitude {
            return nil
        }
        if abs(originNumer) <= 10 {
            return self.numberConvert(originNumer, multiple: 10, isMax: isMax, isMin: isMin)
        }
        // 计算 位数、倍数
        let digitCount = String(Int(abs(originNumer))).count
        let multiple = pow(10, digitCount - 1) as NSDecimalNumber
        return self.numberConvert(originNumer, multiple: multiple.intValue, isMax: isMax, isMin: isMin)
    }
    
    /// 把 CGFloat 转化为指定倍数的数字，如倍数是10时 36.4 -> 40，倍数是100时 36.4 -> 100
    private class func numberConvert(_ originNumer: CGFloat, multiple: Int, isMax: Bool, isMin: Bool) -> Int? {
        if multiple == 0 {
            print("multiple is not 0")
            return 0
        }
        if originNumer == 0 {
            return 0
        }
        let result = Int(originNumer) / multiple 
        if originNumer > 0 {
            if isMax {
                return (result + 1) * multiple
            }
            if isMin {
                return result * multiple
            }
        } else {
            if isMax {
                return result * multiple
            }
            if isMin {
                return (result - 1) * multiple
            }
        }
        return 0
    }
    
    private class func numberOfDecimalPlaces(for number: Float) -> Int {
        var stringValue = String(number)
        if number.truncatingRemainder(dividingBy: 1) == 0 {
            stringValue = String(format: "%.0f", number)
        }
        if let dotIndex = stringValue.firstIndex(of: ".") {
            let decimalPlaces = stringValue.distance(from: dotIndex, to: stringValue.endIndex) - 1
            return decimalPlaces
        }
        return 0
    }
}
