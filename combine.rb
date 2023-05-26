require 'dxruby'

# 迷路データ
m_jigen = 11   #★必ず 5以上の奇数 を入れてください
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

# メインループ
Window.loop do
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
  Window.draw_box_fill(player_x * 50, player_y * 50, player_x * 50 + 50, player_y * 50 + 50, C_RED)

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
    Window.draw_font(100, 200, "Game Clear!", Font.default, color: C_BLUE)
    break
  end

  break if Input.key_down?(K_ESCAPE) # ESCキーでゲーム終了
end