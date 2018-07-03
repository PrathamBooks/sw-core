function init(original_width,large_width,large_height,selected_width,selected_height) {
  $('#cropbox').Jcrop({
    onChange: update_crop,
    onSelect: update_crop,
    setSelect: [0, 0, selected_width, selected_height],
    aspectRatio: selected_width/selected_height
  });

  function update_crop(coords) {
    var rx = selected_width/coords.w;
    var ry = selected_height/coords.h;
    $('#preview').css({
      width: Math.round(rx * large_width) + 'px',
      height: Math.round(ry * large_height) + 'px',
      marginLeft: '-' + Math.round(rx * coords.x) + 'px',
      marginTop: '-' + Math.round(ry * coords.y) + 'px'
    });
    var ratio = original_width/large_width;
    $("#crop_x").val(Math.round(coords.x * ratio));
    $("#crop_y").val(Math.round(coords.y * ratio));
    $("#crop_w").val(Math.round(coords.w * ratio));
    $("#crop_h").val(Math.round(coords.h * ratio));
  }
}

