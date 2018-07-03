cd $SW_BUILD_DIR/assets/css
css="$(ls *.css | tr -d '\n')"
cd $SW_BUILD_DIR/assets/js
vjs="$(ls vendor*.js | tr -d '\n')"
ajs="$(ls bookends*.js | tr -d '\n')"
cd $RAILS_ROOT
sed "s/bookends.*css/$css/" < app/views/layouts/_fluid.html.erb > /tmp/xx
sed "s/vendor.*js/$vjs/" < /tmp/xx > /tmp/yy
sed "s/bookends.*js/$ajs/" < /tmp/yy > /tmp/zz
cp /tmp/zz app/views/layouts/_fluid.html.erb
sed "s/bookends.*css/$css/" < app/views/layouts/application.html.erb > /tmp/xx
sed "s/vendor.*js/$vjs/" < /tmp/xx > /tmp/yy
sed "s/bookends.*js/$ajs/" < /tmp/yy > /tmp/zz
cp /tmp/zz app/views/layouts/application.html.erb
sed "s/bookends.*css/$css/" < app/views/layouts/editor.html.erb > /tmp/xx
sed "s/vendor.*js/$vjs/" < /tmp/xx > /tmp/yy
sed "s/bookends.*js/$ajs/" < /tmp/yy > /tmp/zz
cp /tmp/zz app/views/layouts/editor.html.erb

