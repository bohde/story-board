$ ->
  window.Story = Backbone.Model.extend
    EMPTY:
      title: 'New Story'
      user: '[user]'
      action: '[do something]'
      reason: '[achieve some business requirement]'

    initialize: ->
      @set
        title: @get('title') || @EMPTY.title
        user: @get('user') || @EMPTY.user
        action: @get('action') || @EMPTY.action
        reason: @get('reason') || @EMPTY.reason

    clear: ->
      @destroy()
      $(this.view.el).remove()

  window.StoryBoard = Backbone.Collection.extend
    model: Story

    localStorage: new Store 'stories'

  window.Stories = new StoryBoard

  window.StoryView = Backbone.View.extend (->
      attrs =
        tagName: 'li'

        events:
          'click .delete': 'delete'
          'keypress input,textarea': 'focusOutOnEnter'

        initialize: ->
          _.bindAll @, 'render', 'close'
          @model.bind 'change', @render
          @model.view = @

        render: ->
          $(@el).html ich.card @model.toJSON()
          @

        delete: ->
          @model.clear()
          false

        focusOutOnEnter: (event) ->
          if event.keyCode == 13
            $(event.target).focusout()

      edit = (attr) ->
        (event) ->
          @$('.'+attr).addClass('editing').find('input,textarea').focus()

      update = (attr) ->
        (event) ->
            kwargs = {}
            kwargs[attr] = @$('.'+attr).removeClass('editing').find('input,textarea').val()
            @model.save kwargs


      _(['title', 'user', 'action', 'reason']).each (attr) ->
        attrs['edit'+attr] = edit attr
        attrs.events['dblclick .'+attr] = 'edit'+attr
        attrs['update'+attr] = update attr
        attrs.events['focusout .'+attr] = 'update'+attr

      attrs)()

  window.BoardView = Backbone.View.extend
    el: $ 'body'

    events:
      "click .add": 'create'

    initialize: ->
      _.bindAll @, 'addOne', 'addAll'

      Stories.bind 'add', @addOne
      Stories.bind 'refresh', @addAll

      @render()
      Stories.fetch()
      if !Stories.length
        @create()

    create: ->
      Stories.create()
      false

    addOne: (story) ->
      view = new StoryView
        model: story
      @$('#cards').append view.render().el

    addAll: ->
      Stories.each @addOne

    render: ->
      @$('#overview').html ich.overviewTemplate {}

  window.App = new BoardView
