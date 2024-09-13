//
//  HMLineChartDemoViewController.swift
//  Demo
//
//  Created by powershare on 2024/1/15.
//

import UIKit

class HMLineChartDemoViewController: UIViewController, HMChartViewDelegate {
    
    private var curveChartView: HMLineChartView!
    private var chartData: HMChartData!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "折线图-Demo"
        self.view.backgroundColor = UIColor(red: 246 / 255.0, green: 247 / 255.0, blue: 240 / 255.0, alpha: 1)
        
        // 1. 创建 HMLineChartView
        curveChartView = HMLineChartView(frame: CGRect(x: 0, y: 88, width: UIScreen.main.bounds.size.width, height: 200))
        curveChartView.delegate = self
        curveChartView.backgroundColor = .white
        self.view.addSubview(curveChartView)
        
        // 2. 配置图表
        let bgLineConfig = HMChartBgLineConfig()
        let lineChartConfig = HMLineChartConfig()
        curveChartView.setChartConfig(bgLineConfig, chartConfig: lineChartConfig)
        
        // 3. 设置数据
        let xlist: [String] = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"]
        let ylist: [[CGFloat]] = [[25, 50, 25, 60, 25, 20, -20, 0, 20, 30], [-20, -50, -60, 0, -25, -20, -40, 0, -20, -30]]
        chartData = HMChartData()
        chartData.xlist = xlist
        chartData.ylist = ylist
        curveChartView.chartData = chartData
    }
    
    // MARK: HMChartViewDelegate
    func bubbleViewContent(view: HMLineChartView, selectedIndex: Int) {
        if let xlist = chartData.xlist, let ylist = chartData.ylist {
            var content = xlist[selectedIndex] + " & "
            for ylistAry in ylist {
                content += String(format: "%.0f", ylistAry[selectedIndex])
            }
            curveChartView.bubbleContent = NSAttributedString(string: content)
        }
    }
    
}
