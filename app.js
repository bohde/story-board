(function() {
  $(function() {
    window.Story = Backbone.Model.extend({
      EMPTY: {
        title: 'New Story',
        user: '[user]',
        action: '[do something]',
        reason: '[achieve some business requirement]'
      },
      initialize: function() {
        return this.set({
          title: this.get('title') || this.EMPTY.title,
          user: this.get('user') || this.EMPTY.user,
          action: this.get('action') || this.EMPTY.action,
          reason: this.get('reason') || this.EMPTY.reason
        });
      },
      clear: function() {
        this.destroy();
        return $(this.view.el).remove();
      }
    });
    window.StoryBoard = Backbone.Collection.extend({
      model: Story,
      localStorage: new Store('stories')
    });
    window.Stories = new StoryBoard();
    window.StoryView = Backbone.View.extend({
      tagName: 'li',
      events: {
        'dblclick em,h2': 'edit',
        'focusout input': 'update',
        'keypress input': 'updateOnEnter',
        'click .delete': 'delete'
      },
      initialize: function() {
        _.bindAll(this, 'render', 'close');
        this.model.bind('change', this.render);
        this.model.view = this;
        this.input = $('<input></input>');
        return (this.editing = null);
      },
      render: function() {
        $(this.el).html(ich.card(this.model.toJSON()));
        return this;
      },
      edit: function(event) {
        var el, val;
        el = $(event.target);
        this.editing = el.attr('class');
        val = this.model.get(this.editing);
        this.input.val(val);
        el.after(this.input).remove();
        return this.input.focus();
      },
      updateOnEnter: function(e) {
        return e.keyCode === 13 ? this.update() : null;
      },
      update: function() {
        var kwargs;
        this.input.attr('class');
        kwargs = {};
        kwargs[this.editing] = this.input.val();
        this.editing = null;
        this.model.save(kwargs);
        return this.render();
      },
      "delete": function() {
        this.model.clear();
        return false;
      }
    });
    window.BoardView = Backbone.View.extend({
      el: $('body'),
      events: {
        "click .add": 'create'
      },
      initialize: function() {
        _.bindAll(this, 'addOne', 'addAll');
        Stories.bind('add', this.addOne);
        Stories.bind('refresh', this.addAll);
        this.render();
        return Stories.fetch();
      },
      create: function() {
        Stories.create();
        return false;
      },
      addOne: function(story) {
        var view;
        view = new StoryView({
          model: story
        });
        return this.$('#cards').append(view.render().el);
      },
      addAll: function() {
        return Stories.each(this.addOne);
      },
      render: function() {
        return this.$('#overview').html(ich.overviewTemplate({}));
      }
    });
    return (window.App = new BoardView());
  });
}).call(this);
