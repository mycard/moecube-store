sudo zypper mr -e susecloud:SLE11-SDK-SP3-Pool
sudo zypper mr -e susecloud:SLE11-SDK-SP3-Updates

sudo zypper addrepo http://download.opensuse.org/repositories/devel:languages:nodejs/SLE_11_SP3/devel:languages:nodejs.repo
sudo zypper addrepo http://download.opensuse.org/repositories/devel:tools:building/SLE_11_SP3/devel:tools:building.repo
sudo zypper addrepo http://download.opensuse.org/repositories/games/SLE_11_SP3/games.repo
sudo zypper addrepo http://download.opensuse.org/repositories/home:kukuk:sles/SLE_11_SP3/home:kukuk:sles.repo
sudo zypper addrepo http://download.opensuse.org/repositories/home:draht/SLE_11_SP3_Update/home:draht.repo
sudo zypper addrepo http://download.opensuse.org/repositories/home:PerryWerneck/SLE_11_SP3/home:PerryWerneck.repo

sudo zypper --gpg-auto-import-keys --non-interactive install gcc47 gcc47-c++ git premake4 freetype2-devel readline-devel sqlite3-devel p7zip glu-devel irrlicht-devel libevent-devel nodejs nodejs-devel

wget http://www.lua.org/ftp/lua-5.2.3.tar.gz
tar vfx lua-5.2.3.tar.gz
cd lua-5.2.3
make linux -j2 CC=gcc-4.7
sudo make install

cd ..
git clone https://github.com/mycard/ygopro.git -b server
cd ygopro/
premake4 gmake
cd build/

make config=release ygopro -j2 CXX=g++-4.7 CC=gcc-4.7
cd ..
ln -s bin/release/ygopro ./
strip ygopro
cd ..

#ygopro lastest data
wget --no-check-certificate --user-agent="Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/31.0.1650.63 Safari/537.36" https://my-card.in/mycard/download -O mycard.7z
7za x mycard.7z mycard-$mycard_version/ygocore -y
yes | cp -rf mycard-$mycard_version/ygocore/* ygopro/
rm -rf mycard-$mycard_version mycard.7z

#ygopro-server
git clone https://github.com/mycard/ygopro-server.git
cd ygopro-server
npm install
sudo npm install -g coffee-script forever bunyan
ln -s ../ygopro ygocore