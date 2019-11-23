import 'dart:convert';
import 'dart:io';

import 'package:chat_demo/Model/SendMsgTemplate.dart';
import 'package:chat_demo/Model/chatRecordModel.dart';
import 'package:chat_demo/Pages/chatDetail.dart';
import 'package:flutter/material.dart';
import 'package:signalr_client/hub_connection.dart';
import 'package:signalr_client/signalr_client.dart';

class SignalRProvider with ChangeNotifier {
  HubConnection conn;
  String tempVoicePath;
  String connId;
  String ava1 =
      'https://pic2.zhimg.com/v2-d2f3715564b0b40a8dafbfdec3803f97_is.jpg';
  String ava2 =
      'https://pic4.zhimg.com/v2-0edac6fcc7bf69f6da105fe63268b84c_is.jpg';

  List<ChatRecord> records;

  updateVoicePath(filePath){
    tempVoicePath=filePath;
    notifyListeners();
  }

  addVoiceChatRecord(time,sender){
    records.add(ChatRecord(chatType: 1,content: tempVoicePath,voiceDuration: time,sender: sender,avatarUrl: ava1));
    notifyListeners();
  }

  SignalRProvider() {
    records = List<ChatRecord>();

    //chatRecord type 0 text 1 voice 2 image 3 video
    records.add(ChatRecord(avatarUrl: ava1, sender: 0, content: "你吃了么？",chatType: 0));
    records.add(ChatRecord(avatarUrl: ava2, sender: 1, content: "没吃呢",chatType: 0));
    records.add(ChatRecord(avatarUrl: ava1, sender: 0, content: "那快去吃饭吧！",chatType: 0));
    records.add(ChatRecord(
        avatarUrl: ava2,
        sender: 1,chatType: 0,
        content: "原来你不请我吃饭啊 \n 我还在这等你呢 \n 1231231231"));
        String url='';
        if(Platform.isIOS){
          url='http://192.168.0.6:5000/chatHub';
        }
        else{
          url='http://192.168.0.6:5000/chatHub';
        }
    conn =
        HubConnectionBuilder().withUrl(url).build();
    conn.start();

    conn.on('receiveConnId', (message) {
      connId = message.first.toString();
      notifyListeners();
    });

    conn.on('receiveMsg', (message) {
      records
          .add(ChatRecord(content: message.first, avatarUrl: ava2, sender: 0));
      notifyListeners();
    });
  }

  sendMessage(msg) {
    records.add(ChatRecord(content: msg, avatarUrl: ava1, sender: 1,chatType: 0));
    conn.invoke('receiveMsgAsync', args: [
      jsonEncode(
          SendMsgTemplate(fromWho: connId, toWho: '', message: msg).toJson())
    ]);
    
    notifyListeners();
  }
}