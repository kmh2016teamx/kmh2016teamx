#!/bin/bash

echo -e '\n\n'
echo '環境構築!!'
set -e
cd /var/www/kmh2016teamx/commands
source ~/.bashrc

# ファイル内に文字列が存在しない場合、追加でその文字列を書き込み
# [$1] 文字列
# [$2] ファイルのパス
function echo_if_not_exists {
  if ! [ "`cat $2 | grep "$1"`" ]; then
    echo "$1" >> $2
  fi
}

# コマンドが存在するかどうか調べる
# [$1] コマンド名
function command_exists {
  command -v "$1" >/dev/null 2>&1 ;
}



bundle install

