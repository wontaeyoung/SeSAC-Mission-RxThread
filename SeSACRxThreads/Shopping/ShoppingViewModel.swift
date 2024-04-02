//
//  ShoppingViewModel.swift
//  SeSACRxThreads
//
//  Created by 원태영 on 4/2/24.
//

import Foundation
import RxSwift
import RxCocoa

final class ShoppingViewModel: ViewModel {
  
  // MARK: - I / O
  struct Input {
    let addItem: PublishRelay<ShopItem>
    let deleteItem: PublishRelay<IndexPath>
    let checkboxTapEvent: PublishRelay<Int>
    let bookmarkTapEvent: PublishRelay<Int>
  }
  
  struct Output {
    let items: Driver<[ShopItem]>
  }
  
  private var items: [ShopItem] = [] {
    didSet {
      itemsRelay.accept(items)
    }
  }
  
  // MARK: - Observable
  private lazy var itemsRelay = BehaviorRelay<[ShopItem]>(value: items)
  
  // MARK: - Property
  let disposeBag = DisposeBag()
  
  // MARK: - Method
  func transform(input: Input) -> Output {
    
    input.addItem
      .subscribe(with: self) { owner, item in
        owner.addItem(with: item)
      }
      .disposed(by: disposeBag)
    
    input.deleteItem
      .subscribe(with: self) { owner, indexPath in
        owner.deleteItem(at: indexPath)
      }
      .disposed(by: disposeBag)
    
    input.checkboxTapEvent
      .subscribe(with: self) { owner, index in
        owner.toggleCheckbox(at: index)
      }
      .disposed(by: disposeBag)
    
    input.bookmarkTapEvent
      .subscribe(with: self) { owner, index in
        owner.toggleBookmark(at: index)
      }
      .disposed(by: disposeBag)
    
    return Output(items: itemsRelay.asDriver())
  }
  
  private func addItem(with item: ShopItem) {
    items.insert(item, at: 0)
  }
  
  private func deleteItem(at indexPath: IndexPath) {
    items.remove(at: indexPath.row)
  }
  
  private func toggleCheckbox(at index: Int) {
    items[index].isDone.toggle()
  }
  
  private func toggleBookmark(at index: Int) {
    items[index].bookmark.toggle()
  }
}
