//
//  Created by Lorenzo Fiamingo on 04/11/20.
//
import SwiftUI

/// A view that asynchronously loads, cache and displays an image.
///
/// This view uses a custom default
/// <doc://com.apple.documentation/documentation/Foundation/URLSession>
/// instance to load an image from the specified URL, and then display it.
/// For example, you can display an icon that's stored on a server:
///
///     CachedAsyncImage(url: URL(string: "https://example.com/icon.png"))
///         .frame(width: 200, height: 200)
///
/// Until the image loads, the view displays a standard placeholder that
/// fills the available space. After the load completes successfully, the view
/// updates to display the image. In the example above, the icon is smaller
/// than the frame, and so appears smaller than the placeholder.
///
/// ![A diagram that shows a grey box on the left, the SwiftUI icon on the
/// right, and an arrow pointing from the first to the second. The icon
/// is about half the size of the grey box.](AsyncImage-1)
///
/// You can specify a custom placeholder using
/// ``init(url:scale:content:placeholder:)``. With this initializer, you can
/// also use the `content` parameter to manipulate the loaded image.
/// For example, you can add a modifier to make the loaded image resizable:
///
///     CachedAsyncImage(url: URL(string: "https://example.com/icon.png")) { image in
///         image.resizable()
///     } placeholder: {
///         ProgressView()
///     }
///     .frame(width: 50, height: 50)
///
/// For this example, SwiftUI shows a ``ProgressView`` first, and then the
/// image scaled to fit in the specified frame:
///
/// ![A diagram that shows a progress view on the left, the SwiftUI icon on the
/// right, and an arrow pointing from the first to the second.](AsyncImage-2)
///
/// > Important: You can't apply image-specific modifiers, like
/// ``Image/resizable(capInsets:resizingMode:)``, directly to an `AsyncImage`.
/// Instead, apply them to the ``Image`` instance that your `content`
/// closure gets when defining the view's appearance.
///
/// To gain more control over the loading process, use the
/// ``init(url:scale:transaction:content:)`` initializer, which takes a
/// `content` closure that receives an ``AsyncImagePhase`` to indicate
/// the state of the loading operation. Return a view that's appropriate
/// for the current phase:
///
///     AsyncImage(url: URL(string: "https://example.com/icon.png")) { phase in
///         if let image = phase.image {
///             image // Displays the loaded image.
///         } else if phase.error != nil {
///             Color.red // Indicates an error.
///         } else {
///             Color.blue // Acts as a placeholder.
///         }
///     }
///
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public struct CachedAsyncImage<Content>: View where Content: View {
    
    @State private var phase: AsyncImagePhase = .empty
    
    private let url: URL?
    
    private let scale: CGFloat
    
    private let urlSession: URLSession
    
    private let content: (AsyncImagePhase) -> Content
    
    public var body: some View {
        content(phase)
            .task(id: url) {
                await load(url: url)
            }
    }
    
    /// Loads and displays an image from the specified URL.
    ///
    /// Until the image loads, SwiftUI displays a default placeholder. When
    /// the load operation completes successfully, SwiftUI updates the
    /// view to show the loaded image. If the operation fails, SwiftUI
    /// continues to display the placeholder. The following example loads
    /// and displays an icon from an example server:
    ///
    ///     CachedAsyncImage(url: URL(string: "https://example.com/icon.png"))
    ///
    /// If you want to customize the placeholder or apply image-specific
    /// modifiers --- like ``Image/resizable(capInsets:resizingMode:)`` ---
    /// to the loaded image, use the ``init(url:scale:content:placeholder:)``
    /// initializer instead.
    ///
    /// - Parameters:
    ///   - url: The URL of the image to display.
    ///   - urlCache: The URL cache for providing cached responses to requests within the session.
    ///   - scale: The scale to use for the image. The default is `1`. Set a
    ///     different value when loading images designed for higher resolution
    ///     displays. For example, set a value of `2` for an image that you
    ///     would name with the `@2x` suffix if stored in a file on disk.
    public init(url: URL?, urlCache: URLCache = .shared,  scale: CGFloat = 1) where Content == Image {
        self.init(url: url, urlCache: urlCache, scale: scale) { phase in
            phase.image ?? Image(uiImage: .init())
        }
    }
    
    /// Loads and displays a modifiable image from the specified URL using
    /// a custom placeholder until the image loads.
    ///
    /// Until the image loads, SwiftUI displays the placeholder view that
    /// you specify. When the load operation completes successfully, SwiftUI
    /// updates the view to show content that you specify, which you
    /// create using the loaded image. For example, you can show a green
    /// placeholder, followed by a tiled version of the loaded image:
    ///
    ///     CachedAsyncImage(url: URL(string: "https://example.com/icon.png")) { image in
    ///         image.resizable(resizingMode: .tile)
    ///     } placeholder: {
    ///         Color.green
    ///     }
    ///
    /// If the load operation fails, SwiftUI continues to display the
    /// placeholder. To be able to display a different view on a load error,
    /// use the ``init(url:scale:transaction:content:)`` initializer instead.
    ///
    /// - Parameters:
    ///   - url: The URL of the image to display.
    ///   - urlCache: The URL cache for providing cached responses to requests within the session.
    ///   - scale: The scale to use for the image. The default is `1`. Set a
    ///     different value when loading images designed for higher resolution
    ///     displays. For example, set a value of `2` for an image that you
    ///     would name with the `@2x` suffix if stored in a file on disk.
    ///   - content: A closure that takes the loaded image as an input, and
    ///     returns the view to show. You can return the image directly, or
    ///     modify it as needed before returning it.
    ///   - placeholder: A closure that returns the view to show until the
    ///     load operation completes successfully.
    public init<I, P>(url: URL?, urlCache: URLCache = .shared,  scale: CGFloat = 1, @ViewBuilder content: @escaping (Image) -> I, @ViewBuilder placeholder: @escaping () -> P) where Content == _ConditionalContent<I, P>, I : View, P : View {
        self.init(url: url, urlCache: urlCache, scale: scale) { phase in
            if let image = phase.image {
                content(image)
            } else {
                placeholder()
            }
        }
    }
    
    /// Loads and displays a modifiable image from the specified URL in phases.
    ///
    /// If you set the asynchronous image's URL to `nil`, or after you set the
    /// URL to a value but before the load operation completes, the phase is
    /// ``AsyncImagePhase/empty``. After the operation completes, the phase
    /// becomes either ``AsyncImagePhase/failure(_:)`` or
    /// ``AsyncImagePhase/success(_:)``. In the first case, the phase's
    /// ``AsyncImagePhase/error`` value indicates the reason for failure.
    /// In the second case, the phase's ``AsyncImagePhase/image`` property
    /// contains the loaded image. Use the phase to drive the output of the
    /// `content` closure, which defines the view's appearance:
    ///
    ///     CachedAsyncImage(url: URL(string: "https://example.com/icon.png")) { phase in
    ///         if let image = phase.image {
    ///             image // Displays the loaded image.
    ///         } else if phase.error != nil {
    ///             Color.red // Indicates an error.
    ///         } else {
    ///             Color.blue // Acts as a placeholder.
    ///         }
    ///     }
    ///
    /// To add transitions when you change the URL, apply an identifier to the
    /// ``CachedAsyncImage``.
    ///
    /// - Parameters:
    ///   - url: The URL of the image to display.
    ///   - urlCache: The URL cache for providing cached responses to requests within the session.
    ///   - scale: The scale to use for the image. The default is `1`. Set a
    ///     different value when loading images designed for higher resolution
    ///     displays. For example, set a value of `2` for an image that you
    ///     would name with the `@2x` suffix if stored in a file on disk.
    ///   - transaction: The transaction to use when the phase changes.
    ///   - content: A closure that takes the load phase as an input, and
    ///     returns the view to display for the specified phase.
    public init(url: URL?, urlCache: URLCache = .shared, scale: CGFloat = 1, transaction: Transaction = Transaction(), @ViewBuilder content: @escaping (AsyncImagePhase) -> Content) {
        self.url = url
        self.scale = scale
        self.content = content
        
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = urlCache
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        self.urlSession =  URLSession(configuration: configuration)
    }
    
    private func load(url: URL?) async {
        do {
            guard let url = url else { return }
            let request = URLRequest(url: url)
            let (data, _) = try await urlSession.data(for: request)
            if let uiImage = UIImage(data: data) {
                let image = Image(uiImage: uiImage)
                phase = .success(image)
            }
        } catch {
            phase = .failure(error)
        }
    }
}
