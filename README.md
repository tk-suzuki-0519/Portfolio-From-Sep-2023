# :fire:Portfolio-From-Sep-2023:fire:
> [!IMPORTANT]
> **アピールポイント（この文言は、トップページの生成AIで作成した動画アバターのスクリプトとしても使用）**  
> このアプリケーションは、Terraform Cloudで最先端のIaC技術を使用しデザインされています。環境の再現性、迅速な構築、そして一貫性のある変更管理により、ビジネスの変化や要件の変動に柔軟に対応します。
> アプリケーション実行環境としてECS on Fargateを採用し、リソースの伸縮や管理の手間を大幅に削減しつつ、トラフィックの変動に応じて自動的にスケーリングします。
> 最後に、このクラウド基盤は個人開発経験と実務経験をベースに構築されています。私はこの技術力と経験を活かし、ビジネスの成長と変化に柔軟に対応する強固な基盤を構築することができます。
  
> [!NOTE]
> **想定閲覧者**  
> このREADME.mdに記載されている基本設計書は、顧客ではなく技術者を想定閲覧者として作成されています。  
> したがって、例えば基本設計書内の「セキュリティ設計」の部分にIAMの具体的なセキュリティ機能の説明は冗長的になるため省き、技術選定欄にサービス名としてIAMと記載するに留めることで想定閲覧者の文章を読む負担を軽減するように設計されています。
  
# 目次
1. [:fire:はじめに](#はじめに)
1. [:fire:技術選定](#技術選定)
    1. クラウドインフラ
        1. [クラウド基盤共通](#技術選定クラウドインフラクラウド基盤共通)
        1. [サーバレス環境](#技術選定クラウドインフラサーバレス環境)
        1. [データ分析基盤](#技術選定クラウドインフラデータ分析基盤)
    1. [開発ツール](#技術選定開発ツール)
    1. [バックエンド](#技術選定バックエンド)
    1. [フロントエンド](#技術選定フロントエンド)
    1. [生成AI（動画・静止画・コード生成）](#技術選定生成ai動画静止画コード生成)
1. [:fire:基本設計](#基本設計)
    1. [クラウドインフラ](#基本設計クラウドインフラ)
    1. [コンテナ（簡易版）](#基本設計コンテナ簡易版)
    1. アプリケーション（簡易版）
        1. [実装機能（バックエンド）](#基本設計アプリケーション実装機能バックエンド)
    1. [データベース](#基本設計データベース)
1. [:fire:その他](#その他)
  
---------------------------------------
# :fire:はじめに
はじめに  
  
---------------------------------------
# :fire:技術選定
## 技術選定／クラウドインフラ
### 技術選定／クラウドインフラ／クラウド基盤共通
+ IaC）  Terraform Cloud
  
+ 管理コンソールから作成・有効化したサービス・機能）  IAM(管理ユーザ作成), 
  
+ IaCで作成したサービス・機能）  VPC(IPv4), 
  
+ 初期設定で有効化されているサービス・機能）  
  


<!-- 
+ 管理コンソールから作成・有効化したサービス・機能）  IAM, AWS billing Alarms, AWS Budget, AWS Cost Explorer, 
+ IaCで作成したサービス・機能）  ECS on Fargate, RDS, ECR, ACM, ALB, S3, CloudFront, WAF, CloudWatch log, Route53, VPC Flow Logs, AWS Config, KMS, Athena, Amazon Inspector, Guard Duty, 
+ 初期設定で有効化されているサービス・機能）  CloudTrail, AWS Shield Standard, AWS Health Dashboard, (コスト系も入れる), 
-->
  
### 技術選定／クラウドインフラ／サーバレス環境
+ Python 3.11.5 (サーバレス環境およびデータ分析基盤の構築用)
  
### 技術選定／クラウドインフラ／データ分析基盤
  
  
## 技術選定／開発ツール
+ Docker Desktop 4.24.2
+ aws-cli 2.13.27(オートコンプリート)
+ Terraform v1.6.2(CLI環境)
+ pyenv 2.3.27
  
## 技術選定／バックエンド
+ PHP 8.2.10  
+ Laravel 10.22.0  
  
## 技術選定／フロントエンド
+ Bootstrap（下記生成AIにより、95%以上を自動生成）
+ HTML/CSS（下記生成AIにより、95%以上を自動生成）
  
## 技術選定／生成AI（動画・静止画・コード生成）
+ Creative Reality Studio（写真とテキストを入力し、しゃべるアバター動画を出力するAI。トップページの動画を生成）
+ DiffusionBee（テキストを入力し、画像を出力するAI。favicon.icoを生成）
+ ChatGPT（version4）　HTML/CSS/Bootstrapを生成
  
  
---------------------------------------
# :fire:基本設計
## 基本設計／クラウドインフラ
  
  
## 基本設計／コンテナ（簡易版）
+ nginx 1.25.3
+ mysql 8.1.0
+ php 8.2.10-fpm
  
## 基本設計／アプリケーション（簡易版）
### 基本設計／アプリケーション／実装機能（バックエンド）
+ CRUD機能
+ 検索機能
+ ページネーション機能
+ バリデーション
+ ユーザー登録、ログイン
  
## 基本設計／データベース
+ テーブル設計（簡易版）  
ER図  
  
---------------------------------------
# :fire:その他
  
  