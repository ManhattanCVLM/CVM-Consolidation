//
//  AssessmentView.swift
//  CVM Assessment
//
//  Hosts the bundled assessment in a WKWebView and bridges two native
//  capabilities to it:
//
//    • cvmExport  — CSV / JSON exports open the iOS share sheet
//                   (AirDrop, Mail, Save to Files, Copy to Excel…)
//    • cvmHaptic  — a light tap when a maturity score is selected
//    • cvmPdf     — renders the client report to a real PDF and shares it
//
//  Answers are stored by the web layer in localStorage, which WKWebView
//  persists in the app's own container across launches.
//

import SwiftUI
import WebKit
import UIKit

struct AssessmentView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> WebHostController { WebHostController() }
    func updateUIViewController(_ controller: WebHostController, context: Context) {}
}

final class WebHostController: UIViewController, WKScriptMessageHandler, WKNavigationDelegate {

    private var webView: WKWebView!
    private let impact = UIImpactFeedbackGenerator(style: .light)
    private var pendingAlert: String?
    private var pdfBuilder: PDFBuilder?     // held while the report renders

    // MARK: - Lifecycle

    override func loadView() {
        let config = WKWebViewConfiguration()

        // Persist localStorage between launches (the default store already does,
        // but state it explicitly so the intent is obvious).
        config.websiteDataStore = .default()

        let controller = WKUserContentController()
        controller.add(self, name: "cvmExport")
        controller.add(self, name: "cvmHaptic")
        controller.add(self, name: "cvmPdf")
        config.userContentController = controller

        config.allowsInlineMediaPlayback = true
        if #available(iOS 14.0, *) {
            config.defaultWebpagePreferences.allowsContentJavaScript = true
        }

        webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = false
        webView.allowsLinkPreview = false
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.scrollView.bounces = true
        webView.scrollView.keyboardDismissMode = .interactive
        webView.isOpaque = false
        webView.backgroundColor = .systemBackground
        webView.scrollView.backgroundColor = .systemBackground

        // Lets you inspect the running app from Safari on the Mac
        // (Develop ▸ your device ▸ CVM Assessment) while building it.
        if #available(iOS 16.4, *) {
            webView.isInspectable = true
        }

        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        impact.prepare()
        loadAssessment()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let message = pendingAlert {
            pendingAlert = nil
            showFatal(message)
        }
    }

    // Keep the status-bar area legible in both appearances.
    override var preferredStatusBarStyle: UIStatusBarStyle { .default }

    private func loadAssessment() {
        guard let url = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "Web")
                ?? Bundle.main.url(forResource: "index", withExtension: "html") else {
            showFatal("The assessment file could not be found in the app bundle. In Xcode, confirm Web/index.html appears under Build Phases ▸ Copy Bundle Resources.")
            return
        }
        webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
    }

    // MARK: - Bridge

    func userContentController(_ controller: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case "cvmHaptic":
            impact.impactOccurred()
            impact.prepare()

        case "cvmExport":
            guard let payload = message.body as? [String: Any],
                  let name = payload["name"] as? String,
                  let text = payload["text"] as? String else { return }
            share(text: text, filename: name)

        case "cvmPdf":
            guard let payload = message.body as? [String: Any],
                  let name = payload["name"] as? String,
                  let html = payload["html"] as? String else { return }
            buildPDF(html: html, filename: name)

        default:
            break
        }
    }

    private func share(text: String, filename: String) {
        // Write into a per-export subfolder so the share sheet shows the real
        // filename rather than a uniquified temp name.
        let folder = FileManager.default.temporaryDirectory
            .appendingPathComponent("exports", isDirectory: true)
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let fileURL = folder.appendingPathComponent(sanitise(filename))

        do {
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            try text.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            showFatal("The export could not be written: \(error.localizedDescription)")
            return
        }

        let sheet = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)

        // Required on iPad — an activity controller without an anchor crashes.
        if let popover = sheet.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.maxY - 120, width: 1, height: 1)
            popover.permittedArrowDirections = [.down]
        }

        sheet.completionWithItemsHandler = { _, _, _, _ in
            try? FileManager.default.removeItem(at: folder)
        }

        present(sheet, animated: true)
    }

    private func sanitise(_ name: String) -> String {
        let cleaned = name.components(separatedBy: CharacterSet(charactersIn: "/\\:\u{0}")).joined(separator: "-")
        return cleaned.isEmpty ? "cvm-assessment.csv" : cleaned
    }

    // MARK: - Errors

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        showFatal("The assessment could not be loaded: \(error.localizedDescription)")
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        showFatal("The assessment could not be loaded: \(error.localizedDescription)")
    }

    private func showFatal(_ message: String) {
        // An alert cannot be presented before the controller is in a window;
        // hold it until viewDidAppear if we are too early.
        guard view.window != nil else {
            pendingAlert = message
            return
        }
        let alert = UIAlertController(title: "CVM Assessment", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - PDF report

    /// Renders the report HTML in an off-screen web view sized to A4 and hands
    /// the resulting PDF to the share sheet.
    private func buildPDF(html: String, filename: String) {
        let builder = PDFBuilder(host: view)
        pdfBuilder = builder
        builder.render(html: html) { [weak self] result in
            guard let self = self else { return }
            self.pdfBuilder = nil
            switch result {
            case .success(let data):
                self.shareFile(data: data, filename: filename)
            case .failure(let error):
                self.showFatal("The report could not be built: \(error.localizedDescription)")
            }
        }
    }

    private func shareFile(data: Data, filename: String) {
        let folder = FileManager.default.temporaryDirectory
            .appendingPathComponent("exports", isDirectory: true)
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let fileURL = folder.appendingPathComponent(sanitise(filename))
        do {
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            showFatal("The report could not be saved: \(error.localizedDescription)")
            return
        }

        let sheet = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
        if let popover = sheet.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.maxY - 120, width: 1, height: 1)
            popover.permittedArrowDirections = [.down]
        }
        sheet.completionWithItemsHandler = { _, _, _, _ in
            try? FileManager.default.removeItem(at: folder)
        }
        present(sheet, animated: true)
    }
}

