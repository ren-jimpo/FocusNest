
用件定義書（テキスト版）

アプリ名（仮）：FocusNest

【目的】
スマホ（iOS）とデスクトップ（macOS）で使用可能なタスク管理・学習管理アプリをFlutterで開発する。特にAI領域などの学習テーマを保存・記録・整理できる機能を統合し、日々の学習効率向上を支援する。

【対応プラットフォーム】

iOS
macOS
【使用技術】

Flutter（UI / アプリ本体）
Supabase（PostgreSQLベースのバックエンド：認証 / データベース / リアルタイム同期）
Riverpod or Provider（状態管理）
【機能一覧】

■ 1. タスク管理機能

タスクの追加 / 編集 / 削除
入力項目：
タイトル
説明
締切日時（DateTime）
優先度（高 / 中 / 低）
ステータス（未着手 / 進行中 / 完了）
タグ（複数）
関連学習テーマID（任意）
繰り返し設定（なし / 毎日 / 毎週 / 毎月）
通知機能（端末リマインダー連携：任意）
■ 2. タスクの検索・フィルタ機能

タグでの絞り込み
ステータス別フィルタ
締切日によるフィルタ（今日 / 今週 / 月内など）
フリーワード検索（タイトル / 説明）
■ 3. 学習テーマ管理機能

学習テーマの追加 / 編集 / 削除
入力項目：
タイトル
概要 / 説明文
ステータス（未着手 / 学習中 / 完了）
ノート記録欄（Markdown記法対応予定）
作成日 / 更新日（自動記録）
関連するタスクの一覧表示
■ 4. データ同期・ユーザー管理

Supabase Authによるユーザー登録 / ログイン（GoogleなどのOAuth予定）
ユーザーごとにタスク・学習テーマ・タグを管理
Supabase Realtimeによるデータの即時反映（マルチデバイス同期）
【データモデル設計（Supabase）】

■ tasks テーブル

id: UUID（主キー）
user_id: UUID（外部キー：users）
title: Text
description: Text
due_date: Timestamp
priority: Text（high / medium / low）
status: Text（not_started / in_progress / done）
tags: Text[]（PostgreSQL配列型）
repeat: Text（none / daily / weekly / monthly）
related_theme_id: UUID（外部キー：study_themes）
created_at / updated_at: Timestamp
■ study_themes テーブル

id: UUID（主キー）
user_id: UUID（外部キー）
title: Text
description: Text
status: Text（not_started / studying / done）
notes: Text（Markdown形式）
created_at / updated_at: Timestamp
■ users テーブル（Supabase Authで自動管理）

【UI設計（概要）】

メイン画面：タスク一覧（フィルタ・検索バー付き）
学習テーマ画面：テーマごとのノート＋関連タスク
タスク作成画面：繰り返し設定・タグ選択など入力可能
タブ or ドロワーによる画面切替（タスク / 学習テーマ / 設定）
【将来的な拡張候補】

ポモドーロタイマー（学習集中支援）
学習時間 / タスク達成率の可視化グラフ
ChatGPT連携による学習ノートの要約生成
他ユーザーとテーマ共有（チーム学習支援）# FocusNest
>>>>>>> 6e6f34e7d1abe3a64a5f7296d43036bd98723aed
