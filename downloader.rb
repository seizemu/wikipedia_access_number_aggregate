require "open-uri"
require "date"
require "kconv"
require "yaml"
require "sqlite3"
require "active_record"
require "./my_func"


#設定の読み込み
config = YAML.load_file("config.yml")
READ_DATA_NUMBER = config["wikiperank"]["read_data_number"]
BASE_URL = config["wikiperank"]["base_url"]
NUMBER_OF_RANK_TO_BE_OUTPUT = config["wikiperank"]["number_of_rank_to_be_output"]



#日付を保持するhash生成--------------------------------------------
yesterday_date = DateTime.now - 1
date_hash = {
    'year' => yesterday_date.strftime("%Y"),
    'month' => yesterday_date.strftime("%m"),
    'date' => yesterday_date.strftime("%Y%m%d"),
    'hour' => ""
}
#------------------------------------------------------------------


#データベースの作成と接続------------------------------------------
database_name = ".\/db\/" + "#{date_hash['date']}.db"
db = SQLite3::Database.new(database_name)

#sqlite3でデータベースを作成
db.execute <<-SQL
    create table accesses(
    id integer primary key,
    time text,
    title text,
    count integer,
    created_at,
    updated_at
);
SQL
db.close
#-----------------------------------------------------------------

#activerecordでデータベースに接続
ActiveRecord::Base.establish_connection(
    "adapter" => "sqlite3",
    "database" => "#{database_name}"
)

class Access < ActiveRecord::Base
end
#------------------------------------------------------------------



# 一時的にアクセス数のデータを保持する配列
temp_list = []

# ベースとなるＵＲＬ
base_url = BASE_URL
url = base_url.gsub(/year|month|date/,date_hash)

#ファイル名の問い合わせ
file_name_list = file_upload_confirmation(date_hash, url)


# 各時間ごとの各項目のアクセス数を時間ごとに集計しファイルに出力する
file_name_list.each do |file_name|


    # アクセスデータを一時的に保持するハッシュ
    temp_list = Array.new
    data_pass = String.new

    #ファイル名から時間を抜き出してdate_hash["hour"]に代入
    date_hash["hour"] = hour_select(file_name)
    
    #ファイルのおいてあるURLの文字列を生成
    data_pass = url + file_name
    puts data_pass

    begin

        data = []

        # バイナリモードでファイルを開く
        file = File.open(file_name, "wb")

        # open-uriを使ってurlで指定したファイルを開く
        open(data_pass) do |f|
            data = f.read
        end
        
        file.write(data)

    rescue Exception => e
        puts e
    ensure

        file.close

        # access_analysisメソッドで解析したデータをデータベースに挿入
        temp_list = access_analysis(file_name, READ_DATA_NUMBER)
        puts "data insert start."
        temp_list.each do |hash|
            Access.create(:time => date_hash['hour'], :title => hash[:title], :count => hash[:count])
        end
        puts "data insert finish."
        text_filename = file_name.split(".")[0]
        puts "delete #{text_filename}!"
        `rm ./#{text_filename}`

    end

end

#activerecirdでいるやつをチョイス
puts "一日のデータからランキングを算出しています。"

access_title = []
rank_array = []
#データベースのtitleカラムにあるデータを集計
Access.all.each do |line|
    access_title.push(line[:title])
end

# titleとヒモ付されたcountカラムのデータを配列にtitleごとに挿入
access_title.uniq!.each do |item|
    if item.isutf8
        count_data = ""
        count_data = Access.connection.execute <<-SQL
    select sum(count) from accesses where title = "#{item}";
        SQL
    else
        i += 1
        next
    end
    rank_array.push(["#{item}", count_data.to_s.split("=>")[-1].to_i])
end

temp = rank_array.sort_by do |i|
    i[1]
end

ranking = temp.reverse.first(NUMBER_OF_RANK_TO_BE_OUTPUT)
p ranking

file_output = File.open("output.yml", "w")
file_output.write(ranking.to_yaml)
file_output.close
