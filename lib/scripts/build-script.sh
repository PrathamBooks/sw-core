#!/bin/bash
bash -lc "if [ `wc  -l < /workdir/sw-core/config/locales/en.yml` != `wc  -l < /workdir/sw-core/config/locales/hi.yml` ];
then 
  exit 1 
else 
  echo 'successful localization' 
fi"


#Build and copy /workdir/sw-web app
bash -lc "rm -rf /workdir/sw-core/public/assets/js/*"
bash -lc "rm -rf /workdir/sw-core/public/assets/css/*"
bash -lc "python /workdir/sw-core/lib/scripts/localisations_check.py /workdir/sw-web/src/components/ jsx /workdir/sw-web/src/i18n/en.json"
bash -lc "python /workdir/sw-core/lib/scripts/localisations_check.py /workdir/sw-web/src/components/ jsx /workdir/sw-web/src/i18n/hi.json"

cd /workdir/sw-web
bash -lc "if [ `wc  -l < /workdir/sw-web/src/i18n/en.json` != `wc  -l < /workdir/sw-web/src/i18n/hi.json` ];
then 
  exit 1 
else 
  echo 'successful localization' 
fi"
bash -lc "yarn -v"
bash -lc "yarn install"
bash -lc "REACT_APP_FEATURE_AUTH=true REACT_APP_SHOW_WHITELABEL_ATTRIBUTION=true REACT_APP_EXPANDED_SEARCH_PEOPLE_TAB=true REACT_APP_FEATURE_ILLUSTRATIONS=true REACT_APP_FEATURE_OFFLINE=true REACT_APP_API_URL=http://localhost:3000/api/v1 yarn build"
cd
cp -r /workdir/sw-web/build/assets /workdir/sw-core/public/.
cp /workdir/sw-web/build/*.js /workdir/sw-core/public/.
cp /workdir/sw-web/build/*.json /workdir/sw-core/public/.
cp /workdir/sw-web/build/*.png /workdir/sw-core/public/.

cp /workdir/sw-web/build/*.jpg /workdir/sw-core/public/.
cp /workdir/sw-web/build/index.html /workdir/sw-core/public/.
cp /workdir/sw-web/build/index.html /workdir/sw-core/app/views/react/.

cp /workdir/sw-web/build/index.css /workdir/sw-core/public/
cp /workdir/sw-web/build/index.js /workdir/sw-core/public/


#meta-tag public index changes
sed -i -e 's/$DESCRIPTION/StoryWeaver/g' /workdir/sw-core/public/index.html
sed -i -e 's/$OG_TITLE/StoryWeaver/g' /workdir/sw-core/public/index.html
sed -i -e 's/$OG_URL/https\:\/\/storyweaver.org\.in/g' /workdir/sw-core/public/index.html
sed -i -e 's/$OG_DESCRIPTION/StoryWeaver/g' /workdir/sw-core/public/index.html
sed -i -e 's/$OG_IMAGE/https\:\/\/storyweaver\.org\.in\/assets\/pb-storyweaver\-logo\-01\-4acd9848be4ca29481825c4b23848b97\.svg/g' public/index.html

#meta-tag changes
mv app/views//workdir/sw-web/index.html /workdir/sw-core/app/views/react/index.html.erb
sed -i -e 's/$DESCRIPTION/<%= @description %>/g' /workdir/sw-core/app/views/react/index.html.erb
sed -i -e 's/$OG_TITLE/<%= @title %>/g' /workdir/sw-core/app/views/react/index.html.erb
sed -i -e 's/$OG_URL/<%= @url %>/g' /workdir/sw-core/app/views/react/index.html.erb
sed -i -e 's/$OG_DESCRIPTION/<%= @description %>/g' /workdir/sw-core/app/views/react/index.html.erb
sed -i -e 's/$OG_IMAGE/<%= @image %>/g' /workdir/sw-core/app/views/react/index.html.erb
sed -i -e 's/$OG_TYPE/<%= @type %>/g' /workdir/sw-core/app/views/react/index.html.erb
sed -i -e 's/$OG_BOOK_URL/<%= @book_url %>/g' /workdir/sw-core/app/views/react/index.html.erb
sed -i -e 's/$OG_BOOK_RELEASE_DATE/<%= @release_date %>/g' /workdir/sw-core/app/views/react/index.html.erb
sed -i -e 's/$OG_BOOK_TAGS/<%= @book_tags %>/g' /workdir/sw-core/app/views/react/index.html.erb

#Build and copy /workdir/sw-web header/footer for server pages
cd /workdir/sw-web
bash -lc "REACT_APP_FEATURE_AUTH=true REACT_APP_SHOW_WHITELABEL_ATTRIBUTION=true REACT_APP_EXPANDED_SEARCH_PEOPLE_TAB=true REACT_APP_FEATURE_ILLUSTRATIONS=true REACT_APP_FEATURE_OFFLINE=true REACT_APP_API_URL=http://localhost:3000/api/v1 yarn build-bookends"

cp -r /workdir/sw-web/build/assets /workdir/sw-core/public/.
# cp /workdir/sw-web/build/assets/js/*.js public/assets/js/.
# cp /workdir/sw-web/build/assets/css/bookends.*.css public/assets/css/.
# cp -r /workdir/sw-web/build/assets/media public/assets/.

bash -lc "RAILS_ROOT=/workdir/sw-core/ SW_BUILD_DIR=/workdir/sw-web/build /workdir/sw-core/lib/scripts/add_react_version.sh"

