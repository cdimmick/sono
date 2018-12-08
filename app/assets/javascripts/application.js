// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require bootstrap
//= require rails-ujs
//= require activestorage
//= require turbolinks
//= require underscore
//= require backbone
//= require backbone_shared

//= require facilities/facilities
//= require_tree ../templates
//= require_tree ./facilities/models
//= require_tree ./facilities/collections
//= require_tree ./facilities/views
// require_tree ./facilities/routers

//= require users/users
//= require_tree ./users/models
//= require_tree ./users/collections
//= require_tree ./users/views
//= require_tree .

function c(val){
  console.log('-----------------------------');
  console.log(val);
  console.log('-----------------------------');
}


function titleCase(str) {
  str = str.toLowerCase().split(' ');
  for (var i = 0; i < str.length; i++) {
    str[i] = str[i].charAt(0).toUpperCase() + str[i].slice(1);
  }
  return str.join(' ');
}

function clickCopy(selector){
  $(selector).click(function(e){
    e.preventDefault();

    let input = $(e.target);
    let value = input.val();

    input.select();

    document.execCommand('copy');
    $(e.target).blur();
    input.val('copied!');

    window.setTimeout(function(){
      input.val(value);
    }, 1500);
  });
}
