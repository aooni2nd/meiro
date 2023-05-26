require 'dxruby'

Window.width = 800
Window.height = 600

class GachaItem
  attr_reader :name, :image, :rarity

  def initialize(name, image_path, rarity)
    @name = name
    @image_path = image_path
    @image = nil
    @rarity = rarity
  end

  def load_image
    @image = Image.load(@image_path)
  end
end

items = [
  GachaItem.new("アイテム1", "item1.png", "通常"),
  GachaItem.new("アイテム2", "item2.png", "通常"),
  GachaItem.new("アイテム3", "item3.png", "超激レア")
]

is_menu_screen = true
is_gacha_menu_screen = false
is_gacha_screen = false
selected_item = nil
gacha_result_image = nil
gacha_result_name = nil

Window.loop do
  # メニュー画面の選択肢を定義
  menu_items = ["ガチャを引く", "迷路ゲーム"]

  if is_menu_screen
    # メニュー画面の描画
    Window.draw_font(100, 100, "メニュー画面", Font.default)
    menu_items.each_with_index do |item, index|
      Window.draw_font(120, 150 + index * 30, "#{index + 1}: #{item}", Font.default)
      Window.draw_font(10, 560, "ガチャ結果: #{gacha_result_name}", Font.default)
    end

    # キー入力をチェックして選択肢を処理
    if Input.key_push?(K_1)
      # ガチャを選択した場合の処理
      puts "ガチャが選択されました"
      is_menu_screen = false
      is_gacha_menu_screen = true
    elsif Input.key_push?(K_2)
      # 迷路ゲームを選択した場合の処理
      puts "迷路ゲームが選択されました"
      require_relative 'maze_game.rb'
      # 迷路ゲームのコードを実行するコードを追加
      break
    end
  elsif is_gacha_menu_screen
    # ガチャメニューの描画
    Window.draw_font(100, 100, "ガチャメニュー", Font.default)

    if Input.key_push?(K_UP)
      selected_item = items.sample
      puts "ガチャの結果: #{selected_item.name} (#{selected_item.rarity})"
      is_gacha_menu_screen = false
      is_gacha_screen = true
      gacha_result_image = selected_item.load_image
      gacha_result_name = selected_item.name
    elsif Input.key_push?(K_ESCAPE)
      is_gacha_menu_screen = false
      is_menu_screen = true
    end
  elsif is_gacha_screen
    if selected_item
      Window.draw(0, 0, gacha_result_image)
      Window.draw_font(10, 10, "超激レア", Font.default) if selected_item.rarity == "超激レア"
      Window.draw_font(10, 560, "ガチャ結果: #{gacha_result_name}", Font.default)
    else
      default_item_image = items[0].load_image
      Window.draw(0, 0, default_item_image)
      Window.draw_font(10, 10, "超激レア", Font.default)
      Window.draw_font(10, 560, "ガチャ結果: #{items[0].name}", Font.default)
    end

    if Input.key_push?(K_RETURN)
      is_gacha_screen = false
      is_menu_screen = true
      selected_item = nil
      #gacha_result_image = nil
      #gacha_result_name = nil
    end
  end

  break if Input.key_push?(K_ESCAPE)
end