/// Loads HTML into an off-screen WKWebView and renders it to PDF data.
/// The web view has to be in the view hierarchy to lay out and paint, so it is
/// added at A4 size behind everything and removed once the PDF is produced.
final class PDFBuilder: NSObject, WKNavigationDelegate {

    /// A4 at 72dpi, the unit WKPDFConfiguration works in.
    private static let a4 = CGSize(width: 595, height: 842)

    private let webView: WKWebView
    private var completion: ((Result<Data, Error>) -> Void)?
    private var finished = false

    init(host: UIView) {
        webView = WKWebView(frame: CGRect(origin: .zero, size: PDFBuilder.a4))
        super.init()
        webView.navigationDelegate = self
        webView.isUserInteractionEnabled = false
        webView.alpha = 0.01
        host.addSubview(webView)
        host.sendSubviewToBack(webView)
    }

    func render(html: String, completion: @escaping (Result<Data, Error>) -> Void) {
        self.completion = completion
        webView.loadHTMLString(html, baseURL: nil)

        // Safety net: never leave the caller waiting forever.
        DispatchQueue.main.asyncAfter(deadline: .now() + 25) { [weak self] in
            self?.fail(NSError(domain: "CVMReport", code: 1,
                               userInfo: [NSLocalizedDescriptionKey: "rendering timed out"]))
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Give layout and the SVG charts a beat to settle before capturing.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
            guard let self = self, !self.finished else { return }
            let config = WKPDFConfiguration()
            webView.createPDF(configuration: config) { result in
                switch result {
                case .success(let data): self.succeed(data)
                case .failure(let error): self.fail(error)
                }
            }
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) { fail(error) }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) { fail(error) }

    private func succeed(_ data: Data) {
        guard !finished else { return }
        finished = true
        cleanUp()
        completion?(.success(data))
        completion = nil
    }

    private func fail(_ error: Error) {
        guard !finished else { return }
        finished = true
        cleanUp()
        completion?(.failure(error))
        completion = nil
    }

    private func cleanUp() {
        webView.navigationDelegate = nil
        webView.removeFromSuperview()
    }
}
