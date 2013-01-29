#setup of archlinux for deltamethod
export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
export LD_RUN_PATH=/usr/local/lib:$LD_RUN_PATH

#sudo apt-get -q -y install git
#sudo apt-get -q -y install python-dev
#sudo apt-get -q -y install python-pip
#sudo apt-get -q -y install indicator-cpufreq
#sudo apt-get -q -y install gfortran #restart afterwards and then choose mode "performance" for at least the ATLAS installation (it will fail otherwise)
pacman -S git python2 python2-pip gcc-gfortran
yaourt -S indicator-cpufreq-bzr r60-2
cd $USER/Downloads

# If I understood this all correctly, we only need to yaourt -S python2-pandas
# Which will install numpy, atlas, etc

# This is not needed anymore: pacman installs it alongside numpy
#wget http://www.netlib.org/lapack/lapack-3.4.2.tgz
#wget http://downloads.sourceforge.net/project/math-atlas/Developer%20%28unstable%29/3.11.4/atlas3.11.4.tar.bz2
#tar -vxf atlas3.11.4.tar.bz2
#mkdir atlas_build
#cd atlas_build
#../ATLAS/configure --with-netlib-lapack-tarfile=/home/$USER/Downloads/lapack-3.4.2.tgz --shared -b 64
#make
#sudo make install
#cd ..

########### hdf5 stuff
wget http://www.hdfgroup.org/ftp/lib-external/szip/2.1/src/szip-2.1.tar.gz
tar -vxf szip-2.1.tar.gz
cd szip-2.1
./configure
make
sudo make install
cd ..
##### now hdf5
sudo pacman -S hdf5

##yaml
sudo yaourt -S python2-yaml python2-pandas
sudo pip2 install pytz

###numpy
sudo pacman -S python2-numpy
sudo pip2 install scipy
sudo pip2 install numexpr
#lzo for tables
wget http://www.oberhumer.com/opensource/lzo/download/lzo-2.06.tar.gz
tar -vxf lzo-2.06.tar.gz
cd lzo-2.06
./configure --enable-shared
make
sudo make install
cd ..
sudo pip2 install tables
sudo pip2 install nose


sudo pip2 install IPython

sudo pip2 install ZSI
sudo pip2 install SOAPpy
wget https://google-api-ads-python.googlecode.com/files/adwords_api_python_15.5.0.tar.gz
tar -vxf adwords_api_python_15.5.0.tar.gz
cd adwords_api_python_15.5.0
sudo python setup.py install
cd ..
sudo pip2 install oauth2client # also installs httplib2, python-gflags  
sudo pip2 install requests

###ipython notebook stuff
wget http://download.zeromq.org/zeromq-3.2.2.tar.gz
tar -vxf zeromq-3.2.2.tar.gz
cd zeromq-3.2.2
#sudo apt-get -q -y install libtool autoconf automake
pacman -S libtool autoconf automake
./configure
make
sudo make install
sudo ldconfig
cd ..
sudo pip2 install pyzmq
sudo pip2 install pygments
sudo pip2 install tornado

wget http://downloads.sourceforge.net/project/libpng/libpng15/1.5.13/libpng-1.5.13.tar.gz
tar -vxf libpng-1.5.13.tar.gz
cd libpng-1.5.13
./configure
make
sudo make install
cd ..
wget http://downloads.sourceforge.net/project/freetype/freetype2/2.4.11/freetype-2.4.11.tar.gz
tar -vxf freetype-2.4.11.tar.gz
cd freetype-2.4.11
./configure
make
sudo make install
cd ..

wget https://github.com/downloads/matplotlib/matplotlib/matplotlib-1.2.0.tar.gz
tar -vxf matplotlib-1.2.0.tar.gz
cd matplotlib-1.2.0
python setup.py build
sudo python setup.py install
cd ..
