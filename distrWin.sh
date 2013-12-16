DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR 
if [ ! -f distr ]
then
    mkdir distr
fi
cd distr
rm chatboxclient_x64.zip
rm chatboxclient_x32.zip
rm chatboxserver_x64.zip
rm chatboxserver_x32.zip
if [ ! -f love-0.9.0-win-x64.zip ]
then
    wget https://bitbucket.org/rude/love/downloads/love-0.9.0-win32.zip
    wget https://bitbucket.org/rude/love/downloads/love-0.9.0-win64.zip
fi
unzip -j "*win64.zip" -d x64
unzip -j "*win32.zip" -d x32
cat x64/love.exe ../client.love > x64/chatboxclient_x64.exe
cat x32/love.exe ../client.love > x32/chatboxclient_x32.exe
cd x64
zip -r ../chatboxclient_x64.zip *
cd ..
cd x32
zip -r ../chatboxclient_x32.zip *
cd ..
rm -rf x32
rm -rf x64

unzip -j "*win64.zip" -d x64
unzip -j "*win32.zip" -d x32
cat x64/love.exe ../server.love > x64/chatboxserver_x64.exe
cat x32/love.exe ../server.love > x32/chatboxserver_x32.exe
cd x64
zip -r ../chatboxserver_x64.zip *
cd ..
cd x32
zip -r ../chatboxserver_x32.zip *
cd ..
rm -rf x32
rm -rf x64

rm -rf love*
