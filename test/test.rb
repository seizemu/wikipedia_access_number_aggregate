
# str = "pagecounts-20140403-120000.gz"
#データベースからデータを抜き出して必要なデータだけを配列に代入するテスト

require "sqlite3"
require "active_record"
require "kconv"

access_list = []
rank_array = Array.new
i = 0

ActiveRecord::Base.establish_connection(
    "adapter" => "sqlite3",
    "database" => '/home/daiki/wikiperank/db/20140416.db'
)

class Access < ActiveRecord::Base
end


# puts results.to_s.split("=>")[-1].to_i

Access.all.each do |line|
    access_list.push(line[:title])
end

puts access_list.size
puts access_list.uniq!.size

# begin
access_list.each do |item|
    begin
    if item.isutf8
        count_data = ""
        count_data = Access.connection.execute(<<-"SQL")
    select sum(count) from accesses where title = "#{item}";
        SQL
    else
        # i += 1
        next
    end
    rank_array.push(["#{item}", count_data.to_s.split("=>")[-1].to_i])
    # puts i
    i += 1
    puts i

    rescue Exception => e_access_list
        p e_access_list
    end

end

puts rank_array.first(10)

temp = rank_array.sort_by do |i|
    i[1]
end

ranking = temp.reverse.first(10)

puts ranking


# rescue Exception => e
#     puts e
# end
#p rank_array


=begin
require "./my_func"
require "date"
require "open-uri"

#file_upload_confirmationメソッドのテスト
yesterday_date= DateTime.now - 1
date_hash = {
    'year' => yesterday_date.strftime("%Y"),
    'month' => yesterday_date.strftime("%m"),
    'date' => yesterday_date.strftime("%Y%m%d"),
    'hour' => ""
}

list = Array.new

url = 'http://dumps.wikimedia.org/other/pagecounts-raw/2014/2014-04/'
list = file_upload_confirmation(date_hash, url)
puts list
=end


=begin
require "./access_analysis"

list = [{item: "寿司", count: "100"},{item: "kame", count: "200"},{item: "kinoko", count: "300"}]
# list2 = [{item: "寿司", count: "100"},{item: "kame", count: "200"},{item: "kinoko", count: "300"}]
temp_list = []
temp_hash = Hash.new

2.times do |i|
    temp_list[i] = list_to_hash(list)
end

key_list = temp_list[0].keys
=end

=begin
require "sqlite3"
require "active_record"

db = SQLite3::Database.new("test1.db")
db.execute <<-SQL
    create table accesses(
    id integer primary key,
    time text,
    item text,
    count integer,
    created_at,
    updated_at
);
SQL
db.close

ActiveRecord::Base.establish_connection(
    "adapter" => "sqlite3",
    "database" => "test1.db"
)

class Access < ActiveRecord::Base
end


["unagi","shirasagi","takana"].each do |string|
    access = Access.new
    access.time = 01
    access.item = string
    access.count = 12
    access.save
end
=end
