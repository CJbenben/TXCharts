//
//  ViewController.swift
//  TXCharts
//
//  Created by powershare on 2024/9/9.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private var dataAry: [String] = ["折线图-曲线", "折线图-直角", "折线图-直线", "折线图-合并", "折线图-demo", "柱状图"]
    // MARK: Public Method
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "图表"
        setupUI()
    }
    
    // MARK: Action
    
    // MARK: Private Method - Request
    
    // MARK: Private Method
    
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataAry.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self), for: indexPath)
        cell.textLabel?.text = dataAry[indexPath.row]
        return cell
    }
    
    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            let lineChartVC = HMLineChartCurveViewController()
            navigationController?.pushViewController(lineChartVC, animated: true)
        } else if indexPath.row == 1 {
            let lineChartVC2 = HMLineChartSteppedViewController()
            navigationController?.pushViewController(lineChartVC2, animated: true)
        } else if indexPath.row == 2 {
            let newLineChartVC = HMLineChartStraightViewController()
            navigationController?.pushViewController(newLineChartVC, animated: true)
        } else if indexPath.row == 3 {
            let lineChartVC2 = HMLineChartViewController()
            navigationController?.pushViewController(lineChartVC2, animated: true)
        } else if indexPath.row == 4 {
            let lineChartVC = HMLineChartDemoViewController()
            navigationController?.pushViewController(lineChartVC, animated: true)
        } else if indexPath.row == 5 {
            let barChartVC = HMBarChartDemoViewController()
            navigationController?.pushViewController(barChartVC, animated: true)
        }
    }
    
    // MARK: UI
    private func setupUI() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
    }
    
    // MARK: lazy
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: String(describing: UITableViewCell.self))
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0.0
        }
        return tableView
    }()

}
