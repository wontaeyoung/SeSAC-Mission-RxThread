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
  private let searchBar = UISearchBar().configured {
    $0.backgroundImage = UIImage()
  }
  
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
  
  private let emptyTextRelay = PublishRelay<Void>()
  private let editItemRelay = PublishRelay<ShopItem>()
  
  // MARK: - Property
  let viewModel: ShoppingViewModel
  
  // MARK: - Initializer
  init(viewModel: ShoppingViewModel) {
    self.viewModel = viewModel
    
    super.init()
  }
  
  // MARK: - Life Cycle
  override func setHierarchy() {
    view.addSubviews(searchBar, inputField, addButton, tableView)
    
    navigationItem.titleView = searchBar
  }
  
  override func setConstraint() {
    inputField.snp.makeConstraints { make in
      make.top.equalTo(view.safeAreaLayoutGuide)
      make.leading.equalTo(view).inset(20)
      make.height.equalTo(40)
    }
    
    addButton.snp.makeConstraints { make in
      make.top.equalTo(inputField)
      make.leading.equalTo(inputField.snp.trailing).offset(10)
      make.trailing.equalTo(view).inset(20)
      make.height.equalTo(40)
    }
    
    tableView.snp.makeConstraints { make in
      make.top.equalTo(inputField.snp.bottom).offset(20)
      make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
    }
  }
  
  override func bind() {
    let input = ShoppingViewModel.Input(
      query: .init(),
      addItem: .init(),
      updateItem: .init(),
      deleteItem: .init(),
      checkboxTapEvent: .init(),
      bookmarkTapEvent: .init()
    )
    
    let output = viewModel.transform(input: input)
    
    output.items
      .drive(tableView.rx.items(cellIdentifier: ShoppingTableCell.identifier, cellType: ShoppingTableCell.self)) { row, element, cell in
        cell.updateUI(with: element)
        
        cell.checkboxButtonTapEvent {
          input.checkboxTapEvent.accept(element.id)
        }
        
        cell.bookmarkButtonTapEvent {
          input.bookmarkTapEvent.accept(element.id)
        }
      }
      .disposed(by: disposeBag)
      
    tableView.rx.modelSelected(ShopItem.self)
      .bind(with: self) { owner, item in
        owner.presentEditSheet(with: item)
      }
      .disposed(by: disposeBag)
    
    tableView.rx.itemDeleted
      .withUnretained(self)
      .compactMap { owner, indexPath in
        try owner.tableView.rx.model(at: indexPath) as ShopItem
      }
      .map { $0.id }
      .bind(to: input.deleteItem)
      .disposed(by: disposeBag)
    
    let emptyText = emptyTextRelay.map { "" }
    
    emptyText
      .bind(to: inputField.rx.text)
      .disposed(by: disposeBag)
    
    emptyText
      .map { _ in false }
      .bind(to: addButton.rx.isEnabled)
      .disposed(by: disposeBag)
    
    searchBar.rx.text.orEmpty
      .distinctUntilChanged()
      .debounce(.seconds(1), scheduler: MainScheduler.instance)
      .bind(to: input.query)
      .disposed(by: disposeBag)
     
    inputField.rx.text.orEmpty
      .map { !$0.isEmpty }
      .bind(to: addButton.rx.isEnabled)
      .disposed(by: disposeBag)
    
    addButton.rx.tap
      .withLatestFrom(inputField.rx.text.orEmpty)
      .filter { !$0.isEmpty }
      .do { _ in
        self.emptyTextRelay.accept(())
      }
      .map { ShopItem(name: $0) }
      .bind(to: input.addItem)
      .disposed(by: disposeBag)
    
    editItemRelay
      .bind(to: input.updateItem)
      .disposed(by: disposeBag)
  }
  
  private func presentEditSheet(with item: ShopItem) {
    let vc = EditShoppingSheetController(item: item)
    
    vc.itemRelay
      .bind(to: editItemRelay)
      .disposed(by: disposeBag)
    
    navigationController?.pushViewController(vc, animated: true)
  }
}
