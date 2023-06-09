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
  GachaItem.new("man", "ch1man.png", "通常"),
  GachaItem.new("woman", "ch2woman.png", "通常"),
  GachaItem.new("cos", "ch3cos.png", "超激レア"),
  GachaItem.new("fox", "ch4fox.png", "通常"),
  GachaItem.new("oct", "ch5oct.png", "通常"),
  GachaItem.new("ball", "ch6.png", "超激レア")

]

menu_image = Image.load('menu.png')
gacha_menu_image = Image.load('gacha_menu.png')
gacha_result_menu_image = Image.load('gacha_result_menu.png')
gacha_result_image = Image.load("ch1man.png")


# 迷路データ
m_jigen = 15   #★必ず 5以上の奇数 を入れてください
p_jigen = (m_jigen-3) / 2

#------------------------------------------------------------
#柱の配列を作る pillar
pillar = Array.new(p_jigen) {Array.new(p_jigen, 0)}
#puts(pillar.inspect)

#乱数をつくり, 配列に代入していく
for i in 0..p_jigen-1
    for j in 0..p_jigen-1
        if i == 0
            pillar[i][j] = rand(0..3)   #一番上の行の柱は4方向に倒す
        else
            pillar[i][j] = rand(0..2)   #2行目以降の柱は3方向に倒す
        end
    end
end

#------------------------------------------------------------
#迷路本体の配列を作る maze
$maze = Array.new(m_jigen) {Array.new(m_jigen, 0)}
#puts(maze.inspect)

#枠を作る
#maze[縦][横]
for n in 0..m_jigen-1
    $maze[n][0] = 1        #左枠
    $maze[n][m_jigen-1] = 1  #右枠
    $maze[0][n] = 1        #上枠
    $maze[m_jigen-1][n] = 1  #下枠
end

#pillarの柱がある部分を1にする
for i in 0..p_jigen-1
    for j in 0..p_jigen-1
        row = 2*i + 2
        col = 2*j + 2
        $maze[row][col] = 1
    end
end

#倒した柱をpillarからmazeに反映させる
for i in 0..p_jigen-1
    for j in 0..p_jigen-1
        row = 2*i + 2   #縦
        col = 2*j + 2   #横

        if pillar[i][j] == 0
            $maze[row][col-1] = 1
        elsif pillar[i][j] == 1
            $maze[row+1][col] = 1
        elsif pillar[i][j] == 2
            $maze[row][col+1] = 1
        else
            $maze[row-1][col] = 1
        end
    end
end



# キャラクターの位置
player_x = 1
player_y = 1

# 迷路のサイズ
maze_width = $maze[0].size
maze_height = $maze.size

# ウィンドウのサイズ
window_width = maze_width * 50
window_height = maze_height * 50

# ウィンドウの初期化
Window.width = window_width
Window.height = window_height

# ゴールの位置
goal_x = maze_width - 2
goal_y = maze_height - 2

# ゲームクリアフラグ
game_clear = false



is_menu_screen = true
is_gacha_menu_screen = false
is_gacha_screen = false
is_result_screen = false
selected_item = nil
gacha_result_image = Image.load("ch1man.png")
gacha_result_name = nil
#maze_game = MazeGame.new

is_result_screen = false

