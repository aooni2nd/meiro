require 'dxruby'

# 迷路データ
maze = [
  [1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
  [1, 0, 0, 0, 1, 0, 0, 0, 0, 1],
  [1, 0, 1, 0, 1, 0, 1, 1, 0, 1],
  [1, 0, 1, 0, 0, 0, 1, 0, 0, 1],
  [1, 0, 1, 1, 1, 1, 1, 0, 1, 1],
  [1, 0, 1, 0, 0, 0, 0, 0, 0, 1],
  [1, 0, 1, 0, 1, 1, 1, 1, 0, 1],
  [1, 0, 0, 0, 0, 0, 0, 0, 0, 1],
  [1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
]

# キャラクターの位置
player_x = 1
player_y = 1

# 迷路のサイズ
maze_width = maze[0].size
maze_height = maze.size

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
  maze_height.times do |y|
    maze_width.times do |x|
      case maze[y][x]
      when 1
        Window.draw_box_fill(x * 50, y * 50, x * 50 + 50, y * 50 + 50, C_BLACK) # 壁の描画
      when 0
        Window.draw_box_fill(x * 50, y * 50, x * 50 + 50, y * 50 + 50, C_WHITE) # 道の描画
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
