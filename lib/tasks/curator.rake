namespace :curator do
  task :cron => :environment do 
    def curation(word)
      require 'nokogiri'
      require "open-uri"
      require 'csv'
      require 'mechanize'
      require 'date'

      ######イジるパラメーター#####
      $search_word = word
      $file_name = "public/csv/#{$search_word}_#{DateTime.now.strftime('%Y%m%d%H%M%S')}.csv"
      $google_search = true
      $bing_search = true
      #検索ページ数(1ページ以上)
      page_number = 1 
      ############################

      #検索ページ数1ページ以下の場合の対処
      if page_number < 1
        page_number = 1 
      end
      $page_number = page_number - 1

      def google_scrape
        $google = []
        $google_index = 1
        def google_tag_get(search_result,agent)
          google = []
          h1_tag_array = []
          p_tag_array = []

          doc = Nokogiri::HTML.parse(search_result.body.force_encoding("UTF-8")) 
          doc.css(".g").each do |element|
            begin
            p  url =  element.css("h3.r").css("a").attribute("href").value
              sleep(0.1)
              #サイト内検索 
              detail_page = agent.get(url)
              google << "Google"
              google << $google_index
              google << url.gsub(/\r\n|\r|\n|\s|\t/, "")
          #      detail_doc = Nokogiri::HTML.parse(detail_page.body.force_encoding("UTF-8").encode("UTF-8", :invalid => :replace, :undef => :replace, :replace => '')) 
              detail_doc = Nokogiri::HTML.parse(detail_page.body.force_encoding("UTF-8")) 
             
              #h1タグ取得
              detail_doc.css("h1").each do |h1_tag|
                h1_tag_array << h1_tag.inner_text.gsub(/\r\n|\r|\n|\s|\t|　/, "")
              end
              if h1_tag_array.length == 1
                google << h1_tag_array
              else
                h1_tag_array.delete("")
                google << h1_tag_array
              end
              h1_tag_array = [] 

              #pタグ取得
              detail_doc.css("p").each do |p_tag|
                p_tag_array << p_tag.inner_text.gsub(/\r\n|\r|\n|\s|\t|　/, "")
              end
              if p_tag_array.length == 1
                google << p_tag_array
              else
                p_tag_array.delete("")
                google << p_tag_array
              end
              p_tag_array = []

              #ムダなpタグを削除したのちCSV配列に追加
              if google[4].include?("検索オプションGoogle画像検索ホームヘルプフィードバックを送信")
                google[4].delete("検索オプションGoogle画像検索ホームヘルプフィードバックを送信")
              end
              if google[4].include?("検索オプションRSSヘルプを検索フィードバックを送信")
                google[4].delete("検索オプションRSSヘルプを検索フィードバックを送信")
              end
              if google[4].include?("JavaScriptの設定が「無効」です。")
                google[4].delete("JavaScriptの設定が「無効」です。")
              end
              if google[4].include?("JavaScriptの設定が「無効」になっています。")
                google[4].delete("JavaScriptの設定が「無効」になっています。")
              end
              if google[4].include?("お使いのブラウザはJavaScriptに対応していないか、または無効になっています。詳しくはサイトポリシーのページをご覧ください。")
                google[4].delete("お使いのブラウザはJavaScriptに対応していないか、または無効になっています。詳しくはサイトポリシーのページをご覧ください。")
              end
              
              $google << google
              google = []   

            rescue
              puts "エラー"
              google = []
              next 
            end
            $google_index += 1
          end

          #検索結果内の次へボタン
          #前へボタンと次へボタンの2つある場合
          if doc.css(".pn")[1] 
            next_url = "https://www.google.co.jp" + doc.css(".pn")[1].attribute("href").value
          #次へボタン1つの場合
          else
            next_url = "https://www.google.co.jp" + doc.css(".pn").attribute("href").value
          end 
          return agent.get(next_url)
        end

        agent = Mechanize.new
        agent.user_agent_alias = 'Mac Safari'
        page = agent.get("https://www.google.co.jp")
        form = page.forms.first
        form['q'] = $search_word
        search_result = form.click_button

        #1ページ目の探索
        puts "1ページ目の探索"
        next_search_result = google_tag_get(search_result,agent)

        #2ページ目以降の探索
        $page_number.times do
          puts "2ページ目以降の探索"
          next_search_result = google_tag_get(next_search_result,agent)
        end
      end

      def bing_scrape
        $bing = []
        $bing_index = 1
          def bing_tag_get(search_result,agent) 
            bing = []
            h1_tag_array = []
            p_tag_array = []

            doc = Nokogiri::HTML.parse(search_result.body.force_encoding("UTF-8"))
            doc.css(".b_algo").each do |element|
              begin
                p  url = element.css("a").attribute("href").value
                sleep(0.1)
                #サイト内検索 
                detail_page = agent.get(url)
                bing << "Bing"
                bing << $bing_index 
                bing << url.gsub(/\r\n|\r|\n|\s|\t/, "")
