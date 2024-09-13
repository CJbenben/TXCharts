//
//  HMBaseChartConfig.swift
//  Demo
//
//  Created by powershare on 2024/1/17.
//  Copyright © 2024 ChenJie. All rights reserved.
//

import UIKit

/// 基础配置
class HMBaseChartConfig: NSObject {
    /// 图表距离父视图 margin
    public var chartMargin: UIEdgeInsets = .init(top: 12, left: 20, bottom: 36, right: 20)
    /// x 轴
    public var xAxis: HMXAxis = HMXAxis()
    /// y 轴
    public var yAxis: HMYAxis = HMYAxis()
    /// 是否需要处理 null 值情况
    public var handleNull: Bool = true
    
    /// 是否显示竖直方向选中线，false：不显示线，但还会显示选中点
    public var isShowVerticalSeletedLine: Bool = true
    /// 是否显示水平方向选中线，false：不显示线，只有一条线生效
    public var isShowHorizontalSeletedLine: Bool = false
    /// 选中时，是否显示背景阴影
    public var isShowSelectShadow: Bool = false
    /// 选中时，背景阴影颜色
    public var selectShadowColor = UIColor(red: 238 / 255.0, green: 238 / 255.0, blue: 238 / 255.0, alpha: 0.2)
    /// 选中时，背景阴影宽度，默认值：两个 x 轴之间的宽度
    public var selectShadowWidth: CGFloat?
    
    /// 滑动时是否隐藏底部 x 值
    public var isHiddenSlideXValue: Bool = false
    
    /// 是否设置：只显示最大值和最小值
    public var pointDescOnlyMaxAndMin: Bool = false
    /// 最大值内容，默认取最大值数字
    public var pointDescMaxValue: NSAttributedString?
    /// 最小值内容，默认取最小值数字
    public var pointDescMinValue: NSAttributedString?
    
    /// 是否显示气泡
    public var isShowBubble: Bool = true
    /// 气泡背景颜色
    public var bubbleBackgroudColor: UIColor = UIColor(red: 40 / 255.0, green: 41 / 255.0, blue: 41 / 255.0, alpha: 1)
    /// 气泡圆角
    public var bubbleRadius: CGFloat = 4.0
    /// 气泡中内容距离气泡边距
    public var bubbleMargin: UIEdgeInsets = .init(top: 12.5, left: 10, bottom: 12.5, right: 10)
    
}
