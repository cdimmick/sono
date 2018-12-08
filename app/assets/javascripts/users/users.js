window.Users = {
  Models: {},
  Collections: {},
  Views: {},
  Routers: {},
  hideCols: function(cols){
    this.columns_to_hide = cols;
  },
  init: function(users){
    Users.users = new Users.Collections.Users(users);
    let view = new Users.Views.Index({collection: Users.users});
    view.render();
  }
};
