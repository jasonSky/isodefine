
#!/bin/sh
BUILD_PATH=`pwd`
Repo_PATH=`cat /mdmconfig/Daily/GitPath`
export JAVA_HOME="/usr/local/jdk18"
cd $Repo_PATH/AppServer
TEMPPATH="$HOME/yhl/allAppServer"
VERSION=`cat $BUILD_PATH/nqshell/tmpfile`
RPM_BUILD_PATH="$HOME/rpmbuild"
OUTPUTPATH="../build/output/Packages/"
rm -f /root/.m2/repository/com/netqin/mdm/thrift/5.2.0/*
if [ -d $TEMPPATH ]; then       
rm -rf $TEMPPATH/
fi

echo "`/usr/bin/git log -1 |grep commit`"> ./AppServer.txt
echo "Date: `date +%Y-%m-%d-%H-%M-%S`" >> ./AppServer.txt

mkdir -p $TEMPPATH/AppServer-$VERSION  
cp -rf ./* $TEMPPATH
cp -f $BUILD_PATH/AppServer/install.sh $BUILD_PATH/AppServer/AppServer $TEMPPATH

pushd $TEMPPATH/
/usr/local/maven/bin/mvn clean install
#cp -f ./target/AppServer.war AppServer.txt ./AppServer-$VERSION/
cp -rf ./target/lib ./target/sh ./target/start.sh ./target/log4j2.xml AppServer.txt ./AppServer-$VERSION/
cp -f ./target/AppServer.jar ./AppServer-$VERSION/lib/
mv install.sh AppServer ./AppServer-$VERSION/
chmod a+x ./AppServer-$VERSION/AppServer
chmod a+x ./AppServer-$VERSION/start.sh
tar zcvf AppServer.tar.gz AppServer-$VERSION
mv -f AppServer.tar.gz $RPM_BUILD_PATH/SOURCES/
popd

cd $BUILD_PATH

rm -rf $TEMPPATH
rm -f $Repo_PATH/AppServer/AppServer.txt
rpmbuild -bb AppServer.spec
mv $RPM_BUILD_PATH/RPMS/x86_64/AppServer* $OUTPUTPATH
rm -f /root/.m2/repository/com/netqin/mdm/thrift/5.2.0/*
