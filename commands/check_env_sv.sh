#!/bin/bash

echo -e '\n\n'
echo '確認!!'

source ~/.bashrc

function check {
  echo
  echo "\$ $@"
  "$@"
}

echo -e '\n\n'
echo '# 基本編'

check gcc -v


echo -e '\n\n'
echo '# Ruby on Rails 関連編'

check rbenv --version
check ruby -v
check rails -v
check mysql --version
check nvm --version
check npm -v
check node -v
check bower -v


echo -e '\n\n'
echo '# これは入れておきたいよね編'

check emacs --version
check nano --version
check nkf -V
check scp
check tmux -V
check bash -c "vim --version | grep 'VIM -'"
check zsh --version

echo -e '\n\n'
echo '# apache 設定編'

check httpd -v
check passenger-config --version


echo -e '\n\n'
echo '# その他設定編'

check date
