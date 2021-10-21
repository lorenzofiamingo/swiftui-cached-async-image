# CachedAsyncImage 🗃️

`CachedAsyncImage` is `AsyncImage`, but with cache capabilities. 


## Usage

`CachedAsyncImage` has the exact same API and behavior as `AsyncImage`, so you just have to change this:
```swift
AsyncImage(url: logoURL)
```
to this:
```swift
CachedAsyncImage(url: logoURL)
```

In addition to `AsyncImage` initializers, you have the possibilities to specify the cash you want to use (by default `URLCache.shared` is used):
```swift
CachedAsyncImage(url: logoURL, urlCache: .imageCache)
```

```swift
// URLCache+imageCache.swift

extension URLCache {
    
    static let imageCache = URLCache(memoryCapacity: 512*1000*1000, diskCapacity: 10*1000*1000*1000)
}
```

Remember when setting the cache the response (in this case our image) must be no larger than about 5% of the disk cache (See [this discussion](https://developer.apple.com/documentation/foundation/nsurlsessiondatadelegate/1411612-urlsession#discussion))

## Installation

1. In Xcode, open your project and navigate to **File** → **Swift Packages** → **Add Package Dependency...**
2. Paste the repository URL (`https://github.com/lorenzofiamingo/SwiftUI-CachedAsyncImage`) and click **Next**.
3. Click **Finish**.


## Other projects

[VerticalTabView 🔝](https://github.com/lorenzofiamingo/SwiftUI-VerticalTabView)

[SharedObject 🍱](https://github.com/lorenzofiamingo/SwiftUI-SharedObject)
