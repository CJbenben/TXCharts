//
//  HMXAxis.swift
//  Demo
//
//  Created by powershare on 2024/1/19.
//  Copyright © 2024 ChenJie. All rights reserved.
//

import UIKit

/// x 轴
class HMXAxis: HMAxisBase {
    // x 轴位置
    public enum XAxisPosition: Int {
        case top            // 顶部
        case bottom         // 底部
        case zero           // y轴 0 的位置
    }
    // x 轴显示的值 样式
    public enum LineChartXValueStyle: Int {
        case none           // 不显示 x 轴值
        case all            // 显示 x 轴所有值
        case minMax         // 只显示最大值，最小值
    }
    
    /// x 轴位置
    public var position: XAxisPosition = .bottom
    /// x 轴显示值的样式
    public var xValueStyle: LineChartXValueStyle = .none
    /// x 轴上的值相对于 x 轴位置
    public var valuePosition: XAxisPosition = .bottom
    
}
