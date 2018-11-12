window.Facilities = {
  Models: {},
  Collections: {},
  Views: {},
  Routers: {},
  init: function(facilities){
    Facilities.facilities = new Facilities.Collections.Facilities(facilities);
    let view = new Facilities.Views.Index({collection: Facilities.facilities});
    view.render();
  }
};
