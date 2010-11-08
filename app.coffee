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

  window.StoryView = Backbone.View.extend
    tagName: 'li'

    events:
      'dblclick em,h2': 'edit'
      'focusout input': 'update'
      'keypress input': 'updateOnEnter'
      'click .delete': 'delete'

    initialize: ->
      _.bindAll @, 'render', 'close'
      @model.bind 'change', @render
      @model.view = @
      @input = $('<input></input>')
      @editing = null

    render: ->
      $(@el).html ich.card(@model.toJSON())
      @

    edit: (event) ->
      el = $(event.target)
      @editing = el.attr 'class'
      val = @model.get @editing
      @input.val(val)
      el.after(@input).remove()
      @input.focus()

    updateOnEnter: (e) ->
      if e.keyCode == 13
        @update()

    update: ->
      @input.attr 'class'
      kwargs = {}
      kwargs[@editing] = @input.val()
      @editing = null
      @model.save(kwargs)
      @render()

    delete: ->
      @model.clear()
      false

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
