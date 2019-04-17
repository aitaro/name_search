require 'nokogiri'
require 'open-uri'

require 'net/http'
require 'uri'

tmi_last_name=%w(田中 佐藤 鈴木)
tmi_first_name_kana=%w(さとし かすみ たけし)

puts '----- 名字 頻度 ------'
tmi_last_name.each do |last_name|
  url = "https://namaeranking.com/?search=同姓同名&surname=#{last_name}&firstname=&tdfk=全国"

  charset = nil

  html = open(URI.encode(url)) do |f|
      charset = f.charset
      f.read
  end

  doc = Nokogiri::HTML.parse(html, nil, charset)
  puts last_name + ' : ' +doc.xpath('//h1[@class="title"]').inner_text[/(\d,?)+/] + '人'
  sleep 1
end

puts '----- 名前 頻度 ------'
tmi_first_name_kana.each do |first_name_kana|
  url = URI.parse('http://5go.biz/sei/cgi/kensaku.cgi')
  req = Net::HTTP::Post.new(url.path)
  req.set_form_data(
    {'f1' => first_name_kana.encode('EUC-JP'),
      'pe' => '0',
      'fs' => '1',
      'ff1' => '1',
      'fff1' => '1',
      'ff2' => '1',
      'fff2' => '0',
      'hhh' => '2'
     }, ';')
  res = Net::HTTP.new(url.host, url.port).start do |http|
    http.request(req)
  end
  first_name_list = []
  # puts res.charset
  noko = Nokogiri::HTML(res.body)
  noko.xpath('//tr/td/div/a').each do |n|
    name = n.inner_text.encode('UTF-8')[/.+\s\-/]
    next unless name
    first_name_list.push name[0..-3]
    break if first_name_list.length > 40
  end

  sum = 0
  first_name_list.each do |first_name|

    url = "https://namaeranking.com/?search=同姓同名&surname=&firstname=#{first_name}&tdfk=全国"

    charset = nil

    html = open(URI.encode(url)) do |f|
        charset = f.charset
        f.read
    end

    doc = Nokogiri::HTML.parse(html, nil, charset)
    sum += doc.xpath('//h1[@class="title"]').inner_text[/(\d,?)+/].to_i
    sleep 1
  end
  puts first_name_kana + ' : ' + sum.to_s + '人'
end
