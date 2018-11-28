Users.Views.Show = Backbone.View.extend({
  template: JST['users/users/show'],
  tagName: 'tr',
  className: 'user_row',
  render: function(){
    this.$el.html(this.template(this.model.toJSON()));
    return this;
  }
});
