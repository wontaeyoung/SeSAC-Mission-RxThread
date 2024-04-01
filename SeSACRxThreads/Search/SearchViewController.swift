//
//  SearchViewController.swift
//  SeSACRxThreads
//
//  Created by jack on 2024/04/01.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import KazUtility

final class SearchViewController: UIViewController {
  
  private let tableView = UITableView().configured {
    $0.register(SearchTableViewCell.self, forCellReuseIdentifier: SearchTableViewCell.identifier)
    $0.backgroundColor = .white
    $0.rowHeight = 120
    $0.separatorStyle = .none
  }
  
  private let searchBar = UISearchBar()
  
  
  private var data = ["A", "B", "C", "AB", "D", "ABC", "BBB", "EC", "SA", "AAAB", "ED", "F", "G", "H"] {
    didSet {
      items.onNext(data)
    }
  }
  
  private let disposeBag = DisposeBag()
  private lazy var items = BehaviorSubject(value: data)
  private let downloadTapEvent = PublishSubject<Void>()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .white
    configure()
    setSearchController()
    bind()
  }
  
  private func setSearchController() {
    view.addSubview(searchBar)
    navigationItem.titleView = searchBar
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "추가", style: .plain, target: self, action: #selector(plusButtonClicked))
  }
  
  @objc func plusButtonClicked() {
    let sample = searchBar.text!
    data.append(sample)
    
    searchBar.text = nil
  }
  
  private func configure() {
    view.addSubview(tableView)
    tableView.snp.makeConstraints {
      $0.edges.equalTo(view.safeAreaLayoutGuide)
    }
  }
  
  private func bind() {
    items
      .bind(to: tableView.rx.items(cellIdentifier: SearchTableViewCell.identifier, cellType: SearchTableViewCell.self)) { row, element, cell in
        cell.updateUI(data: element)
        cell.tapEvent(observer: self.downloadTapEvent)
      }
      .disposed(by: disposeBag)
    
    searchBar.rx.text.orEmpty
      .debounce(.seconds(1), scheduler: MainScheduler.instance)
      .distinctUntilChanged()
      .withUnretained(self)
      .map { owner, text in
        owner.filterItems(query: text)
      }
      .bind(to: items)
      .disposed(by: disposeBag)
    
    searchBar.rx.searchButtonClicked
      .withLatestFrom(searchBar.rx.text.orEmpty)
      .distinctUntilChanged()
      .withUnretained(self)
      .map { owner, text in
        owner.filterItems(query: text)
      }
      .bind(to: items)
      .disposed(by: disposeBag)
    
    downloadTapEvent
      .bind(with: self) { owner, _ in
        owner.navigationController?.pushViewController(BirthdayViewController(), animated: true)
      }
      .disposed(by: disposeBag)
    
    Observable.zip(tableView.rx.itemSelected, tableView.rx.modelSelected(String.self))
      .bind(with: self) { owner, value in
        let (indexPath, _) = value
        
        owner.data.remove(at: indexPath.row)
      }
      .disposed(by: disposeBag)
  }
  
  private func filterItems(query: String) -> [String] {
    return query.isEmpty ? data : data.filter { $0.contains(query) }
  }
}
