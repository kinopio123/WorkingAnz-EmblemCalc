require 'discordrb'
require 'date'
require 'nokogiri'
require 'open-uri'

token = 'BotToken'
client_id ='ClientId'
bot = Discordrb::Commands::CommandBot.new token: token,client_id: client_id,prefix: "/"

i = 1
output = ""
x = 0
hash = {}
kakopts = 0
sabunpts = 0
outpts= 0
y = 0
errer = false

#以下変数はエンブレム計算用
amari = 0
ecount = 0
gcount = 0
ekeisan = 0
esabun = 0
para = 1
anz = 0
eigyo = 0
emblem = 0
kemblem = 1000000
syokai = 1
z = 0
help = ">>> 陰湿監視bot E0.3 作:きのぴお\n
 概要\n
  15分ごとにaidoru.infoのランキングから\n
  特定のユーザーのpt変動、エンブレム数をお知らせするbot\n
 使い方\n
  /starte [監視対象] [エンブレム数] [前半戦:0/後半戦:1]\n
   監視開始\n
  /ende
   監視終了\n
    監視対象は大文字小文字などに注意してください\n
    間違っていると動きません"
bot.command :helpanze do |ev|
  ev.send_message help
end
bot.command :starte do |event,inname,emblem,zenkouhan|
  if inname != nil && emblem != nil && zenkouhan != nil
    if i == 1
      i = 0
      emblem = emblem.to_i
output = ("#{inname}" + " さんの現在のpt:" + "#{outpts}" + "(" + "#{sabunpts}" + ")") #出力、送信
          event.send_message output
          emblem = emblem + 1
          emblem = emblem - 1
          event.send_message(emblem)
      while i == 0
        now = DateTime.now
        nowmin = "#{now.minute}"
        if nowmin == "4" or nowmin == "19" or nowmin == "34" or nowmin == "49" then
          #更新時間に計算
          url = 'https://aidoru.info/event/viewrank'
          html = open(url).read
          begin
            doc = Nokogiri::HTML.parse(html)
          rescue
            puts "取得エラー"
            errer = true
            sleep 10
            retry
          end
          doc.xpath("/html/body/div/div[2]/div/table/tbody").each do |node|
            node.xpath("/html/body/div/div[2]/div/table/tbody/tr/td[3]").each do |bname| #名前取得
              bpts = node.xpath("/html/body/div/div[2]/div/table/tbody/tr/td[2]")[x].inner_html.to_s.strip #pt取得
              apts = bpts.gsub(/\(.*/m, "").gsub!(/\,+/, "").to_i #差分削除
              x += 1
              aname = bname.inner_html.to_s.strip #整形
              hash[aname] = apts #名前とptを紐付け
              outpts = hash[inname]
            end
          end
          sabunpts = outpts - kakopts

          #ここからエンブレム計算処理
          if syokai == 0
          if zenkouhan == 1
            para = 4 #後半は計算で1280を使う
          end
          amari = sabunpts % 320
          if sabunpts != 0 || amari != 0 #+0、320で割り切れなければ内訳のために計算
            ekeisan = 0
            eigyo = 1
            while ekeisan < 9 #8回計算してきれいにならなかったら営業かボケ
              anz = sabunpts - (320*para) * ekeisan
              if 0 == anz % 84 #割り切れれば計算おｋ！
                ecount = ekeisan
                gcount = anz / 84 #この2行でイベント、グランド回数が出る
                ekeisan = 10
                eigyo = 0
              end
              ekeisan += 1
            end
          elsif amari == 0
            ecount = sabunpts / 320 * para
          end
          if eigyo == 0
          emblem = emblem - ecount * (150*para) #エンブレム個数計算
          emblem = emblem + gcount * 168
          if emblem < 0
            z = 1
          end
          if emblem > kemblem && z == 1
            emblem = gcount * 168
            z = 0
          end
          kemblem = emblem
          end
            else
              syokai = 0
            end
          output = ("#{inname}" + " さんの現在のpt:" + "#{outpts}" + "(" + "#{sabunpts}" + ")") #出力、送信
          event.send_message output
          if sabunpts == 0
            event.send_message("エンブレムの変動はありません")
          elsif eigyo == 1
            event.send_message("営業等の理由で計算できませんでした 変動はなしとして処理されます。")
          else
            event.send_message("emblem:" + "#{emblem}" + " " + "grand:" + "#{gcount}" + " " + "event:" + "#{ecount}")
          end
          kakopts = outpts
          x = 0
        else
          #何もしない
        end
        if errer == true
          errer = false
          sleep 50
        else
          sleep 60
        end
      end
    else
      event.send_message("既に監視しています")
    end
  else
    event.send_message("引数が不足しています 詳しくは/helpanze")
  end
end

bot.command :ende do |a|
  if i == 0 then
    i = 1
    a.send_message("監視を終了しました")
  else a.send_message("監視していません")
  end
end
bot.run