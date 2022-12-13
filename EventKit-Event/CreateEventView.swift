//
//  CreateEventView.swift
//  EventKit-Event
//
//  Created by Ryo on 2022/12/16.
//

import SwiftUI
import EventKit

struct CreateEventView: View {
    @EnvironmentObject var eventManager: EventManager
    // ContentViewのsheetのフラグ
    @Environment(\.dismiss) var dismiss
    // 変更するイベント(nilの場合は新規追加)
    @Binding var event: EKEvent?
    // eventのタイトル
    @State var title = ""
    // eventの開始日時
    @State var start = Date()
    // eventの終了日時
    @State var end = Date()
    
    var body: some View {
        NavigationStack{
            List {
                TextField("タイトル", text: $title)
                DatePicker("開始", selection: $start)
                //in: start...はstartより前が選択できないように
                DatePicker("終了", selection: $end, in: start...)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(event == nil ? "追加" : "変更") {
                        if let event {
                            eventManager.modifyEvent(event: event, title: title, startDate: start, endDate: end)
                        } else{
                            eventManager.createEvent(title: title, startDate: start, endDate: end)
                        }
                        // sheetを閉じる
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル", role: .destructive) {
                        // sheetを閉じる
                        dismiss()
                    }
                    .buttonStyle(.borderless)
                }
            }
        }
        .task {
            if let event {
                // eventが渡されたら値をセットする
                self.title = event.title
                self.start = event.startDate
                self.end = event.endDate
            }
        }
    }
}

struct CreateEventView_Previews: PreviewProvider {
    static var previews: some View {
        CreateEventView(event: .constant(nil))
    }
}
