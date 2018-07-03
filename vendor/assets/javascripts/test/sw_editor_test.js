// Tests for sw editor code.
if (wysihtml.browser.supported()) {
  module("sw_wysihtml.Editor", {
    setup: function() {
      wysihtml.dom.insertCSS([
        "#wysihtml-test-textarea { width: 50%; height: 100px; margin-top: 5px; font-style: italic; border: 2px solid red; border-radius: 2px; }",
        "#wysihtml-test-textarea:focus { margin-top: 10px; }",
        "#wysihtml-test-textarea:disabled { margin-top: 20px; }"
      ]).into(document);

      this.textareaElement        = document.createElement("textarea");
      this.textareaElement.id     = "wysihtml-test-textarea";
      this.textareaElement.title  = "Please enter your foo";
      this.textareaElement.value  = "hey tiff, what's up?";

      this.form = document.createElement("form");
      this.form.onsubmit = function() { return false; };
      this.form.appendChild(this.textareaElement);

      this.originalBodyClassName = document.body.className;

      this.rules = {
        parserRules : {
            classes: {
                "text-font-normal": 1,
                "text-font-largest": 1,
                "text-font-large": 1,
                "text-font-medium": 1,
                "text-font-small": 1,
                "text-font-smallest": 1,
                "wysiwyg-text-align-right": 1,
                "wysiwyg-text-align-center": 1,
                "wysiwyg-text-align-left": 1,
                "wysiwyg-text-align-justify": 1,
                "wysiwyg-float-left": 1,
                "wysiwyg-float-right": 1,
                "wysiwyg-clear-right": 1,
                "wysiwyg-clear-left": 1,
                "wysiwyg-color-silver" : 1,
                "wysiwyg-color-gray" : 1,
                "wysiwyg-color-white" : 1,
                "wysiwyg-color-maroon" : 1,
                "wysiwyg-color-red" : 1,
                "wysiwyg-color-purple" : 1,
                "wysiwyg-color-fuchsia" : 1,
                "wysiwyg-color-green" : 1,
                "wysiwyg-color-lime" : 1,
                "wysiwyg-color-olive" : 1,
                "wysiwyg-color-yellow" : 1,
                "wysiwyg-color-navy" : 1,
                "wysiwyg-color-blue" : 1,
                "wysiwyg-color-teal" : 1,
                "wysiwyg-color-aqua" : 1,
                "wysiwyg-color-orange" : 1,
                "embed-responsive": 1,
                "embed-responsive-16by9": 1,
                "embed-responsive-item": 1,
                "img-responsive": 1
            },
            classes_blacklist: {
                "Apple-interchange-newline": 1,
                "MsoNormal": 1,
                "MsoPlainText": 1
            },
            tags: {
                "span": {},
                "b":  {},
                "i":  {},
                "br": {},
                "ol": {"unwrap":1},
                "ul": {"unwrap":1},
                "li": {"unwrap":1},
                "h1": {"unwrap":1},
                "h2": {"unwrap":1},
                "h3": {"unwrap":1},
                "h4": {"unwrap":1},
                "h5": {"unwrap":1},
                "h6": {"unwrap":1},
                "sub": {},
                "sup": {},
                "blockquote": {"unwrap":1},
                "u": 1,
                "img": {"remove": 1},
                "a":  { "unwrap":1},
                "iframe": {"remove":1},
                "p": {},
                "div": {"rename_tag": "p"},
                "table": {"unwrap":1},
                "tbody": {"unwrap":1},
                "thead": {"unwrap":1},
                "tfoot": {"unwrap":1},
                "tr": {"unwrap":1},
                "th": {"unwrap":1},
                "td": {"unwrap":1},
                // to allow save and edit files with code tag hacks
                "code": {"unwrap":1},
                "pre": {"unwrap":1},
                "style": {"remove":1}
            }
        }
      }

      document.body.appendChild(this.form);
    },

    setCaretTo: function(editor, el, offset) {
        var r1 = editor.composer.selection.createRange();

        r1.setEnd(el, offset);
        r1.setStart(el, offset);
        editor.composer.selection.setSelection(r1);
    },

    setSelection: function(editor, el, offset, el2, offset2) {
      var r1 = editor.composer.selection.createRange();
      r1.setEnd(el2, offset2);
      r1.setStart(el, offset);
      editor.composer.selection.setSelection(r1);
    },

    teardown: function() {
      var leftover;
      while (leftover = document.querySelector("iframe.wysihtml-sandbox, input[name='_wysihtml_mode']")) {
        leftover.parentNode.removeChild(leftover);
      }
      this.form.parentNode.removeChild(this.form);
      document.body.className = this.originalBodyClassName;
    },

    getComposerElement: function() {
      return this.getIframeElement().contentWindow.document.body;
    },

    getIframeElement: function() {
      var iframes = document.querySelectorAll("iframe.wysihtml-sandbox");
      return iframes[iframes.length - 1];
    },

    ruleChecks: function(elem) {

      var childNodes = elem.childNodes;

      for (var i=0; i< childNodes.length; i++){
        if (childNodes[i].nodeName !== 'P'){
          return false;
        }
        var innerNodes = childNodes[i].childNodes;
        for (var j=0; j<innerNodes.length; j++){
          if(innerNodes[j].nodeName !== 'SPAN'){
            return false;
          }
        }
      }
      return true;
    }

  });

  asyncTest("copyPaste editor._cleanAndPaste command", function() {
    expect(2);
    var that=this;

    var input   = "<p><span class=\"text-font-normal\">hello  world</span></p>",
        cPaste   = "<span>pasted</span>",
        output  = "<p><span class=\"text-font-normal\">hello pasted world</span></p>";

    var editor = new wysihtml.Editor(this.textareaElement, this.parserRules);

    editor.on("load", function() {
      editor.setValue(input, false);
      var el = editor.composer.element.getElementsByClassName("text-font-normal");
      var r1 = editor.composer.selection.createRange();

      r1.nativeRange.setStart(el[0].firstChild, 6);
      r1.nativeRange.setEnd(el[0].firstChild, 6);

      editor.composer.selection.setSelection(r1);
      editor._cleanAndPaste(cPaste);

      ok(that.ruleChecks(editor.composer.element), "Design rule check passed")

      equal(editor.getValue(false,false).toLowerCase(), output, "copy paste operation working correctly");
      start();
    });
  });

  asyncTest("copyPaste-2 editor._cleanAndPaste command", function() {
    expect(2);
    var that=this;

    var input   = "<p><span class=\"text-font-normal\">hello  world</span></p>",
        cPaste   = "<p><span class=\"Random-Style\">pasted</span><p>",
        output  = "<p><span class=\"text-font-normal\">hello pasted world</span></p>";

    var editor = new wysihtml.Editor(this.textareaElement, this.parserRules);


    editor.on("load", function() {
      editor.setValue(input, false);
      var el = editor.composer.element.getElementsByClassName("text-font-normal");
      var r1 = editor.composer.selection.createRange();

      r1.nativeRange.setStart(el[0].firstChild, 6);
      r1.nativeRange.setEnd(el[0].firstChild, 6);

      editor.composer.selection.setSelection(r1);
      editor._cleanAndPaste(cPaste);

      ok(that.ruleChecks(editor.composer.element), "Design rule check passed")

      equal(editor.getValue(false,false).toLowerCase(), output, "copy paste working correctly");
      start();
    });
  });

  asyncTest("copyPaste-3 editor._cleanAndPaste command", function() {
    expect(1);

    var input   = "<p><span class=\"text-font-normal\">hello  world</span></p>",
        cPaste   = '<p>And all of those things are true of Linux.</p><p>It was a Unix-like kernel</p>',
        output  = "<p><span class=\"text-font-normal\">hello And all of those things are true of Linux.</p><p><span class=\"text-font-normal\">It was a Unix-like kernel. world</span></p>";

    var editor = new wysihtml.Editor(this.textareaElement, this.parserRules);

    editor.on("load", function() {
      editor.setValue(input, false);
      var el = editor.composer.element.getElementsByClassName("text-font-normal");
      var r1 = editor.composer.selection.createRange();

      r1.nativeRange.setStart(el[0].firstChild, 6);
      r1.nativeRange.setEnd(el[0].firstChild, 6);

      editor.composer.selection.setSelection(r1);
      editor._cleanAndPaste(cPaste);

      equal(editor.getValue(false,false), output, "copy paste working correctly");
      start();
    });
  });


  asyncTest("Random style changes", function() {
    expect(1);
    var that=this;

    var input   = "<p><span class=\"text-font-normal\">You want to automate</span><span class=\"text-font-normal\">testing your applications</span><span class=\"text-font-normal\">and frameworks</span></p><p><span class=\"text-font-normal\">Writing your own</span><span class=\"text-font-normal\">testing framework may</span><span class=\"text-font-normal\">be tempting</span></p><p><span class=\"text-font-normal\">While there</span><span class=\"text-font-normal\">are other unit testing</span><span class=\"text-font-normal\">frameworks for JavaScript</span></p>" ;

    var editor = new wysihtml.Editor(this.textareaElement, this.parserRules);

    editor.on("load", function() {
      editor.setValue(input, false);
      function getRandNum(length){
        return Math.floor(Math.random() * (length));
      }

      function randomNode(){
        var allNodes = editor.composer.element.getElementsByTagName("*");
        return allNodes[getRandNum(allNodes.length)-1];      
      }

      var r1 = editor.composer.selection.createRange();
      r1.nativeRange.selectNode(randomNode());

      editor.composer.commands.exec('bold');
      ok(that.ruleChecks(editor.composer.element), "Design rule check passed")
      start();
    });
  });

}
 
