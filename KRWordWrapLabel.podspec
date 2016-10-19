Pod::Spec.new do |s|
  s.name             = "KRWordWrapLabel"
  s.version          = "2.0.0"
  s.summary          = "UILabel subclass which provides **Word Wrap** based on white spaces not depending on languages"
  s.description      = <<-DESC
# KRWordWrapLabel

``UILabel`` subclass which provides **Word Wrap** based on white spaces not depending on languages

Although UILabel supports *Word Wrap* for the line breaking mode, it doesn't work on Korean letters. It works just like *Charactor Wrap*. This KRWordWrapLabel provides **Word Wrap** based on white spaces not depending on languages. Almost all the requirements for this library is from Korean, so I'll describe the details in Korean also.

UILabel은 Word Wrap 모드를 지원하지만 한글의 경우 글자 단위로 줄바꿈이 됩니다. 이 KRWordWrapLabel은 UILabel의 Subclass로서 한글의 단어 단위의 줄바꿈이 가능합니다.

### Usages
* Use same as ``UILabel``. Can be previewd in Interface builder by ``IBDesignable``
* Works only on ``Word Wrap`` option of ``Line Break Mode``. Otherwise, works same as UILabel 
* ``IBInspectable`` properties: ``ellipsis`` string and ``lineSpace``
* If a view's width is narrower than the widest width of word in the text, works same as UILabel

* 기존의 ``UILabel``과 같이 사용가능합니다. ``IBDesignable``을 적용하여 Interface Builder에서도 preview가 가능합니다.
* ``Line Break Mode``가 ``Word Wrap``일때만 동작하며 다른 모드에선 ``UILabel``의 기본 동작으로 보여집니다.
* numberOfLines에 의해 마지막 행이 잘릴 때의 표시 문자열인 ``ellipsis``와 줄 간격인 ``lineSpace``를 ``IBInspectable``로 추가하였습니다.
* 뷰의 폭이 공백없는 제일 긴 문자열의 폭보다 짧은 경우 전체가 ``UILabel``의 기본 동작으로 문자 단위로 줄바꿈됩니다.

### ScreenShot
![sreenshot](https://github.com/inkyfox/KRWordWrapLabel/blob/master/screenshot/KRWordWrapLabel.gif)

## Installation

### CocoaPods

#### Swift 3
```Ruby
pod 'KRWordWrapLabel'
```

#### Swift 2.3
```Ruby
pod 'KRWordWrapLabel' => '~>1'
```

## Author

Yongha Yoo, http://inkyfox.oo-v.com

## License

MIT
                        DESC
  s.homepage         = "https://github.com/inkyfox/KRWordWrapLabel"
  s.license          = 'MIT'
  s.author           = { "Yongha Yoo" => "inkyfox@oo-v.com" }
  s.source           = { :git => "https://github.com/inkyfox/KRWordWrapLabel.git", :tag => s.version.to_s }

  s.requires_arc          = true

  s.ios.deployment_target = '8.0'

  s.source_files          = 'Sources/KRWordWrapLabel.swift'

  s.pod_target_xcconfig = {
    'SWIFT_VERSION' => '3.0'
  }

end
