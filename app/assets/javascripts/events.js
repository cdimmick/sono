function _submitEventPassword(ajax_url){
  let password = $('#password').val();
  $.ajax({
    method: 'GET',
    url: ajax_url + '.js',
    data: {
      event: {
        password: password
      }
    },
    error: function(errors){
      alert('Incorrect password!');
      $('#password').select();
    }
  });
}

function submitEventPassword(ajax_url){
  $('#submit').click(function(){
    _submitEventPassword(ajax_url);
  });

  $('#password').keyup(function(e){
    if(e.keyCode == 13){
      _submitEventPassword(ajax_url);
    }
  });
}

function NewEventForm(){
  this.event_form = $('[action="/events"]');
  this.new_user_fields = $('#new_user_fields');
  this.new_user_fields_visible = true;

  this.showHideNewUserFields = function(){
    $('#event_user_id').change((event) => {
      let targ = $(event.target);
      if(targ.val() > 0){
        this.new_user_fields_visible = false;
        this.new_user_fields.hide(500);
      } else {
        this.new_user_fields_visible = true;
        this.new_user_fields.show(250);
      }

      $('#event_user_attributes_name').select();
    });
  }

  this.preventNewUserFieldsOnSubmit = function(){
    this.event_form.submit((event) => {
      // Necessary to drop the New User fields to not cause an validation error.
      if(!this.new_user_fields_visible){
        this.new_user_fields.detach();
      }
    });
  }

  this.initializeNewUserFields = function(){
    this.showHideNewUserFields();
    this.preventNewUserFieldsOnSubmit();
  }

  this.init = function(){
    this.initializeNewUserFields();
  }
}


function StreamPlayer(){
  this.$el = $('#player');
  this.$coming_soon = $('#coming_soon');

  this.getPlayer = function(){
    return new Promise(function(resolve, reject){
      let interval_id = window.setInterval(() => {
        if($wp.get('wowza_player')){
          resolve();
          window.clearInterval(interval_id);
        }
      }, 1000);
    });
  }

  this.isLive = function(){
    return $wp.get('wowza_player').isLive();
  }

  this.play = function(){
    return $wp.get('wowza_player').play();
  }

  this.log = function(message){
    console.log('--- StreamPlayer: ' + message + ' ---');
  }

  this.hide = function(){
    this.$el.hide();
    this.$coming_soon.show();
  }

  this.show = function(){
    this.$el.show();
    this.$coming_soon.hide();
  }

  this.init = function(){
    this.log('Initializing..');
    this.hide();
    this.is_playing = false;

    this.getPlayer().then(() => {
      let interval_id = window.setInterval(() => {
        if(this.isLive()){
          // if(!this.is_playing){
            this.log('Wowza Stream is Live.');
            this.show();
            this.is_playing = true;
            window.clearInterval(interval_id);
          // }
        } else {
          this.log('Wowza Stream is NOT Live, checking again in 5 seconds..');
          this.hide();
          this.is_playing = false;
          this.play();
        }
      }, 1000);
    });
  }
}
