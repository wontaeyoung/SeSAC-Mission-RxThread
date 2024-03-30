//
//  SampleViewController.swift
//  SeSACRxThreads
//
//  Created by 원태영 on 3/30/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import KazUtility

final class SampleViewController: UIViewController {
  
  private let inputField = SignTextField(placeholderText: "이름을 입력해주세요").configured {
    $0.spellCheckingType = .no
    $0.autocorrectionType = .no
    $0.autocapitalizationType = .none
  }
  
  private let applyButton = UIButton().configured {
    $0.configuration = .filled().configured {
      $0.title = "추가하기"
      $0.cornerStyle = .medium
    }
  }
  
  private let tableView = UITableView().configured {
    $0.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    $0.backgroundColor = .lightGray
  }
  
  private var list: [String] = [] {
    didSet {
      listSubject.onNext(list)
    }
  }
  
  private let disposeBag = DisposeBag()
  private let listSubject = BehaviorSubject<[String]>(value: [])
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = Color.white
    configureLayout()
    bind()
  }
  
  func configureLayout() {
    view.addSubviews(inputField, applyButton, tableView)
    
    inputField.snp.makeConstraints { make in
      make.top.equalTo(view.safeAreaLayoutGuide).inset(20)
      make.leading.equalTo(view).inset(20)
      make.height.equalTo(40)
    }
    
    applyButton.snp.makeConstraints { make in
      make.top.equalTo(inputField)
      make.leading.equalTo(inputField.snp.trailing).offset(20)
      make.trailing.equalTo(view).inset(20)
      make.width.equalTo(100)
      make.height.equalTo(40)
    }
    
    tableView.snp.makeConstraints { make in
      make.top.equalTo(inputField.snp.bottom).offset(20)
      make.horizontalEdges.equalTo(view)
      make.bottom.equalTo(view.safeAreaLayoutGuide)
    }
  }
  
  private func bind() {
    listSubject
      .bind(to: tableView.rx.items(cellIdentifier: "Cell")) { row, item, cell in
        cell.textLabel?.text = "\(row) - \(item)"
      }
      .disposed(by: disposeBag)
    
    tableView.rx.itemSelected
      .bind(with: self) { owner, indexPath in
        owner.list.remove(at: indexPath.row)
      }
      .disposed(by: disposeBag)
    
    inputField.rx.text.orEmpty
      .map { !$0.isEmpty }
      .bind(to: applyButton.rx.isEnabled)
      .disposed(by: disposeBag)
    
    applyButton.rx.tap
      .withLatestFrom(inputField.rx.text.orEmpty)
      .bind(with: self) { owner, text in
        owner.addItem(with: text)
      }
      .disposed(by: disposeBag)
  }
  
  private func addItem(with text: String) {
    list.append(text)
  }
}
