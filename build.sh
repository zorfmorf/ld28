DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR
rm *.love
cd client
zip -r ../client.love *
cd ..
cd server
zip -r ../server.love *
