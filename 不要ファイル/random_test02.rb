#230526_1820~230526_2037ee
=begin
■説明
- 0と1のいずれかが要素のn次正方行列として得られればいいので,
  m_jigen を迷路本体の縦横のマス目数としています. （外枠の壁も壁の太さも1マスとしています.）
  p_jigen, pillar は倒す柱を表現するときに使ったものです.

- 道順を1通りにしようとすると, これより複雑で書けそうになかったので, 結局道順が複数ある迷路になりました.

- 仕様上, m_jigen は 5以上の奇数 でなければ動作しません.

- ターミナル上で, 生成された maze配列 をすぐ確認できるようにしておきました.

■使い方
①26行目の m_jigen = 　 に奇数を設定する
②実行する
→mazeに目的の配列が代入される

■連絡？
- 他スクリプトから, 本スクリプトの変数mazeを参照する方法がよくわからないので, そこら辺をどなたかにお願いしたいです.
=end
#------------------------------------------------------------

require 'dxruby'

#次元定義
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
maze = Array.new(m_jigen) {Array.new(m_jigen, 0)}
#puts(maze.inspect)

#枠を作る
#maze[縦][横]
for n in 0..m_jigen-1
    maze[n][0] = 1        #左枠
    maze[n][m_jigen-1] = 1  #右枠
    maze[0][n] = 1        #上枠
    maze[m_jigen-1][n] = 1  #下枠
end

#pillarの柱がある部分を1にする
for i in 0..p_jigen-1
    for j in 0..p_jigen-1
        row = 2*i + 2
        col = 2*j + 2
        maze[row][col] = 1
    end
end

#倒した柱をpillarからmazeに反映させる
for i in 0..p_jigen-1
    for j in 0..p_jigen-1
        row = 2*i + 2   #縦
        col = 2*j + 2   #横

        if pillar[i][j] == 0
            maze[row][col-1] = 1
        elsif pillar[i][j] == 1
            maze[row+1][col] = 1
        elsif pillar[i][j] == 2
            maze[row][col+1] = 1
        else
            maze[row-1][col] = 1
        end
    end
end

#確認用
puts("確認用です↓")
for i in 0..m_jigen-1
    for j in 0..m_jigen-1
        print(" #{maze[i][j]}")
    end
    puts
end
puts("maze配列です↓\n#{maze.inspect}")