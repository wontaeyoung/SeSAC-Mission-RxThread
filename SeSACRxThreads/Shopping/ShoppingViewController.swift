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
  
  private let emptyTextRelay = PublishRelay<Void>()
  private let editItemRelay = PublishRelay<(indexPath: IndexPath, item: ShopItem)>()
  
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
    let input = ShoppingViewModel.Input(
      queryItems: .init(),
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
          input.checkboxTapEvent.accept(row)
        }
        
        cell.bookmarkButtonTapEvent {
          input.bookmarkTapEvent.accept(row)
        }
      }
      .disposed(by: disposeBag)
      
    tableView.rx.itemDeleted
      .bind(to: input.deleteItem)
      .disposed(by: disposeBag)
    
    Observable.zip(
      tableView.rx.itemSelected,
      tableView.rx.modelSelected(ShopItem.self)
    )
    .subscribe(with: self) { owner, row in
      let (index, item) = row
      owner.presentEditSheet(at: index, with: item)
    }
    .disposed(by: disposeBag)
    
    emptyTextRelay
      .map { "" }
      .bind(to: inputField.rx.text)
      .disposed(by: disposeBag)
    
    emptyTextRelay
      .map { false }
      .bind(to: addButton.rx.isEnabled)
      .disposed(by: disposeBag)
    
    inputField.rx.text.orEmpty
      .map { !$0.isEmpty }
      .bind(to: addButton.rx.isEnabled)
      .disposed(by: disposeBag)
    
    /** 실시간 검색 기능과 데이터 업데이트 충돌로 주석처리
    inputField.rx.text.orEmpty
      .distinctUntilChanged()
      .debounce(.seconds(1), scheduler: MainScheduler.instance)
      .bind(to: input.queryItems)
      .disposed(by: disposeBag)
     */
    
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
      .map { ($0.indexPath, $0.item) }
      .bind(to: input.updateItem)
      .disposed(by: disposeBag)
  }
  
  private func presentEditSheet(at indexPath: IndexPath, with item: ShopItem) {
    let vc = EditShoppingSheetController(item: item)
    
    vc.itemRelay
      .map { (indexPath, $0) }
      .bind(to: editItemRelay)
      .disposed(by: disposeBag)
    
    navigationController?.pushViewController(vc, animated: true)
  }
}
