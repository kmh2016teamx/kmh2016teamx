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


echo -e '\n\n'
echo '# 基本編'

sudo yum -y install gcc gcc-c++ make kernel-devel kernel-headers dkms
sudo yum -y install curl-devel openssl-devel libyaml-devel libffi-devel readline-devel zlib-devel gdbm-devel ncurses-devel
# 以下のライブラリは gem nokogiri のインストールに必要
sudo yum -y install libxml2 libxml2-devel libxslt libxslt-devel
# このシェルスクリプト内で後々使う
sudo yum -y install expect
# gem 'rails-erd' で使う
sudo yum -y install graphviz
sudo yum -y update

# sed コマンドの alias を設定
shopt -s expand_aliases
if sed --version 2>/dev/null | grep -q GNU; then
  alias sedi='sed -i"" '
else
  alias sedi='sed -i "" '
fi

echo -e '\n\n'
echo '# Ruby on Rails 関連編'

echo '## ruby アンインストール'
sudo yum -y remove ruby

echo '## git'
sudo yum -y install git

echo '## mysql'
sudo yum -y install mysql-server mysql-devel
sudo chkconfig mysqld on
sudo service mysqld start
# mysql のユーザー設定
expect -c "
  spawn mysql -u root
  expect \"mysql>\"
  send \"CREATE USER 'kmh2016teamx'@'localhost';\n\"
  expect \"mysql>\"
  send \"GRANT ALL PRIVILEGES ON *.* TO 'kmh2016teamx'@'localhost';\n\"
  expect \"mysql>\"
  send \"quit\n\"
"
echo

echo '## rbenv'
if ! [ -e ~/.rbenv ]; then
  git clone https://github.com/sstephenson/rbenv.git ~/.rbenv
  echo_if_not_exists 'export PATH="$HOME/.rbenv/bin:$PATH"' ~/.bash_profile
  echo_if_not_exists 'export PATH="$HOME/.rbenv/bin:$PATH"' ~/.zshrc
  echo_if_not_exists 'eval "$(rbenv init -)"' ~/.bash_profile
  echo_if_not_exists 'eval "$(rbenv init -)"' ~/.zshrc
  source ~/.bash_profile
fi

echo '## ruby-build'
if ! [ -e ~/.rbenv/plugins/ruby-build ]; then
  git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
  sudo ~/.rbenv/plugins/ruby-build/install.sh
fi

echo '## ruby'
if ! [ "`ruby -v | grep '2.3.1'`" ]; then
  rbenv install 2.3.1
  rbenv rehash
  rbenv global 2.3.1
fi

echo '## bundler'
if ! [ "`bundler -v | grep 'Bundler version'`" ]; then
  rbenv exec gem install bundler
  rbenv rehash
fi

echo '## rails'
if ! [ "`rails -v | grep '4.2.7'`" ]; then
  gem install rails --version 4.2.7 --no-document
fi

echo '### bundle install'
bundle config build.nokogiri --use-system-libraries
# bundle install

# echo '### secrets.yml 作成'
# ./create_secrets_sv.sh

echo '## bower インストール'

echo '### nvm'
sudo yum -y erase npm
if ! [ -s ~/.nvm ] ; then
  sedi "/##### begin nvm #####/,/##### end nvm #####/c\\" ~/.bashrc
  sedi "/##### begin nvm #####/,/##### end nvm #####/c\\" ~/.zshrc
  curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.32.0/install.sh | bash
  export NVM_DIR="/home/vagrant/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm

  for str_to_delete in 'export NVM_DIR=\"\/home\/vagrant\/.nvm\"' '[ -s \"$NVM_DIR\/nvm.sh\" ] && . \"$NVM_DIR\/nvm.sh\"  # This loads nvm'
  do
    sedi "/$str_to_delete/d" ~/.bashrc
    sedi "/$str_to_delete/d" ~/.zshrc
  done
fi

echo '### node'
if ! [ "`node --version | grep 'v6.4.0'`" ]; then
  nvm install v6.4.0
  nvm use v6.4.0
fi

