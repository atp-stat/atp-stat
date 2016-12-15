# README

# ■タスク
## Get player ranking and import them to db
```rake atp_stat:ranking:get[range]```   
最新のランキングから、指定したrangeの選手名の一覧を取得  
(ex. ランキング1-20位の選手をDB(players)に格納 => ```rake atp_stat:ranking:get[1-20]```)
## Get player activity and import them to db
```rake atp_stat:activity:get[player_id,year]```   
指定したplayer_idの、指定したyearの全ての戦績&ランキングを取得   
(ex. 2016年のフェデラーの戦績をDB(activities)に格納=> ```rake atp_stat:activity:get[f324,2016]```)   
## Get ATP ranking and import them to db
```rake atp_stat:ranking:update```   
現在のATPランキングを取得   
(ex. 現在のATPランキングをDB(rankings)に格納=> ```rake atp_stat:ranking:update```)   
