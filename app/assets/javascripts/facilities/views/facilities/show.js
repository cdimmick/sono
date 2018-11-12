Facilities.Views.Show = Backbone.View.extend({
  template: JST['facilities/facilities/show'],
  tagName: 'tr',
  className: 'facility_row',
  render: function(){
    this.$el.html(this.template(this.model.toJSON()));
    return this;
  }
});
