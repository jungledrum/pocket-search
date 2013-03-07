$(function(){
	var Item = Backbone.Model.extend({
		urlRoot: "/items",

		defaults: {
			"name": "name",
			"title": "title"
		},

		initialize: function(){

		}
	});

	var item = new Item;
	item.fetch({
		success: function() {
    console.log(item.toJSON());
  }})
	// console.log(item)
	// console.log(item.toJSON());

	var ItemView = Backbone.View.extend({
		template: _.template($("#item-template").html()),

		initialize: function(){
			$("#items").append(this.template(item.toJSON()))
		},

		render: function(item){
			// this.$("#items").append(this.template(item.toJSON()))
			// console.log(template)
		}
	});

	var view = new ItemView();
});