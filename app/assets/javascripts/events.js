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