#p  detail_doc = Nokogiri::HTML.parse(detail_page.body.force_encoding("UTF-8").encode("UTF-8", :invalid => :replace, :undef => :replace, :replace => '')) 
                detail_doc = Nokogiri::HTML.parse(detail_page.body.force_encoding("UTF-8")) 

                #h1タグ取得
                detail_doc.css("h1").each do |h1_tag|
                  h1_tag_array << h1_tag.inner_text.gsub(/\r\n|\r|\n|\s|\t/, "")
                end
                h1_tag_array.delete("")
                bing << h1_tag_array
                h1_tag_array = []
                
                #pタグ取得
                detail_doc.css("p").each do |p_tag|
                  p_tag_array << p_tag.inner_text.gsub(/\r\n|\r|\n|\s|\t/, "")
                end
                p_tag_array.delete("")
                bing << p_tag_array
                p_tag_array = []

                #ムダなpタグを削除したのちCSV配列に追加
                if bing[4].include?("検索オプションRSSヘルプを検索フィードバックを送信")
                  bing[4].delete("検索オプションRSSヘルプを検索フィードバックを送信")
                end
                if
                  bing[4].delete("JavaScriptの設定が「無効」です。")
                end
                if bing[4].include?("JavaScriptの設定が「無効」になっています。")
                  bing[4].delete("JavaScriptの設定が「無効」になっています。")
                end
                if bing[4].include?("お使いのブラウザはJavaScriptに対応していないか、または無効になっています。詳しくはサイトポリシーのページをご覧ください。")
                  bing[4].delete("お使いのブラウザはJavaScriptに対応していないか、または無効になっています。詳しくはサイトポリシーのページをご覧ください。")
                end

                $bing << bing
                bing = []
              rescue
                bing = []
                puts "エラー"
                next
              end
              $bing_index += 1
            end

            #検索結果内の次へボタン
            next_url = "https://www.bing.com" + doc.css(".sb_pagN").attribute("href").value
            return agent.get(next_url)

          end

          agent = Mechanize.new
          agent.user_agent_alias = 'Mac Safari'
          page = agent.get("https://www.bing.com/")
          form = page.forms.first
          form['q'] = $search_word
          search_result = form.click_button

          #1ページ目の探索
          puts "1ページ目の探索"
          next_search_result = bing_tag_get(search_result,agent)

          #2ページ目以降の探索
          $page_number.times do
            puts "2ページ目以降の探索"
            next_search_result = bing_tag_get(next_search_result,agent)
          end
      end

      def to_csv
        header = ["検索エンジン","ランク順位","url","h1タグ","pタグ"]  
        CSV.open($file_name,'w',:encoding => "Shift_JIS:UTF-8",:headers => true, undef: :replace, replace: '*') do |file|  
          file << header

          if $google_search
            $google.each do |line|
              file << line
            end
          end
          if $bing_search
            $bing.each do |line|
              file << line
            end
          end
        end
       puts "CSV出力--------------------------------------------------------------------------"
      end

      if $google_search
        google_scrape
      end
      if $bing_search
        bing_scrape
      end
      to_csv 
    end

    Curator.all.each do |curator|
      if curator.cron != false 
        curation(curator.word) 
        CsvFile.create(file_name: $file_name,curator_id: curator.id)
      end
    end
  end
end
