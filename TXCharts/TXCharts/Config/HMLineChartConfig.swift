//
//  HMLineChartConfig.swift
//  Demo
//
//  Created by powershare on 2024/1/19.
//  Copyright © 2024 ChenJie. All rights reserved.
//

import UIKit

class HMLineStyleConfig: NSObject {
    // 折线上点的描述位置
    public enum LineChartPointDescPosition: Int {
        case none               // 不显示点的描述
        case top                // 描述在点的正上方
        case bottom             // 描述在点的正下方
        case auto               // 描述位置动态计算
    }
    /// 折线的 宽度
    public var lineWidth: CGFloat = 2.0
    /// 折线的 样式
    public var lineStyle: BgLineStyle = .solid
    /// 折线的 颜色
    public var lineColor: UIColor = .black
    /// 折线的 开始位置
    public var startIndex: Int = 0
    /// 折线的 终点位置
    public var endIndex: Int = 0
    /// 线下方是否填充颜色
    public var isNeedFillColor: Bool = true
    
    /// 点上面的描述文字位置
    public var pointDescPosition: LineChartPointDescPosition = .top
}

/// 折线图配置
class HMLineChartConfig: HMBaseChartConfig {
    // 折线图样式
    public enum LineChartStyle: Int {
        case curve      // 曲线
        case stepped    // 直角
        case straight   // 直线
    }
    
    // 折线上点的样式
    public enum LineChartPointStyle: Int {
        case none               // 不显示选中点
        case hollow             // 空心点（中间白色）
        case solid              // 实心点（周边白色）
    }
    
    /// 折线样式
    public var chartStyle: LineChartStyle = .curve
    
    /// 每一段折线样式配置
    public var lineStyleConfigs: [[HMLineStyleConfig]]?
    
    /// 未选中时，折线上普通点样式
    public var normalPointStyle: LineChartPointStyle = .none
    /// 选中时，折线上选中点样式
    public var selectPointStyle: LineChartPointStyle = .hollow
    /// 折线上选中点的圆角
    public var selectPointRadius: CGFloat = 4.0
    
    /// 点上面的文字颜色，默认取折线颜色
    public var pointDescTextColor: UIColor?
    /// 点上面的文字字体
    public var pointDescTextFont: UIFont = UIFont.systemFont(ofSize: 11)
    /// 点上面的文字单位
    public var pointDescUnit: String = ""
    
}
