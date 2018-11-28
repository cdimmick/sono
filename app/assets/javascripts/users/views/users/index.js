Users.Views.Index = Backbone.View.extend({
  el: '#users',
  initialize: function(){
    this.list = this.$el.find('#users_table tbody');
    this.headers = this.$el.find('th');
    this.listenTo(this.collection, 'reset', this.renderList)
  },
  render: function(){
    this.renderList();
    this.renderFilters();
    this.renderSorters();
  },
  renderFilters: function(){
    renderBackboneFilters(this);
  },
  renderSorters: function(){
    renderBackboneSorters(this);
  },
  renderList: function(){
    renderBackboneList(this, Users.Views.Show);
  }
});
