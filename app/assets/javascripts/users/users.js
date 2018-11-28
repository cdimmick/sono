window.Users = {
  Models: {},
  Collections: {},
  Views: {},
  Routers: {},
  init: function(users){
    Users.users = new Users.Collections.Users(users);
    let view = new Users.Views.Index({collection: Users.users});
    view.render();
  }
};
