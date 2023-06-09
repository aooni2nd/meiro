require 'dxruby'

Window.width = 800
Window.height = 600

#Time変更部分a
# 制限時間
TIME_LIMIT = 20  # 制限時間（秒）
FONT_SIZE = 32  # 時間表示のフォントサイズ
TIME_COLOR = [255, 255, 255]  # 時間表示の文字色

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
lose_result_image = Image.load("lose_result_menu.png")



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

#Time変更部分
# ゲーム開始時刻
start_time = Time.now

# ゲーム終了フラグ
game_over = false



#道の座標を返す関数     （★たまに壁上の座標を返すことがあるので要修正だと思います）
#呼び出し方：●●, ▼▼ = road_point(任意の数, 任意の数)で呼び出しと格納を同時に行います
#アイテム配置にも使えます！
def road_point(xx, yy)        #変数は2つで, この関数内ではxxとyyで処理される
  while $maze[xx][yy] == 1    #道の上になるまでランダムに発生させることを繰り返す
      xx = rand(2..13)
      yy = rand(2..13)
  end
  return xx, yy
end

#次の立ち位置を返す関数
#呼び出し方：●●, ▼▼ = random_move(移動前x座標, 移動前y座標) で関数呼び出しと格納を同時に行います
#他の移動する敵キャラクターにも使えます！
#原理：（方向乱数を出す→その方向が道ならばそこに座標を移動）←これを繰り返す
#迷路作成のコードに合わせて, dirは0:左, 1:下, 2:右, 3:上 としています
def random_move(x, y)   #この関数内ではxとyで処理される
  count = 0
  while count <= 0        #ここを大きくしてもいいけど、ワープしたように見えたり、絶対に立てない道が出たりする。                    # 0にしておけば, 壁の方向が乱数として出ても必ず移動させられる
      dir = rand(0..3) #方向
      if dir == 0 && $maze[y][x - 1] == 0 #移動方向左かつ左が壁ではないとき
          x -= 1
          count += 1
      elsif dir == 1 && $maze[y + 1][x] == 0
          y += 1
          count += 1
      elsif dir == 2 && $maze[y][x + 1] == 0
          x += 1
          count += 1
      elsif dir == 3 && $maze[y - 1][x] == 0
          y -= 1
          count += 1
      end
  end
  return x, y     #移動後の座標を返します
end



#敵に関する諸変数定義
enemy_image = Image.load("item1.png")     #敵の見た目
enemy_flag = false          #敵の動作準備フラグ

#敵の位置（初期）を決定する（初回なのでroad_point(テキトーな値, テキトーな値)で呼び出す）
enemy_x, enemy_y = road_point(0, 0)   #★13,13にすると壁をすり抜けることがある（修正が必要かも）






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
game_lose = false

#マップアイテム
item_get = false
item = Image.load("item.png")
item_x, item_y = road_point(0, 0)


#スクリーン制御
is_menu_screen = true
is_gacha_menu_screen = false
is_gacha_screen = false
is_result_screen = false
lose_result_screen = false
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
      start_time = Time.now
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

    end
  elsif is_result_screen
    Window.draw_font(50, 50, "Game Clear!", Font.default, color: C_BLUE)
    Window.draw_font(140, 300, "Enterでメニューに戻る", Font.default)
    start_time = Time.now
    # キャラクターの位置リセット
    player_x = 1
    player_y = 1
    if Input.key_push?(K_RETURN)
      is_result_screen = false
      is_menu_screen = true
      game_clear = false
      
    end
  elsif lose_result_screen 
    Window.draw(3, 0, lose_result_image)
    #Window.draw_font(50, 50, "負け", Font.default, color: C_BLUE)
    Window.draw_font(300, 700, "Enterでメニューに戻る", Font.default)
    # キャラクターの位置リセット
    remaining_time = 5
    player_x = 1
    player_y = 1

    start_time = Time.now
    if Input.key_push?(K_RETURN)
      is_game_lose = false
      is_menu_screen = true
      game_lose =false
      game_clear = false
      lose_result_screen = false 

    end
  end
  




  # 迷路ゲームの描画と更新
  if !is_menu_screen && !is_gacha_menu_screen && !is_gacha_screen&& !is_result_screen && !lose_result_screen 
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
    
    # タイマーの描画
    
    elapsed_time = (Time.now - start_time).to_i
    remaining_time = TIME_LIMIT - elapsed_time
    Window.draw_font(10, 10, "Time: #{remaining_time}", Font.default, color: TIME_COLOR, size: FONT_SIZE)
 
     # ゲームの終了条件判定
    if remaining_time <= 0
      game_lose = true
    end
  

    
  
    # プレイヤーの描画
    Window.draw_scale(player_x * 50 - 40, player_y * 50 - 40, gacha_result_image,0.39,0.39)
  
    #アイテムゲット
    if item_get==false
      Window.draw(item_x * 50, item_y * 50,item)
    end

    # ゴールの描画
    Window.draw_box_fill(goal_x * 50, goal_y * 50, goal_x * 50 + 50, goal_y * 50 + 50, C_GREEN)
  
    #敵の描画
    Window.draw(enemy_x * 50, enemy_y * 50, enemy_image)        #enemy_imageは画像

    #敵の移動
    while enemy_flag == true
    
    #次に進む方向を決める
    enemy_x, enemy_y = random_move(enemy_x, enemy_y)
    #フラグをもとに戻す
    enemy_flag = false
    end









    # ゲームの更新
    if Input.key_push?(K_UP) && $maze[player_y - 1][player_x] == 0
      player_y -= 1
      enemy_flag = true
    end
    if Input.key_push?(K_DOWN) && $maze[player_y + 1][player_x] == 0
      player_y += 1
      enemy_flag = true
    end
    if Input.key_push?(K_LEFT) && $maze[player_y][player_x - 1] == 0
      player_x -= 1
      enemy_flag = true
    end
    if Input.key_push?(K_RIGHT) && $maze[player_y][player_x + 1] == 0
      player_x += 1
      enemy_flag = true
    end
  

    #アイテム
    if player_x == item_x && player_y == item_y
      item_get = true
    end


    # ゲームの終了条件(勝ち)
    if player_x == goal_x && player_y == goal_y
      game_clear = true
    end
  
    # ゲームクリア時の処理
    if game_clear
      is_result_screen = true
      
      #Window.draw_font(100, 200, "Game Clear!", Font.default, color: C_BLUE)
    end
    
    if game_lose
      lose_result_screen = true
      
      #Window.draw_font(100, 200, "Game Clear!", Font.default, color: C_BLUE)
    
    end
  end
  
  break if Input.key_down?(K_ESCAPE) # ESCキーでゲーム終了
end