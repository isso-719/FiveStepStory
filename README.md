
このリポジトリはLife is Tech Mentorsのアドカレ6日目のネタです。

## アイディア
- 対戦型のオセロを作ろう！

## 利用技術
- sinatra
- web socket

### web socketとは
HTML5から利用が可能で、他のクライアントと簡単に相互通信ができる規格。
[WebSocketについて調べてみた。](https://qiita.com/south37/items/6f92d4268fe676347160)
[SinatraでWebsocket通信](https://qiita.com/sasurai_usagi3/items/ab32fe1feb3f275e039e)
## はじめに参加しているユーザーをカウントしてみよう！

[テンプレート](https://github.com/4geru/simple-websocket-count/tree/b137f1b54df423356d7372986f37d66a5454e22e)

```
 $ git clone https://github.com/4geru/simple-websocket-count.git
 $ bundle # パッケージのインストール
 $ bundle exec rake db:migrate # データベースの構成
 $ bundle exec ruby app.rb # サーバーの起動
```

### オセロ盤を作る
複数のブラウザページを開いて数が増えたり減ったりするのを確認できたらOK!
次に、オセロの板を作ってみよう！for文を使うことでtableを簡単に作ることができます！

```erb:html
<table>
  <% for i in 0..7 %>
  <tr>
    <% for j in 0..7%>
      <td onclick="s('<%= i %><%= j %>')"  id='<%= i %><%= j %>'>
        <% # 真ん中のおけないところ %>
        <% if (i == 4 and j == 4) or (i == 3 and j == 3)%>
          <div class='black'></div>
        <% end %>
        <% if (i == 3 and j == 4) or (i == 4 and j == 3)%>
          <div class='white'></div>
        <% end %>
      </td>
    <% end %>
  </tr>
  <% end %>
</table>
```

```css:css
td{
  background: green;
  width: 100px; height: 100px;
}
table{
  background: black;
}
.black{
  background: black;
  margin: auto;
  width: 80px; height: 80px;
  border-radius: 50%;
}
.white{
  background: white;
  margin: auto;
  width: 80px; height: 80px;
  border-radius: 50%;
}
```

### WebSocketを実装しよう
実際に、WebSocketを使って行きます！
WebSocketは常にサーバーとブラウザが接続されているイメージ！
app.rbの中のsettings.socketsで、接続しているブラウザを全て管理しています。
リクエストを送って来たsocketをwsとして、app.rbの中で使っています。

ws.send("send")で、元のsocketに対して "send" というメッセージを送ることができます！
データは、JavaScriptでは、JSON。RubyではHashで扱いたいけど、sendでは、文字しか送れないので、JavaScirpt・Rubyでそれぞれ変換する必要がります。
複数のデータを送りたい場合は、送る時に、typeを書くと管理しやすいです。

```ruby:app.rb
get '/websocket/count' do
  if request.websocket? then
    request.websocket do |ws|
      ws.onopen do # 接続を開始した時
        settings.sockets << ws # socketsリストに追加
        c = Count.first # count の数を増やす
        c.count += 1
        c.save
        settings.sockets.each do |s| # 全体へメッセージを転送
          c = Count.first
          s.send({type: 'count', count: c.count}.to_json.to_s)
        end
      end
      ws.onmessage do |msg| # メッセージを受け取った時
        puts 'メッセージを受け取ったよ！'
        data = JSON.parse(msg)
        case data['type']
        when 'open', 'close' # 送られたデータが open or close データだったら
          settings.sockets.each do |s| # 全体へメッセージを転送
            c = Count.first
            s.send({type: 'count', count: c.count}.to_json.to_s)
          end
        when 'board' # 送られたデータが board データだったら
          turn  = data['turn'] == 'black' ? 'white' : 'black'
          puts data
          settings.sockets.each do |s| # メッセージを転送
            s.send({type: 'board', turn: turn, pos: data['pos']}.to_json.to_s)
          end
        end
      end
      ws.onclose do # メッセージを終了する時
        c = Count.first # count の数を減らす
        c.count -= - 1
        c.save
        settings.sockets.each do |s| # 全体へメッセージを転送
          c = Count.first
          s.send({type: 'count', count: c.count}.to_json.to_s)
        end
        settings.sockets.delete(ws) # socketsリストから削除
      end
    end
  end
end
```

```javascript:javascript
var countBox = document.getElementById("count");
var turnBox = document.getElementById("turn");

window.onload = function(){
  var count = new WebSocket('ws://' + window.location.host + "/websocket/count");

  // 接続が始まった時
  count.onopen = function() { count.send('{"type":"open"}'); };
  // 接続が終わった時
  count.onclose = function() { count.send('{"type":"close"}'); };
  // メッセージを受け取った時
  count.onmessage = function(m) {
    data = JSON.parse(m.data)
    if(data.type == 'count'){ // サーバーからカウントを変更する命令が来た時
      countBox.innerHTML = data.count         
    } else if(data.type == 'board'){ // サーバーから石を置く命令が来た時
      turn = data.turn == 'black' ? 'white' : 'black'
      turnBox.innerHTML = data.turn
      document.getElementById(data.pos).innerHTML = '<div class=' + turn + '></div>'
      console.log('get board')
    }
  }

  s = function(msg){
    // すでに石が置かれていたら置かない
    if(!document.getElementById(msg).innerHTML.match('div'))
      count.send(JSON.stringify({type:'board', pos: msg, turn: turnBox.innerHTML}));
  }
};
```

なんとか形になるものにはできた。
WebSocketを使ってみたなので、実際のゲームになるまではもう少し先のお話。
[完成盤](https://github.com/4geru/simple-websocket-count/tree/final)
