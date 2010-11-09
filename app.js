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
    window.StoryView = Backbone.View.extend((function() {
      var attrs, edit, update;
      attrs = {
        tagName: 'li',
        events: {
          'click .delete': 'delete',
          'keypress input,textarea': 'focusOutOnEnter'
        },
        initialize: function() {
          _.bindAll(this, 'render', 'close');
          this.model.bind('change', this.render);
          return (this.model.view = this);
        },
        render: function() {
          $(this.el).html(ich.card(this.model.toJSON()));
          return this;
        },
        "delete": function() {
          this.model.clear();
          return false;
        },
        focusOutOnEnter: function(event) {
          return event.keyCode === 13 ? $(event.target).focusout() : null;
        }
      };
      edit = function(attr) {
        return function(event) {
          return this.$('.' + attr).addClass('editing').find('input,textarea').focus();
        };
      };
      update = function(attr) {
        return function(event) {
          var kwargs;
          kwargs = {};
          kwargs[attr] = this.$('.' + attr).removeClass('editing').find('input,textarea').val();
          return this.model.save(kwargs);
        };
      };
      _(['title', 'user', 'action', 'reason']).each(function(attr) {
        attrs['edit' + attr] = edit(attr);
        attrs.events['dblclick .' + attr] = 'edit' + attr;
        attrs['update' + attr] = update(attr);
        return (attrs.events['focusout .' + attr] = 'update' + attr);
      });
      return attrs;
    })());
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
        Stories.fetch();
        return !Stories.length ? this.create() : null;
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
