{Mail} = require "../models/mail"

###

  The view with the "load more" button.

###
class exports.MailsListMore extends Backbone.View

  constructor: (@el, @collection) ->
    super()
    
  initialize: ->
    @collection.on('reset', @render, @)
    @collection.on('change', @render, @)
    window.app.mailboxes.on('change_active_mailboxes', @render, @)

  events: {
     "click #add_more_mails" : 'loadOlderMails',
  }
  
  render: ->
    template = require "./templates/_mail/mails_more"
    $(@el).html template({"collection" : @collection})
    @
    
  loadOlderMails: () ->
    @collection.fetchOlder()