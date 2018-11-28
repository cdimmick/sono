function renderBackboneSorters(view){
  $(view.headers.find('span')).click((e) =>{
    let header = $(e.target).closest('th');
    sorter = $(header).data('sorter');

    let sorter_parts = sorter.split('.');

    view.collection.comparator = (model) =>{
      if(sorter_parts.length === 1){
        return model.get(sorter);
      } else {
        return model.get(sorter_parts[0])[sorter_parts[1]];
      }
    }

    view.collection.sort({silent: true});

    if(view.sorter == sorter){
      // If sorter is the same, reverse.
      view.collection.models = view.collection.models.reverse();
      view.sorter = null;
    } else {
      view.sorter = sorter; // Reassign sorter
    }

    view.collection.trigger('reset', view.collection, {});
  });
}

function renderBackboneFilters(view){
  view.headers.each(function(){
    if($(this).data('sorter')){
      $(this).find('input').detach();
      $(this).prepend('<input type="text" class="form-control" />')
    }
  });

  $(view.headers.find('input')).keyup((e) => {
    view.renderList();
  });
}

function renderBackboneList(view, item_view_class){
  // item_view_class is the class of the View for the individaul elements in the list
  view.list.empty();

  $.each(view.collection.models, (i, model) => {
    let pass = true;

    $(view.headers).each((i, header) => {
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
      let item_view = new item_view_class({model: model});
      view.list.append(item_view.render().$el);
    }
  });
}
