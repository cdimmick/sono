Facilities.Views.Index = Backbone.View.extend({
  el: '#facilities',
  initialize: function(){
    this.list = this.$el.find('#facilities_table tbody');
    this.headers = this.$el.find('th');
    this.listenTo(this.collection, 'reset', this.renderList)
  },
  render: function(){
    this.renderList();
    this.renderFilters();
    this.renderSorters();
  },
  renderFilters: function(){
    this.headers.each(function(){
      $(this).find('input').detach();
      $(this).prepend('<input type="text" class="form-control" />')
    });

    $(this.headers.find('input')).keyup((e) => {
      this.renderList();
    });
  },
  renderSorters: function(){
    $(this.headers.find('span')).click((e) =>{
      let header = $(e.target).closest('th');
      sorter = $(header).data('sorter');

      let sorter_parts = sorter.split('.');

      this.collection.comparator = (model) =>{
        if(sorter_parts.length === 1){
          return model.get(sorter);
        } else {
          return model.get(sorter_parts[0])[sorter_parts[1]];
        }
      }

      this.collection.sort({silent: true});

      if(this.sorter == sorter){
        // If sorter is the same, reverse.
        this.collection.models = this.collection.models.reverse();
        this.sorter = null;
      } else {
        this.sorter = sorter; // Reassign sorter
      }

      this.collection.trigger('reset', this.collection, {});
    });
  },
  renderList: function(){
    this.list.empty();

    $.each(this.collection.models, (i, model) => {
      let pass = true;

      $(this.headers).each((i, header) => {
        if(pass){
          let filter_val = $(header).find('input').val();

          if(filter_val){
            let reg = new RegExp(filter_val, 'i');

            let filter_keys = $(header).data('sorter').split('.');

            if(filter_keys.length == 1){
              if(!reg.exec(model.get(filter_keys[0]))){
                pass = false
              }
            } else {
              if(!reg.exec(model.get(filter_keys[0])[filter_keys[1]])){
                pass = false;
              }
            }
          }
        }
      });

      if(pass){
        let view = new Facilities.Views.Show({model: model});
        this.list.append(view.render().$el);
      }
    });

    return this;
  }
});
