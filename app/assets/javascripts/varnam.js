function VarnamIME(element,toolbar,language,serverUrl){

  if (!$(element).length){
    return;
  }
  serverUrl = typeof serverUrl !== 'undefined' ? serverUrl : "http://localhost:8080/" ;
  var enabled = true,
      oldValue="",
      suggestionDivId = "varnam_ime_suggestions",
      suggestionDiv = "#" + suggestionDivId,
      suggestionList = suggestionDiv + ' ul',
      suggestedItem = suggestionDiv + suggestionList + ' option',
      closeButtonId = 'varnam_suggestions_close',
      closeButton = '#' + closeButtonId,
      previousWord = "",
      currentWord = "",
      gRange,

      KEYS = {
        ESCAPE: 27,
        ENTER: 13,
        TAB: 9,
        SPACE: 32,
        PERIOD: 190,
        UP_ARROW: 38,
        DOWN_ARROW: 40,
        QUESTION: 191,
        EXCLAMATION: 49,
        COMMA: 188,
        LEFT_BRACKET: 57,
        RIGHT_BRACKET: 48,
        QUOTE: 222,
        SEMICOLON: 59
      },
      WORD_BREAK_CHARS = [KEYS.ENTER, KEYS.TAB, KEYS.SPACE, KEYS.PERIOD, KEYS.QUESTION, KEYS.EXCLAMATION, KEYS.COMMA, KEYS.LEFT_BRACKET, KEYS.RIGHT_BRACKET, KEYS.SEMICOLON, KEYS.QUOTE],
      skipTextChange = false,
      activeElement = null;

  var suggestionUrlFor = function(text) {
    return serverUrl.concat("tl/").concat(language.code).concat("/").concat(text);
  }

  function createSuggestionsDiv() {
    if ($(suggestionDiv).length <= 0) {
      var divHtml = '<div id="' + suggestionDivId + '" style="display: none;"><ul></ul></div>';

      $("body").append(divHtml);
      // $(closeButton).on('click', hidePopup);
    }
  } 

  var transliterate=function(word){
    $.ajax({
      url: suggestionUrlFor(word),
      type: 'GET',
      crossDomain: true,
      success: function(data) {
        //Removing the suggestion which is already the same as input
        if (data.result.indexOf(data.input) !== -1) {
          data.result.splice(data.input, 1)
        }
        displaySugg(data);         
      },
      error: function() { console.log("transliteration failed !"); }
    });
  }

  var displaySugg = function(data) {
    var active = element;
    if (active && getWordUnderCaret(active).word == data.input && data.result.length > 0) {
      populateSuggestions(data);
      positionPopup(active);
    }else{
      hidePopup();
    }
  }

  var populateSuggestions = function(data){
    var html = "";
    if (data.result.length <= 0) {
      hidePopup();
      return;
    }
    $.each(data.result, function(index, value) {
      if (index === 0) {
        html += '<li class="varnam_selected">' + value + '</li>';
      } else {
        html += '<li>' + value + '</li>';
      }
    });
    $(suggestionList).html(html);
    $(suggestionList + ' li').off('click', suggestedItemClicked);
    $(suggestionList + ' li').on('click', suggestedItemClicked);
  }

  var suggestedItemClicked =function(event) {
    event.stopPropagation();
    event.preventDefault();
    var text = $(this).text();
    replaceWordUnderCaret(text);
  }

  var createToolbar = function(withLanguage){
    var textElement, buttonGroup;

    if ($('#varnam-menu-group').length !== 0){
      buttonGroup = $('#varnam-menu-group');
    }else{
      buttonGroup = $("<div class='dropdown' id='varnam-menu-group'/>");
    }		
    var ulElement = $("<ul class='dropdown-menu' />");
    if (withLanguage){
      textElement = $("<a class='btn btn-sm btn-default dropdown-toggle btn-richtext-font-trigger' data-toggle='dropdown' href='#' id='varnam-toggle'><span class='current-language'>"+language.name+"</span>&nbsp;<b class='caret'></b></a>");
      $(ulElement).append("<li class='varnam-menu' data-varnam-language='" +language.code+"'><a>"+ language.name +"</a></li>");
      $(toolbar)
        .append("<p class='font-sm text-bold'>Choose keyboard</p>")
        .append($(buttonGroup)
        .append(textElement,ulElement))
        .addClass('non-english-script');

      $(ulElement).append("<li class='varnam-menu' data-varnam-language='en'><a >Keyboard</a></li>");
    }

    $('li.varnam-menu').click(function(){
      $('#varnam-toggle').html($(this).text() + " <span class='caret'></span>");
      var langCode = $(this).data('varnam-language');
      if (langCode === 'en'){
        disableVarnam();
      }else{
        enableVarnam();
      }
    });
  }


  var hidePopup = function(){
    $(suggestionDiv).hide();
  }

  var showProgress = function(){
    var html = '<li>Loading...</li>';
    $(suggestionList).html(html);
    positionPopup(element);
  }


  var handleSelectionOnSuggestionList = function(e){
    if (!$(suggestionDiv + " li").is(':visible')){
      return;
    }
    $(suggestionList).focus();

    var selectedItem = $("li.varnam_selected").first();
    $(selectedItem).removeClass('varnam_selected');
    var nextSelection = null;

    if (e.keyCode == KEYS.UP_ARROW) {
      if (selectedItem.prev().length === 0) {
        nextSelection = selectedItem.siblings().last();
      } else {
        nextSelection = selectedItem.prev();
      }
    }
    if (e.keyCode == KEYS.DOWN_ARROW) {
      if (selectedItem.next().length === 0) {
        nextSelection = selectedItem.siblings().first();
      } else {
        nextSelection = selectedItem.next();
      }
    }
    $(nextSelection).addClass("varnam_selected");
    e.stopPropagation();
    e.preventDefault();
  }

  var isSuggestionsVisible = function() {
    return $(suggestionDiv).is(':visible');
  }

  var getElementValue=function(){
    if(!$(element).attr("contenteditable") == true){
      return $(element).val();
    }
    else{
      return $(element).html();
    }
  }

  var hasTextChanged = function() {
    var newValue = getElementValue();
    if (oldValue != newValue) {
      oldValue=newValue;
      return true;
    }
    return false;
  }

  var showSuggestions = function(e){
    var event = $.event.fix(e);
    activeElement = event.target;
    prevWord = currentWord;
    currentWord = getWordUnderCaret(activeElement).word;
    if (event.keyCode == KEYS.ESCAPE) {
      event.preventDefault();
      event.stopPropagation();
      return;
    }
    var wordUnderCaret = getWordUnderCaret(element);
    if ($.trim(wordUnderCaret.word) !== '') {
      if (hasTextChanged() && ! skipTextChange) {
        showProgress();
        var text = wordUnderCaret.word;
        transliterate(text);
      } else if (currentWord != prevWord) {
      	  hidePopup();
      }
    } else {
      hidePopup();
    }
  }


  var getCursorPos = function(input) {
    if(!$(input).attr("contenteditable") == true){
      if ("selectionStart" in input && document.activeElement == input) {
        return {
          start: input.selectionStart,
          end: input.selectionEnd
        };
      }
      else if (input.createTextRange) {
        var sel = document.selection.createRange();
        if (sel.parentElement() === input) {
          var rng = input.createTextRange();
          rng.moveToBookmark(sel.getBookmark());
          for (var len = 0;
              rng.compareEndPoints("EndToStart", rng) > 0;
              rng.moveEnd("character", -1)) {
                len++;
              }
          rng.setEndPoint("StartToStart", input.createTextRange());
          for (var pos = { start: 0, end: len };
              rng.compareEndPoints("EndToStart", rng) > 0;
              rng.moveEnd("character", -1)) {
                pos.start++;
                pos.end++;
              }
          return pos;
        }
      }
      return -1;
    }else{
      var sel, word = "", rect;
      if (window.getSelection && (sel = window.getSelection()).modify) {
        var selectedRange = sel.getRangeAt(0);

        rect=selectedRange.getClientRects();
        sel.addRange(selectedRange);
      } else if ( (sel = document.selection) && sel.type != "Control") {
        var range = sel.createRange();
        range.collapse(true);
        range.expand("word");
        rect=range.getClientRects();

      }
      return rect;
    }
  }

  var positionPopup = function(editor) {
    if(!$(editor).attr("contenteditable") == true){
      var pos = getWordBeginingPosition(editor);
      var rects = element.getClientRects();
      if (rects.length > 0) {
        var rect = rects[0];
        var scrollTop = document.documentElement.scrollTop || document.body.scrollTop;
        var scrollLeft = document.documentElement.scrollLeft || document.body.scrollLeft;
        var height = $(window).height() - $(suggestionDiv).height();
        var topPos = rect.top + pos.top + 25;
        if (height < topPos) {
          topPos = topPos - $(suggestionDiv).height() - 40;
        }

        var viewportWidth = $(window).width();
        var calculatedLeft = rect.left + scrollLeft + pos.left;
        var suggestionDivsRight = calculatedLeft + $(suggestionDiv).width();
        if (suggestionDivsRight > viewportWidth) {
          // Right side of suggestion list is going off the screen
          var diff = suggestionDivsRight - viewportWidth;
          calculatedLeft = calculatedLeft - diff - 10;
        }

        $(suggestionDiv).css({
          display: 'block',
          position: 'absolute',
          top: topPos + scrollTop + 'px',
          left: calculatedLeft + 'px',
          'z-index': '5000000'
        });
      }
    } else {
      var rect = getCursorPos(editor);
      if (rect == -1){
        hidePopup();
        return;
      }
      if(rect[0]=== undefined){
        hidePopup();
        return;
      }
      var scrollTop = document.documentElement.scrollTop || document.body.scrollTop;
      var scrollLeft = document.documentElement.scrollLeft || document.body.scrollLeft;
      $(suggestionDiv).css({
        display: 'block',
        position: 'absolute',
        top: (rect[0].bottom + scrollTop )+ 'px',
        left: rect[0].right + 'px',
        'z-index': '25000'
      });
    }
  }

  var getWordBeginingPosition = function(editor) {
		// This is required to set the selection back
		$(editor).focus();
		var prev = $(editor).getSelection();

		// Moving the cursor to the beginning of the word.
		var word = getWordUnderCaret(editor);
		$(editor).setSelection(word.start, word.end);
		var pos = $(editor).caret('position');

		// Moving the cursor back to the old position
		if (prev) {
			$(editor).setSelection(prev.start, prev.end);
		}
		return pos;
	}

  var isWordBoundary = function(text) {
    if (text === null || text === "" || text == " " || text == "\n" || text == "." || text == "\t" || text == "\r" || text == "\"" || text == "'" || text == "?" || text == "!" || text == "," || text == "(" || text == ")" || text == "\u000B" || text == "\u000C" || text == "\u0085" || text == "\u2028" || text == "\u2029" || text == "\u000D" || text == "\u000A" || text == ";") {
      return true;
    }
    return false;
  }

  var isWordBreakKey = function(keyCode) {
    var exists = $.inArray(keyCode, WORD_BREAK_CHARS) == - 1 ? false: true;
    if (exists) {
      return true;
    }
    return false;
  }


  var processKeyEvent = function(e) {
    var event = $.event.fix(e);
    activeElement = event.target;

    if (event.keyCode == KEYS.ESCAPE) {
      hidePopup();
      event.preventDefault();
      event.stopPropagation();
      return;
    }
    skipTextChange = false;
    if (event.keyCode == KEYS.DOWN_ARROW || event.keyCode == KEYS.UP_ARROW) {
      handleSelectionOnSuggestionList(event);
    }
    if (isSuggestionsVisible()) {
      if (isWordBreakKey(event.keyCode)) {
        var word = $("li.varnam_selected").first().text();
        if (word !== undefined && $.trim(word) !== '') {
          replaceWordUnderCaret(word);
          if (event.keyCode == KEYS.ENTER) {
            event.preventDefault();
            event.stopPropagation();
          }
        }
        skipTextChange = true;
      }
    } else if (isWordBreakKey(event.keyCode)) {                                                                                           
      skipTextChange = true;
    }
  }

  var replaceWordUnderCaret = function(text) {
    var editor = $(element);
    if(!$(editor).attr("contenteditable") == true){
      var w = getWordUnderCaret(element);
      $(editor).setSelection(w.start, w.end);
      $(editor).replaceSelectedText(text);
    }else if (window.getSelection()) {
        // Saving the caret position in the previous keypress and using it here (gRange).
        var mySel = window.getSelection();
        var range = gRange;
        range.deleteContents();
        var txtNode = document.createTextNode(text);
        range.insertNode(txtNode);
        range.setStartAfter(txtNode);
        mySel.removeAllRanges(); 
        mySel.addRange(range);      
    }
    hidePopup();
    learnWord(text);
  }


  var varnamLearnUrl = function() {
    return serverUrl.concat('learn');
  }

  var learnWord = function(text) {
    var params = {
      'lang': language.code,
      'text': text
    };

    var xhr = new XMLHttpRequest();
    xhr.open("POST", varnamLearnUrl(), true);
    xhr.setRequestHeader('Content-type','text/plain; charset=utf-8');
    xhr.send('{"lang":"'+language.code+'","text": "'+text+'"}');
  }

    // Returns a range and textnode containing object from caret position covering a whole word
  // wordOffsety describes the original position of caret in the new textNode 
  // Caret has to be inside a textNode.
  function getRangeForWord(selection) {
    var anchor, offset, doc, range, offsetStart, offsetEnd, beforeChar, afterChar,
        txtNodes = [];
    if (selection) {
      anchor = selection.anchorNode;
      offset = offsetStart = offsetEnd = selection.anchorOffset;
      doc = anchor.ownerDocument;
      range = rangy.createRange(doc);

      if (anchor && anchor.nodeType === 3) {

        while (offsetStart > 0 && (/[^!\s?,".;()\[\]\{\}~]/).test(anchor.data[offsetStart - 1])) {
          offsetStart--;
        }

        while (offsetEnd < anchor.data.length && (/[^!\s?,".;()\[\]\{\}~]/).test(anchor.data[offsetEnd])) {
          offsetEnd++;
        }

        range.setStartAndEnd(anchor, offsetStart, offsetEnd);

        return {
          range: range
        };

      }
    }
    return false;
  }

  var getWordUnderCaret = function(editor) {
    if(!$(editor).attr("contenteditable") == true){
      var insertionPoint = editor.selectionStart;
      var startAt = 0;
      var endsAt = 0;
      var lastPosition = editor.value.length + 1;
      var text = '';

      // Moving back till we hit a word boundary
      var caretPos = insertionPoint;
      startAt = insertionPoint;
      while (caretPos) {
        text = editor.value.substring(caretPos - 1, caretPos);
        if (isWordBoundary(text)) {
          break;
        }--caretPos;
        startAt = caretPos;
      }

      endsAt = insertionPoint;
      caretPos = insertionPoint;
      while (caretPos < lastPosition) {
        text = editor.value.substring(caretPos, caretPos + 1);
        if (isWordBoundary(text)) {
          break;
        }++caretPos;
        endsAt = caretPos;
      }

      return {
        start: startAt,
          end: endsAt,
          word: editor.value.substring(startAt, endsAt)
      };
    }else{
      var sel, word = "", startAt, endAt;
      if (window.getSelection && (sel = window.getSelection()).modify) {
        var selectedRange = sel.getRangeAt(0);
        sel.collapseToStart();
        //sel.modify("extend", "backward", "word");
        //sel.modify("extend", "forward", "word");
        var wordInfo = getRangeForWord(sel);

        if(wordInfo.range){
          word = wordInfo.range.toString();        
          startAt = wordInfo.range.startOffset;
          end = wordInfo.range.endOffset;
          gRange = wordInfo.range.nativeRange;
        }
        // Restore selection
        sel.removeAllRanges();
        sel.addRange(selectedRange);
      } else if ( (sel = document.selection) && sel.type != "Control") {
        var range = sel.createRange();
        range.collapse(true);
        range.expand("word");
        word = range.text;
        startAt = sel.startOffset;
        end = sel.endOffset;
      }
      return {
        start: startAt,
          end: endAt,
          word: word
      };
    }
  }

  var languagesUrl = function() {
    return serverUrl.concat("languages");
  }

  var getLanguageDetails = function(callback){
    $.ajax({
      url: languagesUrl(),
      type: 'GET',
      crossDomain: true,
      success: function(data) { 
        var success = false;
        $.each(data,function(index, value){
          if(value.DisplayName === language.name){
            success = true;
            language.code=value.LangCode;
            callback();
            return;
          }
        });
      },
      error: function() { 
        console.error("varnam initialization failed !"); 
      }
    });
  };

  var getLanguageDetailsAndCreateToolbar = function(callback){
    $.ajax({
      url: languagesUrl(),
      type: 'GET',
      crossDomain: true,
      success: function(data) { 
        var success = false;
        $.each(data,function(index, value){
          if(value.DisplayName === language.name){
            success = true;
            language.code=value.LangCode;
            callback();
            return;
          }
        });
        if(!success){
          createToolbar(false);
        }
      },
      error: function() { 
        createToolbar(false);
        console.error("varnam initialization failed !"); 
      }
    });
  };

  var enableVarnam = function(){
    $(element).on('keydown', processKeyEvent); 
    $(element).on('keyup', showSuggestions); 
  }

  var disableVarnam = function(){
    $(element).off('keydown', processKeyEvent); 
    $(element).off('keyup', showSuggestions); 
  }

  var initForWsyiEditor = function(){
    getLanguageDetailsAndCreateToolbar(function(){
      createToolbar(true);
      createSuggestionsDiv();
      hidePopup();
      enableVarnam();
      oldValue=getElementValue();
    });
  };	

  var init = function(){
    getLanguageDetails(function(){
      createSuggestionsDiv();
      hidePopup();
      enableVarnam();
      oldValue=getElementValue();
    });
  };

  return {
    initForWsyiEditor: initForWsyiEditor,
      init: init
  }
}
