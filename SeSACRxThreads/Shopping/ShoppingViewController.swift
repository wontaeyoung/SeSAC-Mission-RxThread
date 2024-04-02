//
//  ShoppingViewController.swift
//  SeSACRxThreads
//
//  Created by 원태영 on 4/2/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class ShoppingViewController: RxBaseViewController, ViewModelController {
  
  // MARK: - UI
  private let inputField = SignTextField(placeholderText: "무엇을 구매하실건가요?")
  private let addButton = UIButton().configured {
    $0.configuration = .filled().configured {
      $0.title = "추가하기"
      $0.cornerStyle = .medium
      $0.buttonSize = .medium
    }
  }
  
  private lazy var tableView = UITableView().configured {
    $0.register(ShoppingTableCell.self, forCellReuseIdentifier: ShoppingTableCell.identifier)
    $0.rowHeight = 60
    $0.separatorStyle = .none
    $0.keyboardDismissMode = .onDrag
  }
  
  // MARK: - Property
  let viewModel: ShoppingViewModel
  
  // MARK: - Initializer
  init(viewModel: ShoppingViewModel) {
    self.viewModel = viewModel
    
    super.init()
  }
  
  // MARK: - Life Cycle
  override func setHierarchy() {
    view.addSubviews(inputField, addButton, tableView)
  }
  
  override func setConstraint() {
    inputField.snp.makeConstraints { make in
      make.top.equalTo(view.safeAreaLayoutGuide)
      make.leading.equalTo(view).inset(20)
      make.height.equalTo(50)
    }
    
    addButton.snp.makeConstraints { make in
      make.top.equalTo(inputField)
      make.leading.equalTo(inputField.snp.trailing).offset(10)
      make.trailing.equalTo(view).inset(20)
      make.height.equalTo(50)
    }
    
    tableView.snp.makeConstraints { make in
      make.top.equalTo(inputField.snp.bottom).offset(20)
      make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
    }
  }
  
  override func bind() {
    
  }
}
