###
    @file: mails_controller.coffee
    @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
    @description:
        Railwayjs controller to handle mails CRUD backend and their attachments.
###

load 'application'


# shared functionnality : find the mail via its ID
before ->
    Mail.find params.id, (err, mail) =>
        if err
            send error: err, 500
        else if not mail?
            send error: "not found", 404
        else
            @mail = mail
            next()
, { only: ['show', 'update', 'destroy', 'getattachmentslist'] }


# App entry point
action 'index', ->
    render
        title: "Cozy Mails"


# GET /mails/:id
# Return mail corresponding to given ID.
action 'show', ->
    send @mail


# PUT /mails/:id
# Modify given mail. If mail read flag is changed, the remote mail version is
# updated too.
action 'update', ->
    markRead = false
    if body.read and not @mail.read
        markRead = true

    @mail.updateAttributes body, (err) =>
        if err
            send error: err, 500
        else
            if markRead
                Mailbox.find @mail.mailbox, (err, mailbox) =>
                    if err or not mailbox?
                        send error: "unknown mailbox can't update read flag", 500
                    else
                        mailbox.getAccount (err, account) =>
                            mailbox.password = account.password
                            mailbox.markMailAsRead @mail, (err) ->
                                if err
                                    send error: "can't update read flag", 500
                                else
                                    send 200
            else
                send success: true


# GET '/mailslist/:timestamp/:num'
# Get num mails until given timestamp.
action 'getlist', ->
    num = parseInt req.params.num
    timestamp = parseInt req.params.timestamp

    if params.id? and params.id isnt "undefined"
        skip = 1
    else
        skip = 0

    query =
        startkey: [timestamp, params.id]
        limit: num
        descending: true
        skip: skip

    Mail.dateId query, (err, mails) ->
        if err
            send error: err, 500
        else
            if mails.length is 0
                send []
            else
                send mails


# GET '/mailsnew/:timestamp'
# Get all mails after a given timestamp.
action 'getnewlist', ->
    timestamp = parseInt params.timestamp

    query =
        startkey: [timestamp, undefined]
        descending: false
        skip: 1

    Mail.dateId query, (err, mails) ->
        if err
            send error: err, 500
        else
            send mails

# GET '/mails/:id/attachments
# Get all attachements object for given mail.
action 'getattachmentslist', ->
    query =
        key: @mail.id

    Attachment.fromMail query, (err, attachments) ->
        if err
            send error: err, 500
        else
            send attachments

# GET '/attachments/:id/'
# Get file linked to attachement with given id.
action 'getattachment', ->
    Attachment.find params.id, (err, attachment) =>
        if err
            send error: err, 500
        else if not attachment
            send error: true, 400
        else
            attachment.getFile attachment.fileName, (err, res, body) ->
                if err or not res?
                    send error: true, 500
                else if res.statusCode is 404
                    send 'File not found', 404
                else if res.statusCode isnt 200
                    send error: true, 500
                else
                    send success: true, 200
            .pipe res
