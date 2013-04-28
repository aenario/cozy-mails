
###
    @file: message_box_element.coffee
    @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
    @description:
        Serves a single message to user

###

class exports.MessageBoxElement extends Backbone.View

    constructor: (@model, @collection) ->
        super()
        @model.view = @

    events:
        "click button.close" : 'onCloseClicked'

    onCloseClicked: =>
         @$el.fadeOut()
         if @model.get("type") isnt "info" or @model.get("type") isnt "check"
             @model.destroy()
         @collection.remove @model
         @remove()

    remove: =>
        @$el.remove()

    render: ->
        if @model.get("timeout") isnt 0
             setTimeout @remove, @model.get("timeout") * 1000

        type = @model.get("type")

        if type is "error"
            template = require './templates/_message/message_error'
        else if type is "success"
            template = require './templates/_message/message_success'
        else if type is "warning"
            template = require './templates/_message/message_warning'
        else
            template = require './templates/_message/message_info'

        @$el.html template model: @model
        @
