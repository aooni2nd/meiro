require 'dxruby'

# ウィンドウのサイズを設定
Window.width = 800
Window.height = 600

# 爆発エフェクトのパラメータ
explosion_radius = 10       # 爆発の初期半径
explosion_max_radius = 100  # 爆発の最大半径
explosion_speed = 5         # 爆発の拡大速度
explosion_color = [255, 0, 0, 200]  # 爆発の色（赤）

explosion_x = Window.width / 2  # 爆発のX座標
explosion_y = Window.height / 2 # 爆発のY座標

# メインのループ
Window.loop do
  # ウィンドウをクリア
  Window.draw_box_fill(0, 0, Window.width, Window.height, [0, 0, 0])

  # 爆発の半径を増加させる
  explosion_radius += explosion_speed


  # 爆発を描画する
  Window.draw_circle_fill(explosion_x, explosion_y, explosion_radius, explosion_color)
end
