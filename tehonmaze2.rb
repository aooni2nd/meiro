#!ruby -Ks

require "dxruby"

XMAX=66
YMAX=50

SIZE = 10

$dirtable = [
  [0,1,2,3], [0,1,3,2], [0,2,1,3], [0,2,3,1], [0,3,1,2], [0,3,2,1],
  [1,0,2,3], [1,0,3,2], [1,2,0,3], [1,2,3,0], [1,3,0,2], [1,3,2,0],
  [2,0,1,3], [2,0,3,1], [2,1,0,3], [2,1,3,0], [2,3,0,1], [2,3,1,0],
  [3,0,1,2], [3,0,2,1], [3,1,0,2], [3,1,2,0], [3,2,0,1], [3,2,1,0]
]

$dx = [2, 0, -2, 0]
$dy = [0, -2, 0, 2]

$map = Array.new(XMAX + 1) do |i|
  Array.new(YMAX + 1) {|j| ((i >= 3 and j >= 3) and (i <= XMAX - 3 and j <= YMAX - 3)) ? 0 : 1 }
end

$nsite = 0
$xx = []
$yy = []

def add(i, j)
  $xx[$nsite] = i
  $yy[$nsite] = j
  $nsite += 1
end

def select
  return false if $nsite < 0

  $nsite -= 1
  r = rand($nsite)

  ret = [$xx[r], $yy[r]]

  $xx[r] = $xx[$nsite]
  $yy[r] = $yy[$nsite]

  ret
end

i = 0
j = 0

4.step(XMAX - 3, 2) do |i|
  add(i, 2)
  add(i, YMAX - 2)
end

4.step(YMAX - 3, 2) do |j|
  add(2, j)
  add(XMAX - 2, j)
end

$map[2][3] = 0
$map[XMAX - 2][YMAX - 3] = 0

while (s = select)
  i, j = s
  catch(:last) {
    while 1
      tt = $dirtable[rand(24)]
      i1 = 0
      j1 = 0

      3.downto(0) do |d|
        t = tt[d]
        i1 = i + $dx[t]
        j1 = j + $dy[t]
        break if $map[i1][j1] == 0

        throw :last if d == 0
      end

      $map[(i + i1) / 2][(j + j1) / 2] = 1
      i = i1
      j = j1
      $map[i][j] = 1

      add(i, j)
    end
  }
end

$image = Image.new(XMAX * SIZE, YMAX * SIZE)

2.upto(YMAX - 2) do |j|
  2.upto(XMAX - 2) do |i|
    x = i - 2
    y = j - 2

    if ($map[i][j] == 1)
      $image.boxFill(x * SIZE, y * SIZE, (x + 1) * SIZE, (y + 1) * SIZE, [255,255,255])
    end
  end
end

Window.loop do
  Window.draw(SIZE / 2, SIZE / 2, $image)

  break if Input.keyPush?(K_ESCAPE)
end