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
