import AppKit
import SwiftUI

struct NonWrappingTextEditor: NSViewRepresentable {
    @Binding var text: String
    var onFocusChange: (Bool) -> Void

    private static let limit = CGFloat.greatestFiniteMagnitude
    private static let inset = NSSize(width: 0, height: 6)

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, onFocusChange: onFocusChange)
    }

    func makeNSView(context: Context) -> NSScrollView {
        let scroll = Self.makeScrollView()
        let view = Self.makeTextView(in: scroll, delegate: context.coordinator)

        view.delegate = context.coordinator
        view.minSize = NSSize(width: scroll.contentSize.width, height: scroll.contentSize.height)
        view.string = text

        scroll.documentView = view
        Self.size(view, in: scroll)
        return scroll
    }

    func updateNSView(_ scroll: NSScrollView, context: Context) {
        guard let view = scroll.documentView as? NSTextView else { return }

        if view.string != text {
            view.string = text
        }

        Self.size(view, in: scroll)
    }

    private static func makeScrollView() -> NSScrollView {
        let scroll = NSScrollView()
        scroll.borderType = .noBorder
        scroll.drawsBackground = false
        scroll.hasHorizontalScroller = true
        scroll.hasVerticalScroller = true
        scroll.autohidesScrollers = true
        return scroll
    }

    private static func makeTextView(in scroll: NSScrollView, delegate: NSTextViewDelegate) -> NSTextView {
        let store = NSTextStorage()
        let layout = NSLayoutManager()
        let container = NSTextContainer(
            containerSize: NSSize(width: limit, height: limit)
        )

        // Keep each sentence on one visual line so newlines remain the only item boundary.
        container.lineBreakMode = .byClipping
        container.lineFragmentPadding = 0
        container.widthTracksTextView = false
        container.heightTracksTextView = false

        store.addLayoutManager(layout)
        layout.addTextContainer(container)

        let view = NSTextView(
            frame: NSRect(origin: .zero, size: scroll.contentSize),
            textContainer: container
        )
        view.delegate = delegate
        view.drawsBackground = false
        view.font = .systemFont(ofSize: NSFont.systemFontSize)
        view.isRichText = false
        view.importsGraphics = false
        view.isAutomaticQuoteSubstitutionEnabled = false
        view.isAutomaticDashSubstitutionEnabled = false
        view.isAutomaticTextReplacementEnabled = false
        view.allowsUndo = true
        view.isHorizontallyResizable = true
        view.isVerticallyResizable = true
        view.textContainerInset = inset
        view.maxSize = NSSize(width: limit, height: limit)
        view.autoresizingMask = [.height]
        return view
    }

    private static func size(_ view: NSTextView, in scroll: NSScrollView) {
        guard let container = view.textContainer,
              let layout = view.layoutManager else { return }

        layout.ensureLayout(for: container)

        let used = layout.usedRect(for: container)
        let width = max(
            scroll.contentSize.width,
            ceil(used.width + view.textContainerInset.width * 2)
        )
        let height = max(
            scroll.contentSize.height,
            ceil(used.height + view.textContainerInset.height * 2)
        )

        view.setFrameSize(NSSize(width: width, height: height))
    }
}

extension NonWrappingTextEditor {
    final class Coordinator: NSObject, NSTextViewDelegate {
        @Binding private var text: String
        private let onFocusChange: (Bool) -> Void

        init(text: Binding<String>, onFocusChange: @escaping (Bool) -> Void) {
            _text = text
            self.onFocusChange = onFocusChange
        }

        func textDidBeginEditing(_ notification: Notification) {
            onFocusChange(true)
        }

        func textDidChange(_ notification: Notification) {
            guard let view = notification.object as? NSTextView else { return }
            text = view.string
            if let scroll = view.enclosingScrollView {
                NonWrappingTextEditor.size(view, in: scroll)
            }
        }

        func textDidEndEditing(_ notification: Notification) {
            onFocusChange(false)
        }
    }
}
