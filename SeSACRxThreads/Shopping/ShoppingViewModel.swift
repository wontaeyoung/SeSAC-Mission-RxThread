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
    let queryItems: PublishRelay<String>
    let addItem: PublishRelay<ShopItem>
    let updateItem: PublishRelay<(at: IndexPath, updated: ShopItem)>
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
    
    input.queryItems
      .withUnretained(self)
      .map { owner, query in
        query.isEmpty
        ? owner.items
        : owner.items.filter { $0.name.contains(query) }
      }
      .bind(to: itemsRelay)
      .disposed(by: disposeBag)
    
    input.addItem
      .subscribe(with: self) { owner, item in
        owner.addItem(with: item)
      }
      .disposed(by: disposeBag)
    
    input.updateItem
      .subscribe(with: self) { owner, row in
        let (indexPath, item) = row
        guard let originalIndex = owner.originalIndex(at: indexPath.row) else { return }
        guard owner.items[originalIndex].name != item.name else { return }
        
        owner.updateItem(at: indexPath, with: item)
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
  
  private func originalIndex(at index: Int) -> Int? {
    let item = itemsRelay.value[index]
    guard let originalIndex = items.firstIndex(of: item) else { return nil }
    return originalIndex
  }
  
  private func addItem(with item: ShopItem) {
    guard items.filter({ $0.name == item.name }).isEmpty else { return }
    items.insert(item, at: 0)
  }
  
  private func updateItem(at indexPath: IndexPath, with item: ShopItem) {
    guard let originalIndex = originalIndex(at: indexPath.row) else { return }
    items[originalIndex] = item
  }
  
  private func deleteItem(at indexPath: IndexPath) {
    guard let originalIndex = originalIndex(at: indexPath.row) else { return }
    items.remove(at: originalIndex)
  }
  
  private func toggleCheckbox(at index: Int) {
    guard let originalIndex = originalIndex(at: index) else { return }
    items[originalIndex].isDone.toggle()
  }
  
  private func toggleBookmark(at index: Int) {
    guard let originalIndex = originalIndex(at: index) else { return }
    items[originalIndex].bookmark.toggle()
  }
}
