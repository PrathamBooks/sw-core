#! /usr/bin/env bash
echo "________________________________________________________________"
echo "________________Moving to React Folder__________________________"
echo "________________________________________________________________"
cd $REACT_PATH
echo "________________________________________________________________"
echo "________________Updating the code to the latest_________________"
echo "________________________________________________________________"
[ -z "$BRANCH" ] && BRANCH=development
git pull origin $BRANCH
echo "________________________________________________________________"
echo "________________Doing yarn install_______________________________"
echo "________________________________________________________________"
yarn install
echo "________________________________________________________________"
echo "________________Running yarn build___________________________"
echo "________________________________________________________________"
REACT_APP_API_URL=http://localhost:3000/api/v1 yarn build
echo "________________________________________________________________"
echo "_______________ Copying the index.html file_____________________"
echo "________________________________________________________________"
cp $REACT_PATH/build/index.html $RAILS_PATH/app/views/react/
cp $REACT_PATH/build/index.html $RAILS_PATH/public/
echo "________________________________________________________________"
echo "________________Moving assets folder____________________________"
echo "________________________________________________________________"
cp -r $REACT_PATH/build/assets/* $RAILS_PATH/public/assets/
echo "________________________________________________________________"
echo "________________Running build-bookends__________________________"
echo "________________________________________________________________"
REACT_APP_API_URL=http://localhost:3000/api/v1 yarn build-bookends
echo "________________________________________________________________"
echo "________________Moving assets again_____________________________"
echo "________________________________________________________________"
cp -r $REACT_PATH/build/assets/* $RAILS_PATH/public/assets/
echo "________________________________________________________________"
echo "_______________Running add_react_version script_________________"
echo "________________________________________________________________"
SW_BUILD_DIR=$REACT_PATH/build RAILS_ROOT=$RAILS_PATH $RAILS_PATH/lib/scripts/add_react_version.sh
cp $REACT_PATH/src/service-worker.js $RAILS_PATH/public/
