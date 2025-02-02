# やることまとめ

- 名前.comでマイドメインを取得する。
    - 以下ページ参照
    - [マイドメインをお名前ドットコムで取得するときのスクショ](https://www.notion.so/18ab61f4796b8003a299e2518aaaf273?pvs=21)
- terraformディレクトリ構成をより明確化するために細分化
    - 環境のフォルダ内は今networkとmainいう大きな枠組みになってるが
    - 以下のようなフォルダ分けにする
        - my-modules
            - compute
            - network
            - database
            - identity
            - dns -new ホストゾーン登録以外のdnsサーバー用設定が書いてある
            - static_content -new cloudfront,s3あたりの設定が書いてある
            - tls_cert -new acm周りの設定が書いてある
            - tfstate_management
        - environment/{環境名}/
            - general - tfstateの管理用とdnsホストゾーン登録をする。
            - network - vpcとかnatgwとか
            - webapplication -acm,route53,autoscaling,albが対象
            - webhosting -  route53,cloudfront,acm,s3,
            - database - rdsが対象
            - identity - iamが対象
    - 起動順はgeneral→web-hosting→network→ database → webapplication    identity

- webアプリ更改
    - html
        - webアプリ単体で機能検証をするために新たなボタンを設ける
        - 用途は、webアプリ(html,css,javascript)のみで簡潔する動作の確認のため
    - css
        - 特段変更はなし
    - javascript
        - constで適当に定義したパラメータをボタンを押したら表示されるように設定を行う。
    - 余力があればやりたい
        - reactを使ったwebフレームワーク利用によるよりモダンなアプリケーション化
        - フロントエンド部分のテストコード作成
    
- apiアプリ更改
    - 余力があればやりたい
        - 現在すべての要素を取得するクエリを投げてるが、その挙動がテストできるようにテスト用のコードを作成したい。
        - migrateを実施するための機能を搭載していちいちdbにテーブルやデータを登録しに行くのをやめたい。
        - 更新や削除といった機能の実装もできるようにしたい
    

- 静的コンテンツ配信用のamazonS3を作成する。
    - バケット名は任意
    - 前面にcloudfrontを立てるのでそれを見越してリソースを作る
        - もしもs3のみで静的コンテンツ配信をしようとした場合http通信しかできないらしい
        - ブロックパブリックアクセスを無効化し外部アクセスを有効にする
        - そのうえでcloudfrontのみからのアクセスにs3のバケットポリシーを絞り、OACを設定することで、cloudfrontからs3にアクセスし、s3に対しては直接アクセスできないようにする
- amazons3に対して自前のwebサイト情報を放り込む
    - 余力があればやりたい
        - この方法に関しては手動でアップロードする。。。もかんがえたものの
        - せっかくなら、githubにあるソースコードから指定のものをs3にアップロードするまでを自動化する形にしたい
        - よってgithubactionsを使ったワークフローを構築するとする
            - githubactions用に使うためのiamユーザーを作成
            - iamユーザーがs3にファイルアップロードできるようにするためのiamポリシーを定義
            - iamユーザーのsecretキーをgithubのsecretsに登録する
            - s3に対してデプロイをするためのワークフローを作成する(今回トリガーは手動にする)
            - 参考:https://dev.classmethod.jp/articles/deploy-web-site-with-github-actions/
        - 
    - index.htmlを参照先にしておく、その他原資も同様のパスに配置する
- cloudfrontディストリビューションを設定する。
    - オリジンサーバーはs3バケット
    - HTTPS通信を許可するためのOACを設定
    - CloudFrontのURLにアクセスしてもS3のURLにリダイレクトされる 事象が発生する可能性がある
    - https://dev.classmethod.jp/articles/s3-cloudfront-redirect/
    - そのため、origindomainnameにリージョン名を指定して作成することが必要
    - ちなみに24時間以内にアクセスした場合が条件のため、急ぎでないならば気にすることはないかもしれん
    - cloudfrontのセキュリティ対策に関して興味深い記事
    - https://qiita.com/solsol13_dia/items/368584ef8de568f842da
    - 
- ~~s3の~~ cloudfrontのエンドポイントで自前のwebサイト情報が開くことを確認する。
- webalb、webサイト用の起動テンプレートとautoscaling、サブネット、ルートテーブルその他諸々を削除する
    
    ここでもともとnginxとwebサイトをホストしていたので、ここに作成しているやつらは不要になるためである。
    
- api用のec2インスタンスに入る方法がなくなってしまったので
    - acmセッションマネージャーとか用意を考える
        - IAMロールとポリシーを設定する
        - プライベートサブネットのVPCとセキュリティグループは使いまわし
        - ssh のアクセス制限は不要で行ける
        - iamロールをec2の起動テンプレートにつける
        - 以下コマンドでアクセス(NATかVPCEPで外部アクセス必須)
        
        aws ssm start-session --target **i-0938082e320983f13**
        

- route53にお名前.comで取得したドメインをホストゾーンとして登録する
- 作成したドメインをcloudfrontディストリビューションに指定してレコードを作る(エイリアスレコード)
- ACMを使ってTLS証明書を取得する
- cloudfrontに適用してすべての通信をHTTPSに対応させる
    - バージニア北部リージョンなのね。。。
- api向けのドメインはさぶどめいんとしてapi.ドメイン名の形式にしてRoute53とNLBとを関連付けを行う
- api.ドメイン名に対するTLS証明書をALBのターゲットグループで指定するようにする
- http通信ができてたがそれは無効化すること
- webサーバーのjavascript内の向き先はapi.ドメイン名にすること
- セキュリティグループ上80番ポートは許可しているが、443は許可してないので開けておく
- これで接続はできるようになっているはず。接続を試行する。
