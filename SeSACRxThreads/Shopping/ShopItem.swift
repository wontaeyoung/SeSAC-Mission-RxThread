//
//  ShopItem.swift
//  SeSACRxThreads
//
//  Created by 원태영 on 4/2/24.
//

struct ShopItem: Equatable {
  
  var name: String
  var isDone: Bool
  var bookmark: Bool
  
  init(name: String) {
    self.name = name
    self.isDone = false
    self.bookmark = false
  }
}
