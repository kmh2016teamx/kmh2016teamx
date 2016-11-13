$(function() {

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
    $("#discussion_description").val(result.candidates[0].speech);
  });

});
