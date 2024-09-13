//
//  HMBarChartDemoViewController.swift
//  Demo
//
//  Created by powershare on 2024/1/15.
//

import UIKit

class HMBarChartDemoViewController: UIViewController, HMChartViewDelegate {
    
    private var barChartView1: HMLineChartView!
    private var barChartView2: HMLineChartView!
    private var chartData1: HMChartData!
    private var chartData2: HMChartData!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "柱状图-Demo"
        self.view.backgroundColor = UIColor(red: 246 / 255.0, green: 247 / 255.0, blue: 240 / 255.0, alpha: 1)
        
        addSubView1()
        addSubView2()
    }
    
    private func addSubView1() {
        // 1. 创建 HMLineChartView
        barChartView1 = HMLineChartView()
        barChartView1.delegate = self
        barChartView1.backgroundColor = .white
        self.view.addSubview(barChartView1)
        barChartView1.snp.makeConstraints { make in
            make.top.equalTo(self.view).offset(88)
            make.leading.trailing.equalTo(self.view)
            make.height.equalTo(200)
        }
        
        // 2. 配置图表
        let bgLineConfig = HMChartBgLineConfig()
        let barChartConfig = HMBarChartConfig()
        barChartConfig.xAxis.enabled = true
        
        let lineStyleConfig1 = HMLineStyleConfig()
        lineStyleConfig1.lineColor = .cyan
        lineStyleConfig1.startIndex = 0
        lineStyleConfig1.endIndex = 3
        
        let lineStyleConfig11 = HMLineStyleConfig()
        lineStyleConfig11.lineColor = .blue
        lineStyleConfig11.startIndex = 3
        lineStyleConfig11.endIndex = 10
        barChartConfig.lineStyleConfigs = [[lineStyleConfig1, lineStyleConfig11]]
        barChartView1.setChartConfig(bgLineConfig, chartConfig: barChartConfig)
        
        // 3. 设置数据
        let xlist: [String] = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"]
        let ylist: [[CGFloat]] = [[25, 50, 25, 60, 25, 20, 25, 15, 20, 30]]
        chartData1 = HMChartData()
        chartData1.xlist = xlist
        chartData1.ylist = ylist
        barChartView1.chartData = chartData1
    }
    
    private func addSubView2() {
        // 1. 创建 HMLineChartView
        barChartView2 = HMLineChartView()
        barChartView2.delegate = self
        barChartView2.backgroundColor = .white
        self.view.addSubview(barChartView2)
        barChartView2.snp.makeConstraints { make in
            make.top.equalTo(self.view).offset(388)
            make.leading.trailing.equalTo(self.view)
            make.height.equalTo(200)
        }
        
        // 2. 配置图表
        let bgLineConfig = HMChartBgLineConfig()
        
        let barChartConfig = HMBarChartConfig()
        barChartConfig.xAxis.enabled = true
        barChartConfig.xAxis.position = .zero
        barChartConfig.yAxis.enabled = true
        barChartConfig.yAxis.showValueCount = 5
        barChartConfig.direction = .auto
        
        let lineStyleConfig1 = HMLineStyleConfig()
        lineStyleConfig1.lineColor = .cyan
        lineStyleConfig1.startIndex = 0
        lineStyleConfig1.endIndex = 10
        
        let lineStyleConfig11 = HMLineStyleConfig()
        lineStyleConfig11.lineColor = .blue
        lineStyleConfig11.startIndex = 0
        lineStyleConfig11.endIndex = 10
        barChartConfig.lineStyleConfigs = [[lineStyleConfig1], [lineStyleConfig11]]
        barChartView2.setChartConfig(bgLineConfig, chartConfig: barChartConfig)
        
        // 3. 设置数据
        let xlist: [String] = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"]
        let ylist: [[CGFloat]] = [[25, 50, 25, 60, 25, 20, 25, 15, 20, 30], [-25, -30, -45, -20, -15, -60, -45, -35, -40, -30]]
        chartData2 = HMChartData()
        chartData2.xlist = xlist
        chartData2.ylist = ylist
//        chartData2.minValue = -100
//        chartData2.maxValue = 100
        barChartView2.chartData = chartData2
    }
    
    // MARK: HMChartViewDelegate
    func bubbleViewContent(view: HMLineChartView, selectedIndex: Int) {
        if view == barChartView1 {
            if let xlist = chartData1.xlist, let ylist = chartData1.ylist {
                var content = xlist[selectedIndex] + " & "
                for ylistAry in ylist {
                    content += String(format: "%.0f", ylistAry[selectedIndex])
                }
                barChartView1.bubbleContent = NSAttributedString(string: content)
            }
        } else if view == barChartView2 {
            if let xlist = chartData2.xlist, let ylist = chartData2.ylist {
                var content = xlist[selectedIndex] + " & "
                for ylistAry in ylist {
                    content += String(format: "%.0f", ylistAry[selectedIndex])
                }
                barChartView2.bubbleContent = NSAttributedString(string: content)
            }
        }
    }
    
}
