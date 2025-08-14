import UIKit
import UserNotifications

class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    var orientationLock: UIInterfaceOrientationMask = .all

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return orientationLock
    }

    // 在应用启动时调用
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // 延迟请求通知权限
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.requestNotificationPermission()
        }
        return true
    }
    
    // 请求通知权限
    // 在 AppDelegate 中
    func requestNotificationPermission() {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                if granted {
                    print("Notification permission granted.")
                } else if let error = error {
                    print("Failed to request notification permission: \(error)")
                }
            }
        }
    // 安排一个短时间触发的测试通知
      private func scheduleTestNotification() {
          let content = UNMutableNotificationContent()
          content.title = "测试通知"
          content.body = "这是一条测试通知，用于检查通知功能是否正常工作。"
          content.sound = .default

          // 设置触发时间为5秒后
          let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
          
          let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
          UNUserNotificationCenter.current().add(request) { error in
              if let error = error {
                  print("Failed to schedule test notification: \(error)")
              }
          }
      }

    // 安排随机阅读提醒
    private func scheduleRandomReadingReminders() {
        let content = UNMutableNotificationContent()
        content.title = "阅读提醒"
        content.body = "拿起手机、你也可以阅读🥳"
        content.sound = .default

        // 生成9:00 AM - 8:00 PM之间的随机时间
        let startHour = 9
        let endHour = 20
        let randomHour = Int.random(in: startHour...endHour)
        let randomMinute = Int.random(in: 0...59)
        var dateComponents = DateComponents()
        dateComponents.hour = randomHour
        dateComponents.minute = randomMinute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule reading reminder: \(error)")
            }
        }
    }

    // 安排周期性总结报告
    private func schedulePeriodicSummaryReport() {
        let content = UNMutableNotificationContent()
        content.title = "阅读总结"
        
        // 假设此处有一个累积阅读时间的计算方法
        let totalDuration = calculateTotalReadingDuration()
        content.body = "你前三天的累积阅读时间是 \(Int(totalDuration / 60)) 分钟，继续加油！"
        content.sound = .default

        // 每隔3天发送通知
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3 * 24 * 60 * 60, repeats: true)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule summary report: \(error)")
            }
        }
    }

    // 假设这是计算累积阅读时间的函数
    private func calculateTotalReadingDuration() -> TimeInterval {
        // 将这里的计算方式调整为从 ContentView 传递过来的实际数据
        // 你可以通过委托或者观察者模式将数据从 ContentView 传递到这里
        // 这里假设为180分钟的总阅读时间
        return 180 * 60
    }
}
