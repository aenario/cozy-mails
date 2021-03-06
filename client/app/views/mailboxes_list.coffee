{Mailbox} = require "../models/mailbox"
{MailboxesListElement} = require "../views/mailboxes_list_element"

###
    @file: mailboxes_list.coffee
    @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
    @description:
        Displays the list of configured mailboxes.
###

class exports.MailboxesList extends Backbone.View
    id: "mailboxes"
    el: "#mailboxes"
    className: "mailboxes"

    constructor: (@collection) ->
        super()
        @collection.view = @

    initialize: ->
        @collection.on 'reset', @render, @

    addOne: (mailbox) ->
        box = new MailboxesListElement mailbox, @collection
        @$el.append box.render().el

    render: ->
        @$el.html ""
        @collection.each (mailbox) =>
            mailbox.isEdit = false
            @addOne mailbox

        if @collection.length is 0
            @$el.append '<p id="no-mailbox-msg">no mailbox found</p>'
        @

        $("#mailboxes").niceScroll()