echo '### nvm 高速化'
nvm_config_script=$(cat <<EOF
if [ -s \$HOME/.nvm ]; then
  export NVM_DIR="\$HOME/.nvm"
  NVM_DEFAULT_VERSION=\`cat \$NVM_DIR/alias/default\`
  NVM_DEFAULT_DIR=\$NVM_DIR/versions/node/\$NVM_DAFAULT_VERSION
  PATH=\$NVM_DEFAULT_DIR/bin:\$PATH
  MANPATH=\$NVM_DEFAULT_DIR/share/man:\$MANPATH
  export NODE_PATH=\$NVM_DEFAULT_DIR/lib/node_modules
  NODE_PATH=\${NODE_PATH:A}
  nvm() {
    unset -f nvm
    source "\$NVM_DIR/nvm.sh"
    nvm "\$@"
  }
fi
EOF
)

sedi "/##### begin nvm #####/,/##### end nvm #####/c\\" ~/.bashrc
sedi "/##### begin nvm #####/,/##### end nvm #####/c\\" ~/.zshrc

echo "##### begin nvm #####" >> ~/.bashrc
echo "##### begin nvm #####" >> ~/.zshrc
echo "$nvm_config_script" >> ~/.bashrc
echo "$nvm_config_script" >> ~/.zshrc
echo "##### end nvm #####" >> ~/.bashrc
echo "##### end nvm #####" >> ~/.zshrc
source ~/.bashrc

echo '### bower'
npm -g update
if ! command_exists 'bower' ; then
  npm -g install bower
fi

echo '### bower package 更新'
# rails bower:update

echo "## zip"
sudo yum -y install zip unzip


echo -e '\n\n'
echo '# これは入れておきたいよね編'

echo '## apache'
sudo yum -y install httpd httpd-devel
if [ ! -e /etc/httpd/conf/httpd.conf.orig ]; then
  sudo cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.orig
fi

echo '## emacs'
sudo yum -y install emacs

echo '## nano'
sudo yum -y install nano

echo '## nkf'
sudo yum -y install nkf

echo '## openssh-clients'
sudo yum -y install openssh-clients

echo '## tmux'
if ! [ "`tmux -V | grep '2.3'`" ]; then
  mkdir -p ~/tmp
  cd ~/tmp
  sudo yum -y install ncurses-devel
  wget http://sourceforge.net/projects/levent/files/latest/download
  tar -xvf download
  cd libevent-2.0.22-stable/
  ./configure && make
  sudo make install
  sudo sh -c "echo '/usr/local/lib' > /etc/ld.so.conf.d/libevent.conf"
  sudo ldconfig
  sudo ln -sf /usr/local/lib/libevent-2.0.so.5 /usr/lib64/libevent-2.0.so.5

  cd ~/tmp
  wget https://github.com/tmux/tmux/releases/download/2.3/tmux-2.3.tar.gz
  tar -xvf tmux-2.3.tar.gz
  cd tmux-2.3
  ./configure LDFLAGS=-L/usr/local/lib/ && make
  sudo make install
fi
cd /var/www/kmh2016teamx/commands

echo '## vim'
sudo yum -y install vim-enhanced

echo '## zsh'
sudo yum -y install zsh
sudo usermod -s /bin/zsh vagrant
echo_if_not_exists 'export LANG=ja_JP.UTF-8' ~/.zshrc
echo_if_not_exists "alias kmh2016teamx='cd /var/www/kmh2016teamx'" ~/.zshrc


echo -e '\n\n'
echo '# apache 設定編'

echo '## passenger インストール'
sudo yum -y install apr-devel apr-util-devel
sudo chmod o+x /home/vagrant
if ! [ "`passenger-config --version | grep 'Phusion Passenger'`" ]; then
  gem install passenger --no-document
  rbenv rehash
  echo -e '\n\n以下のコマンドでは、言語を選ぶ所ではrubyのみを選択。あとは Enter でいい。\n\n'
  passenger-install-apache2-module
fi
# passenger-install-apache2-module --snippet > ./kmh2016teamx.conf
echo "" > ./kmh2016teamx.conf
sudo mv -f ./kmh2016teamx.conf /etc/httpd/conf.d/
if ! [ "`cat /etc/sysconfig/httpd | grep "export PATH=$HOME/.rbenv/shims:\\$PATH"`" ]; then
  sudo bash -c "echo 'export PATH=$HOME/.rbenv/shims:\$PATH' >> /etc/sysconfig/httpd"
fi

echo '## httpd.conf 関連の設定'
# 「AddHandler cgi-script .cgi」 の行のコメントを解除
sudo sed -i -e "s/^.*AddHandler cgi\-script \.cgi.*$/AddHandler cgi-script .cgi/g" /etc/httpd/conf/httpd.conf
# 「NameVirtualHost *:80」 の行のコメントを解除
sudo sed -i -e "s/^.*NameVirtualHost \*:80.*$/NameVirtualHost *:80/g" /etc/httpd/conf/httpd.conf
# /etc/httpd/conf.d/kmh2016teamx.conf の VirtualHost 設定を更新
# virtualhost_text='<VirtualHost *:80>
#     DocumentRoot /var/www/kmh2016teamx/public

#     <Directory /var/www/kmh2016teamx/public>
#         AllowOverride all
#         Options -MultiViews
#     </Directory>

#     ErrorLog /var/log/httpd/kmh2016teamx.error.log
#     CustomLog /var/log/httpd/kmh2016teamx.access.log combined

#     # environment を切り替える。デフォルトは production
#     RailsEnv test
# </VirtualHost>'
virtualhost_text=''
sudo sed -i "/<VirtualHost \*:80>/,/<\/VirtualHost>/c\\" /etc/httpd/conf.d/kmh2016teamx.conf
sudo bash -c "echo '$virtualhost_text' >> /etc/httpd/conf.d/kmh2016teamx.conf"


echo -e '\n\n'
echo '# その他設定編'

echo '## ファイアーウォール'

str_to_add='-A INPUT -p tcp -m tcp --dport 3000 -j ACCEPT'
if [ "`sudo cat /etc/sysconfig/iptables | grep -e "$str_to_add"`" != "$str_to_add" ]; then
  sudo sed -i -e "/ 22 /a -A INPUT -p tcp -m tcp --dport 3000 -j ACCEPT" /etc/sysconfig/iptables
  sudo service iptables restart
fi
str_to_add='-A INPUT -p tcp -m tcp --dport 80 -j ACCEPT'
if [ "`sudo cat /etc/sysconfig/iptables | grep -e "$str_to_add"`" != "$str_to_add" ]; then
  sudo sed -i -e "/ 22 /a -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT" /etc/sysconfig/iptables
  sudo service iptables restart
fi

echo '## 時刻設定'
if [ ! -e /etc/localtime.orig ]; then
  ### [【Linux】タイムゾーン(Timezone)の変更 - Qiita](http://qiita.com/azusanakano/items/b39bd22504313884a7c3)
  ### オリジナルをバックアップ
  sudo cp /etc/localtime /etc/localtime.orig
  ### タイムゾーンファイルの変更
  sudo ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
  sudo sh -c "echo -e 'ZONE=\"Asia/Tokyo\"\nUTC=false' > /etc/sysconfig/clock"
fi

source ~/.bash_profile

./check_env_sv.sh
