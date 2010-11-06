$ ->
  window.Story = Backbone.Model.extend
    EMPTY:
      user: '[ user ]'
      action: '[ do something ]'
      reason: '[ achieve some business requirement ]'

    initialize: ->
      @set
        user: @get('user') || @EMPTY.user
        action: @get('action') || @EMPTY.action
        reason: @get('reason') || @EMPTY.reason

  window.StoryBoard = Backbone.Collection.extend
    model: Story

    localStorage: new Store 'stories'

  window.Stories = new StoryBoard

  window.StoryView = Backbone.View.extend
    tagName: 'li'

    events:
      'dblclick': 'edit'

    initialize: ->
      _.bindAll @, 'render', 'close'
      @model.bind 'change', @render
      @model.view = @

    render: ->
      $(@el).html ich.card(@model.toJSON())
      @

    edit: ->

  window.BoardView = Backbone.View.extend
    el: $ '#cards'

    initialize: ->
      _.bindAll @, 'addOne', 'addAll'

      Stories.bind 'add', @addOne
      Stories.bind 'refresh', @addAll

      Stories.fetch()

    addOne: (story) ->
      view = new StoryView
        model: story
      @el.append view.render().el

    addAll: ->
      Stories.each @addOne

  window.App = new BoardView
