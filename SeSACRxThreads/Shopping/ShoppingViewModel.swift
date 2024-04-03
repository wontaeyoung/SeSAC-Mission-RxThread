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
    let query: PublishRelay<String>
    let addItem: PublishRelay<ShopItem>
    let updateItem: PublishRelay<ShopItem>
    let deleteItem: PublishRelay<UUID>
    let checkboxTapEvent: PublishRelay<UUID>
    let bookmarkTapEvent: PublishRelay<UUID>
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
    
    let output = Observable.combineLatest(
      input.query,
      itemsRelay
    )
      .map { (query: $0.0, items: $0.1) }
      .map { value in
        return value.query.isEmpty
        ? value.items
        : value.items.filter { $0.name.contains(value.query) }
      }
      .asDriver(onErrorJustReturn: [])
    
    input.addItem
      .subscribe(with: self) { owner, item in
        owner.addItem(with: item)
      }
      .disposed(by: disposeBag)
    
    input.updateItem
      .subscribe(with: self) { owner, updatedItem in
        owner.updateItem(with: updatedItem)
      }
      .disposed(by: disposeBag)
    
    input.deleteItem
      .subscribe(with: self) { owner, id in
        owner.deleteItem(id: id)
      }
      .disposed(by: disposeBag)
    
    input.checkboxTapEvent
      .subscribe(with: self) { owner, id in
        owner.toggleCheckbox(id: id)
      }
      .disposed(by: disposeBag)
    
    input.bookmarkTapEvent
      .subscribe(with: self) { owner, id in
        owner.toggleBookmark(id: id)
      }
      .disposed(by: disposeBag)
    
    return Output(items: output)
  }
  
  private func originalIndex(id: UUID) -> Int? {
    return items.firstIndex { $0.id == id }
  }
  
  private func addItem(with item: ShopItem) {
    items.insert(item, at: 0)
  }
  
  private func updateItem(with item: ShopItem) {
    guard let index = originalIndex(id: item.id) else { return }
    items[index] = item
  }
  
  private func deleteItem(id: UUID) {
    guard let index = originalIndex(id: id) else { return }
    items.remove(at: index)
  }
  
  private func toggleCheckbox(id: UUID) {
    guard let index = originalIndex(id: id) else { return }
    items[index].isDone.toggle()
  }
  
  private func toggleBookmark(id: UUID) {
    guard let index = originalIndex(id: id) else { return }
    items[index].bookmark.toggle()
  }
}
