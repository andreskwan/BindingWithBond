/*
* Copyright (c) 2015 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import Foundation
import Bond

class PhotoSearchViewModel {
  
  private let searchService: PhotoSearch = {
    let apiKey = NSBundle.mainBundle().objectForInfoDictionaryKey("apiKey") as! String
    return PhotoSearch(key: apiKey)
  }()
  
  let searchString = Observable<String?>("")
  let validSearchText = Observable<Bool>(false)
  
  
  init() {
    searchString.value = "Bond"
    
    searchString.map { $0!.characters.count > 3 }
      .bindTo(validSearchText)
    
    searchString
      .filter { $0!.characters.count > 3 }
      .throttle(0.5, queue: Queue.Main)
      .observe {
        [unowned self] text in
        self.executeSearch(text!)
    }
  }
  
  func executeSearch(text: String) {
    var query = PhotoQuery()
    query.text = searchString.value ?? ""
    
    searchService.findPhotos(query) {
      result in
      switch result {
      case .Success(let photos):
        print("500px API returned \(photos.count) photos")
      case .Error:
        print("Sad face :-(")
      }
    }
  }
}
