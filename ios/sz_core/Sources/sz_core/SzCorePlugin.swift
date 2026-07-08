import Flutter
import UIKit

public class SzCorePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "sz_core", binaryMessenger: registrar.messenger())
    let instance = SzCorePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
        case "showToast":
          guard
          let args = call.arguments as? [String: Any],
          let message = args["message"] as? String
          else {
            result(nil)
            return
          }

          let bgColor = (args["backgroundColor"] as? NSNumber)?.int64Value ?? 0xFF000000
          let textColor = (args["textColor"] as? NSNumber)?.int64Value ?? 0xFFFFFFFF
          let fontSize = (args["fontSize"] as? NSNumber)?.doubleValue ?? 12.0
          let duration = (args["duration"] as? NSNumber)?.doubleValue ?? 2.0

          showToast(
            message,
            backgroundColor: UIColor(argb: bgColor),
            textColor: UIColor(argb: textColor),
            fontSize: fontSize,
            duration: duration
          )

          result(nil)
        case "getScreenSize":
          guard let window = UIApplication.shared.connectedScenes
          .compactMap({ $0 as? UIWindowScene })
          .first?
          .windows
          .first(where: { $0.isKeyWindow }) else {

            result(nil)
            return
          }

          result([
            "width": window.bounds.width,
            "height": window.bounds.height
          ])
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func showToast(
  _ message: String,
  backgroundColor: UIColor,
  textColor: UIColor,
  fontSize: CGFloat,
  duration: Double
  ) {

    guard let window = UIApplication.shared.connectedScenes
    .compactMap({ $0 as? UIWindowScene })
    .first?
    .windows
    .first(where: { $0.isKeyWindow })
    else {
      return
    }

    let label = UILabel()
    label.text = message
    label.textAlignment = .center
    label.textColor = textColor
    label.backgroundColor = backgroundColor
    label.font = UIFont.systemFont(ofSize: fontSize)
    label.numberOfLines = 0
    label.layer.cornerRadius = 8
    label.clipsToBounds = true

    let maxWidth = window.frame.width - 40

    let size = label.sizeThatFits(
      CGSize(width: maxWidth - 32, height: .greatestFiniteMagnitude)
    )

    label.frame = CGRect(
      x: 20,
      y: window.frame.height - 120,
      width: maxWidth,
      height: max(size.height + 24, 45)
    )

    label.alpha = 0

    window.addSubview(label)

    UIView.animate(withDuration: 0.25) {
      label.alpha = 1
    }

    UIView.animate(
      withDuration: 0.25,
      delay: duration,
      options: [],
      animations: {
        label.alpha = 0
      },
      completion: { _ in
        label.removeFromSuperview()
      }
    )
  }
}


extension UIColor {

  convenience init(argb: Int64) {

    let a = CGFloat((argb >> 24) & 0xFF) / 255.0
    let r = CGFloat((argb >> 16) & 0xFF) / 255.0
    let g = CGFloat((argb >> 8) & 0xFF) / 255.0
    let b = CGFloat(argb & 0xFF) / 255.0

    self.init(
      red: r,
      green: g,
      blue: b,
      alpha: a
    )
  }
}