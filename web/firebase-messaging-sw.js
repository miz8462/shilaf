// web/firebase-messaging-sw.js

// Firebase v8 互換の書き方（Service Worker用）
importScripts('https://www.gstatic.com/firebasejs/8.10.0/firebase-app.js');
importScripts('https://www.gstatic.com/firebasejs/8.10.0/firebase-messaging.js');

// あなたの Firebase 設定（値は今のままでOK）
firebase.initializeApp({
  apiKey: "AIzaSyDT-FPkpxI-17xwYuZFopyhL2EIB59yZs4",
  authDomain: "shilaf-313d3.firebaseapp.com",
  projectId: "shilaf-313d3",
  storageBucket: "shilaf-313d3.firebasestorage.app",
  messagingSenderId: "364902792906",
  appId: "1:364902792906:web:8e790158a1752db2873e33",
  measurementId: "G-QV7J21C95L"
});

// FCM のインスタンスを取得
const messaging = firebase.messaging();

// （任意）バックグラウンドメッセージ受信時の表示などをここに書ける
// messaging.onBackgroundMessage(function(payload) {
//   console.log('[firebase-messaging-sw.js] Received background message ', payload);
// });