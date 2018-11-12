Facilities.Views.Index = Backbone.View.extend({
  el: '#facilities',
  initialize: function(){
    this.list = this.$el.find('#facilities_table tbody');
  },
  render: function(){
    let t = this;

    $.each(this.collection.models, function(i, facility){
      let view = new Facilities.Views.Show({model: facility});
      t.list.append(view.render().$el);
      return this;
    });
  }
});
