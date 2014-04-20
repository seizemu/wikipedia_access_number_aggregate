require "cgi"
require "nokogiri"
    

def access_analysis(base_filename,output_number)

    #gzipコマンドを使ってファイルを解凍
    `gzip -d #{base_filename}`


    filename = base_filename.split(".")[0]
    

    #ファイルを開く
    file = File.open(filename,"r:UTF-8")

    #日本からのアクセスを保持する配列
    list = []
    result = []

    #ファイルから一行ずつ読み出し
    file.each_line do |text|
        begin

        if text =~ /^ja/

            #splitメソッドでスペースごとにわけて配列に代入
            data = text.split

            #必要な要素を取り出す
            h = {title: CGI.unescape(data[1]), count: data[-2]}

            #pushメソッドで配列に代入
            list.push h
        end

        #例外処理
        rescue Exception => e
        p e
        end
    end

    file.close


    #ソートして一時的に配列に格納する
    temp = list.sort_by do |i|
        i[:count].to_i
    end

    #アクセス数のデータを昇順に並べ替えて最初から指定数を指定し配列に代入
    temp.reverse.first(output_number).each do |i|
        result.push(i)
    end

    return result
end


#nookogiriを使ってwikipediaのアクセス数を掲載しているwebサイトにファイルが上がっているかを確認
def file_upload_confirmation(date_hash, url)

    list = Array.new
    doc = Nokogiri::HTML(open(url))

    #xpathでaタグを指定
    a = doc.xpath("//a")

    #aタグ内のテキストを任意の条件で指定し、配列に代入
    a.each do |tag|
        if /.gz$/ =~ tag.text and tag.text.split("-")[1] == date_hash["date"]
            list.push(tag.text)
        end
    end
    
    return list
end


#ファイル名に記載されている時間を抜き出すメソッド
def hour_select(str)
    number = str.split("-")[-1].split(".")[0]
    return number[0..1].to_i
end
