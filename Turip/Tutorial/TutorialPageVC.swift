//
//  ViewController.swift
//  Turip
//
//  Created by 山田航輝 on 2023/08/30.
//

import UIKit
import HealthKit

class TutorialPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var viewControllerList: [UIViewController] = [] //VCの配列
    
    var comeFrom: String = ""
    var from: Int = 0
    var to: Int = 0
    
    let healthStore = HKHealthStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if comeFrom == "signup" {
//            inst1-10, instFin
            setPage(from: 1, to: 11) //メソッドの呼び出し
            
        } else if comeFrom == "trip" {
//            inst2-7
            setPage(from: 2, to: 7)
            
        } else if comeFrom == "tour" {
//            inst8-10
            setPage(from: 8, to: 10)
        }
        
        
        self.dataSource = self
        self.delegate = self
        
        //表示するVC決定
        self.setViewControllers([viewControllerList[0]], direction: .forward, animated: true, completion: nil)
        
        self.navigationController?.navigationBar.isHidden = true
        
    }
    
    
    //superクラス - PageVC呼出 scroll水平
    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //前ページの取得
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = viewControllerList.firstIndex(of: viewController) else { return nil } //現在のVC取得
        
        let prevIndex = index - 1
        
        guard prevIndex >= 0 else { return nil } //1ページ目だったら-1となるのでnil
        
        return viewControllerList[prevIndex]
    }
    
    
    //後ページの取得
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = viewControllerList.firstIndex(of: viewController) else { return nil } //現在のVC取得
        
        let nextIndex = index + 1
        
        guard nextIndex < viewControllerList.count else { return nil }
        
        return viewControllerList[nextIndex]
    }
    
    
    //ページインジケータ
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return viewControllerList.count // ページの総数
    }
    
    // 現在表示しているページのインデックスを表示
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        //vc探す・index取得
        guard let firstViewController = viewControllers?.first, let firstViewControllerIndex = viewControllerList.firstIndex(of: firstViewController) else {
            return 0
        }
        return firstViewControllerIndex
    }
    
    //pageのセット
    func setPage(from: Int, to: Int) {
        
        viewControllerList = []
        
        for n in from...to {
            let mainSB = UIStoryboard(name: "Tutorial", bundle: nil)
            let vc = mainSB.instantiateViewController(withIdentifier: "inst\(n)") //インスタンス化
            viewControllerList.append(vc)
        }
        
        if from == 1 {
            let tutorialSB = UIStoryboard(name: "Main", bundle: nil)
            let vcFinal = tutorialSB.instantiateViewController(withIdentifier: "instFin")
            viewControllerList.append(vcFinal)
        }
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
