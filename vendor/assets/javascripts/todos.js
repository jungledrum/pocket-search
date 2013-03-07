$(function(){

  var Todo = Backbone.Model.extend({

    urlRoot: "/books",

    defaults: {
      "title":"title",
      "col":"col1"
    },

    initialize: function(){
      this.set({name: "name"})
    }

  });

  var todo = new Todo();
  if (todo.has("id")) {
    console.log("has")

  };
  console.log(todo.save())
})