// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery-ui
//= require jquery.colorbox
//= require twitter/bootstrap

function check_for_enter_pressed(e){
  if (e.keyCode == 13)
    return true;
  
  return false;
}

function isArrowKeyPressed(e){
  var evt = e || window.event;
  if(evt.keyCode >= 37 && evt.keyCode <= 40){
    return true;
  }
  return false;
}

function open_colorbox(get_url){
  $.colorbox({
    href: get_url,
    height: '300px',
    width: '50%',
    top: '100px'
  });
  return false;
}

