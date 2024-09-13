//
//  HMChartData.swift
//  Demo
//
//  Created by powershare on 2024/1/17.
//  Copyright © 2024 ChenJie. All rights reserved.
//

import UIKit

/// 图表所需数据
class HMChartData: NSObject {
    /// x 轴数据
    var xlist: [String]?
    /// y 轴数据
    var ylist: [[CGFloat]]?
    /// 当前选中位置下标
    var lineIndex: Int = 0
    /// 图表最大值，默认取 ylist 中最大值
    var maxValue: CGFloat = CGFloat.greatestFiniteMagnitude
    /// 图表最小值，默认取 ylist 中最小值
    var minValue: CGFloat = -CGFloat.greatestFiniteMagnitude
}
