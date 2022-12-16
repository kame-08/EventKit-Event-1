//
//  EventManager.swift
//  EventKit-Event
//
//  Created by Ryo on 2022/12/12.
//

import Foundation
import EventKit

class EventManager: ObservableObject {
    var store = EKEventStore()
    // イベントへの認証ステータスのメッセージ
    @Published var statusMessage = ""
    // 取得されたevents
    @Published var events: [EKEvent]? = nil
    // 起動時の日時
    @Published var day = Date()

    init() {
        Task {
            do {
                // カレンダーへのアクセスを要求する
                try await store.requestAccess(to: .event)
            } catch {
                print(error.localizedDescription)
            }
            // イベントへの認証ステータス
            let status = EKEventStore.authorizationStatus(for: .event)
            
            switch status {
            case .notDetermined:
                statusMessage = "カレンダーへのアクセスする\n権限が選択されていません。"
            case .restricted:
                statusMessage = "カレンダーへのアクセスする\n権限がありません。"
            case .denied:
                statusMessage = "カレンダーへのアクセスが\n明示的に拒否されています。"
            case .authorized:
                statusMessage = "カレンダーへのアクセスが\n許可されています。"
                fetchEvent()
                // カレンダーデータベースの変更を検出したらfetchEvent()を実行する
                NotificationCenter.default.addObserver(self, selector: #selector(fetchEvent), name: .EKEventStoreChanged, object: store)
            @unknown default:
                statusMessage = "@unknown default"
            }
        }
    }

    /// 指定した日付内のイベントを取得
    @objc func fetchEvent() {
        // 適切なカレンダーを取得
        let calendar = Calendar.current
        // 開始日コンポーネントの作成
        let start = calendar.startOfDay(for: day)
        // 終了日コンポーネントの作成
        let end = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: start)
        // イベントストアのインスタンスメソッドから述語を作成
        var predicate: NSPredicate? = nil
        if let end {
            predicate = store.predicateForEvents(withStart: start, end: end, calendars: nil)
        }
        // 述語に一致する全てのイベントを取得
        if let predicate {
            events = store.events(matching: predicate)
        }
    }
    
    /// イベントの追加
    func createEvent(title: String, startDate: Date, endDate: Date){
        let event = EKEvent(eventStore: store)
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        //デフォルトカレンダー
        event.calendar = store.defaultCalendarForNewEvents
        do {
            try store.save(event, span: .thisEvent, commit: true)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    /// イベントの変更
    func createEvent(event: EKEvent,title: String, startDate: Date, endDate: Date){
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        //デフォルトカレンダーに追加
        event.calendar = store.defaultCalendarForNewEvents
        do {
            try store.save(event, span: .thisEvent, commit: true)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    /// イベントの削除
    func deleteEvent(event: EKEvent){
        //do,catchがないとダメな理由
        do {
            try store.remove(event, span: .thisEvent, commit: true)
        } catch {
            print(error.localizedDescription)
        }
    }
}