Window.loop do
  # メニュー画面の選択肢を定義
  menu_items = ["ガチャを引く", "迷路ゲーム"]

  if is_menu_screen
    # メニュー画面の描画
    
    #Window.draw_font(10, 10, "メニュー画面", Font.default)
    
    Window.draw(3, 0, menu_image)
    menu_items.each_with_index do |item, index|
      #Window.draw_font(10, 60 + index * 30, "#{index + 1}: #{item}", Font.default)
      Window.draw_font(10, 700, "ガチャ結果: #{gacha_result_name}", Font.default)
    end

    # キー入力をチェックして選択肢を処理
    if Input.key_push?(K_2)
      # ガチャを選択した場合の処理
      puts "ガチャが選択されました"
      is_menu_screen = false
      is_gacha_menu_screen = true
    elsif Input.key_push?(K_1)
      # 迷路ゲームを選択した場合の処理
      puts "迷路ゲームが選択されました"
      is_menu_screen = false
      is_gacha_menu_screen = false
      is_gacha_screen = false
      
      # 迷路ゲームの処理を行う
      puts "迷路ゲームが選択されました"
      is_menu_screen = false
      is_gacha_menu_screen = false
      is_gacha_screen = false
    end
      
  elsif is_gacha_menu_screen
    # ガチャメニューの描画
    Window.draw(3, 0, gacha_menu_image)

    if Input.key_push?(K_DOWN)
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
      Window.draw(3, 0, gacha_result_menu_image)
      Window.draw_scale(330, 330, gacha_result_image,3,3)
      Window.draw_font(300, 700, "Enterでメニューに戻る", Font.default)
      Window.draw_font(1000, 1000, "超激レア", Font.default) if selected_item.rarity == "超激レア"
  
    else
      default_item_image = items[0].load_image
      Window.draw(0, 0, default_item_image)
      Window.draw_font(1000, 1000, "超激レア", Font.default)
      Window.draw_font(10, 700, "ガチャ結果: #{items[0].name}", Font.default)
    end

    if Input.key_push?(K_RETURN)
      is_gacha_screen = false
      is_menu_screen = true
      selected_item = nil
      #gacha_result_image = nil
      #gacha_result_name = nil
    end
  elsif is_result_screen
    Window.draw_font(50, 50, "Game Clear!", Font.default, color: C_BLUE)
    Window.draw_font(140, 300, "Enterでメニューに戻る", Font.default)
    # キャラクターの位置リセット
    player_x = 1
    player_y = 1
    if Input.key_push?(K_RETURN)
      is_result_screen = false
      is_menu_screen = true
      game_clear = false
      
    end
  end
  




  # 迷路ゲームの描画と更新
  if !is_menu_screen && !is_gacha_menu_screen && !is_gacha_screen&& !is_result_screen 
    # ゲームの描画
    Window.draw_box_fill(0, 0, window_width, window_height, C_WHITE) # 背景の描画

    # 迷路の描画
    maze_height.times do |i|
      maze_width.times do |j|
        case $maze[i][j]
        when 1
          Window.draw_box_fill(j * 50, i * 50, j * 50 + 50, i * 50 + 50, C_BLACK) # 壁の描画
        when 0
          Window.draw_box_fill(j * 50, i * 50, j * 50 + 50, i * 50 + 50, C_WHITE) # 道の描画
        end
      end
    end
  
    # プレイヤーの描画
    Window.draw_scale(player_x * 50 - 40, player_y * 50 - 40, gacha_result_image,0.39,0.39)
  
    # ゴールの描画
    Window.draw_box_fill(goal_x * 50, goal_y * 50, goal_x * 50 + 50, goal_y * 50 + 50, C_GREEN)
  
    # ゲームの更新
    if Input.key_push?(K_UP) && $maze[player_y - 1][player_x] == 0
      player_y -= 1
    end
    if Input.key_push?(K_DOWN) && $maze[player_y + 1][player_x] == 0
      player_y += 1
    end
    if Input.key_push?(K_LEFT) && $maze[player_y][player_x - 1] == 0
      player_x -= 1
    end
    if Input.key_push?(K_RIGHT) && $maze[player_y][player_x + 1] == 0
      player_x += 1
    end
  
    # ゲームの終了条件
    if player_x == goal_x && player_y == goal_y
      game_clear = true
    end
  
    # ゲームクリア時の処理
    if game_clear
      is_result_screen = true
      #Window.draw_font(100, 200, "Game Clear!", Font.default, color: C_BLUE)
    
    end
  end
  
  break if Input.key_down?(K_ESCAPE) # ESCキーでゲーム終了
end