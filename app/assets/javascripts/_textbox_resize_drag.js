"use strict"

var TextboxResizeDrag = (function(options){

  return function(textbox, options){
    // Minimum Resizable area
    var minWidth = 50;
    var minHeight = 50;
  
    var isMicrosoftEdge = /Edge/.test(navigator.userAgent);
    // Thresholds
    var MARGINS = 10;
    var parentElement = options && options.parent ? options.parent : document;
  
    if (options){
      minWidth = options.width || minWidth;
      minHeight = options.height || minHeight;
      parentElement = options.parent || parentElement;
    }

    var clicked = null;
    var onRightEdge, onBottomEdge, onLeftEdge, onTopEdge, onBox;


    var box, x, y, move_event;

    var redraw = false;

    
    var parentLeftOffset = 0, parentTopOffset = 0;


    // Mouse Events
    textbox.addEventListener('mousedown', onMouseDown);
    document.addEventListener('mousemove', onMove);
    document.addEventListener('mouseup', onUp);

    // Touch Events
    textbox.addEventListener('touchstart', onTouchDown);
    document.addEventListener('touchmove', onTouchMove);
    document.addEventListener('touchend', onTouchEnd);


    function onTouchDown(event) {
      onDown(event.touches[0]);
      event.preventDefault();
    }

    function onTouchMove(event) {
      onMove(event.touches[0]);
    }

    function onTouchEnd(event) {
      if (event.touches.length === 0)
        onUp(event.changedTouches[0]);
    }

    function onMouseDown(event) {
      onDown(event);
    }

    // 
    // Enable resize on mouse moving over the square box
    // provided on the edges of the textbox
    //
    $('.square').on('mouseover', function(){
      onBox = true;
    }).on('mouseout', function(){
      onBox = false;
    });

    function onDown(event) {
      calc(event);
      var isResizing = (onRightEdge || onBottomEdge || onLeftEdge || onTopEdge) && onBox;
      var isMoving =  (onRightEdge || onBottomEdge || onLeftEdge || onTopEdge) && !onBox;
      clicked = {
        x: x,
        y: y,
        cx: event.clientX,
        cy: event.clientY,
        w: box.width,
        h: box.height,
        isResizing: isResizing,
        isMoving: isMoving,
        onTopEdge: onTopEdge,
        onLeftEdge: onLeftEdge,
        onRightEdge: onRightEdge,
        onBottomEdge: onBottomEdge
      };
      if (options && options.parent && (onTopEdge || onLeftEdge)){
         var parentBounds = options.parent.getBoundingClientRect();
         parentLeftOffset = parentBounds.left;
         parentTopOffset = parentBounds.top;
      }
    }

    function onMove(event) {
      calc(event);
      move_event = event;
      redraw = true;
    }

    function onUp(event) {
      if ( clicked && (clicked.isResizing || clicked.isMoving) ) {
        if (options && options.stop) {
          options.stop();
        }
      }
      clicked = null;
    }

    function calc(event) {
      box = textbox.getBoundingClientRect();
      x = event.clientX - box.left;
      y = event.clientY - box.top;
      var within_x = (event.clientX >= box.left - MARGINS/4 && event.clientX <= box.left + box.width + MARGINS/4);
      var within_y = (event.clientY >= box.top - MARGINS/4 && event.clientY <= box.top + box.height + MARGINS/4);

      onTopEdge = y < MARGINS && y > -MARGINS/4 && within_x; 
      onLeftEdge = x < MARGINS && x > -MARGINS/4 && within_y;
      onRightEdge = x > box.width - MARGINS && x < box.width + MARGINS/4 && within_y;
      onBottomEdge = y > box.height - MARGINS && y < box.height + MARGINS/4 && within_x;
    }

    function animate() {
      requestAnimationFrame(animate);
      if (!redraw) return;
      redraw = false
      if (clicked && clicked.isResizing) {
        if (clicked.onRightEdge) textbox.style.width = Math.max(x, minWidth) + 'px';
        if (clicked.onBottomEdge)  textbox.style.height = Math.max(y, minHeight) + 'px';
        if (clicked.onLeftEdge) {
          var currentWidth = Math.max(clicked.cx - move_event.clientX + clicked.w, minWidth);
          if (currentWidth > minWidth) {
            textbox.style.width = currentWidth + 'px';
            textbox.style.left = move_event.clientX - parentLeftOffset + 'px';
          }
        }
        if (clicked.onTopEdge) {
          var currentHeight = Math.max(clicked.cy - move_event.clientY + clicked.h, minHeight);
          if (currentHeight > minHeight) {
            textbox.style.height = currentHeight + 'px';
            textbox.style.top = move_event.clientY - parentTopOffset + 'px';
          }
	}
        return;
      }
      if (clicked && clicked.isMoving) {
        var bounds = $(textbox).position();
        textbox.style.left = (bounds.left + move_event.clientX - clicked.cx) + 'px';
        textbox.style.top = (bounds.top + move_event.clientY - clicked.cy) + 'px';
        clicked.cx = move_event.clientX;
        clicked.cy = move_event.clientY;
      }

      var cursorClasses = ['resize-left-diagonal', 'resize-right-diagonal', 'resize-horizontal', 'resize-vertical', 'move'];
      var cursorsString = cursorClasses.join(' ');
      // style cursor
      $(textbox).removeClass(cursorsString);
      if (onBox) {
        if (onRightEdge && onBottomEdge || onLeftEdge && onTopEdge){
          $(textbox).addClass(cursorClasses[0]);
        } else if (onRightEdge && onTopEdge || onBottomEdge && onLeftEdge) {
          $(textbox).addClass(cursorClasses[1]);
        } else if (onRightEdge || onLeftEdge) {
          $(textbox).addClass(cursorClasses[2]);
        } else if (onTopEdge || onBottomEdge) {
          $(textbox).addClass(cursorClasses[3]);
        }
      } else {
        if (onRightEdge || onTopEdge || onBottomEdge || onLeftEdge){
          $(textbox).addClass(cursorClasses[4]);
        }
      }
    }
    animate();
  }
})();

