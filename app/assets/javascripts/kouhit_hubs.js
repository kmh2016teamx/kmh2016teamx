$.fn.extend({
  insertAtCaret: function(v) {
    var o = this.get(0);
    o.focus();
    if (jQuery.browser != null && jQuery.browser.msie != null) {
      var r = document.selection.createRange();
      r.text = v;
      r.select();
    } else {
      var s = o.value;
      var p = o.selectionStart;
      var np = p + v.length;
      o.value = s.substr(0, p) + v + s.substr(p);
      o.setSelectionRange(np, np);
    }
  }
});

$(document).on('turbolinks:load', function() {

  // 音声認識

  SpeechRec.config({
    'SkyWayKey':'9954ce78-bb27-45cc-98ac-b33cb8870e9a',
    'OpusWorkerUrl':'/assets/libopus.worker.js'
  });

  $("#start_rec").click(function(){
    SpeechRec.start();
    console.log("音声認識を開始します");
  });

  $("#cancel_rec").click(function(){
    SpeechRec.stop();
    console.log("音声認識を終了します");
  });

  SpeechRec.on_proc(function(info){
    console.log(info.volume);
  });

  SpeechRec.on_result(function(result){
    console.log(result.candidates);
    $("#discussion_description").insertAtCaret(result.candidates[0].speech);
  });

});
