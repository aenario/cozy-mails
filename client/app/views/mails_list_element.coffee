{Mail} = require "../models/mail"

###

  The element on the list of mails. Reacts for events, and stuff.

###
class exports.MailsListElement extends Backbone.View

  tagName : "tr"

  events : {
    "click" : "setActiveMail"
  }
  
  constructor: (@model, @collection) ->
    super()
    @model.view = @
    @collection.on "change_active_mail", @render, @
    
  setActiveMail: (event) ->
    @collection.activeMail = @model
    @collection.trigger "change_active_mail"
    @collection.activeMail.set_read()

  render: ->
    template = require('./templates/_mail/mail_list')
    $(@el).html template({"model" : @model, "active" : @model == @collection.activeMail})
    @