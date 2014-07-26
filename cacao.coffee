Messages = new Meteor.Collection("messages")

if Meteor.isClient

	timeDependency = new Deps.Dependency()
	currentTime = undefined

	refreshTime = ->
		currentTime = (new Date).getTime()
		timeDependency.changed()

	opacityFromTime = (refTime)->
		age = currentTime - refTime
		result = 1.0 - (age*0.1)/1000
		if result < 0 then 0 else result

	Meteor.setInterval(refreshTime, 100)

	Template.chat.displayMessage = ->
		timeDependency.depend()
		opacityFromTime(this.time) > 0
	
	Template.message.opacity = ->
		timeDependency.depend()
		calculatedOpacity = opacityFromTime(this.time)
		$self = $("#"+this._id)
		if calculatedOpacity < 0.5
			$self.addClass "folded"
		calculatedOpacity

	Template.chat.sessionNickname = ->
		Session.get "nickname"

	Template.chat.messages = ->
		Messages.find {}, sort: {time: 1}
	
	Template.chat.events =
		"submit": (event, template)->
			event.preventDefault()
			message =
				nickname: Session.get("nickname")
				body: $("#messageBody").val()
				time: (new Date).getTime()
			Messages.insert message, ->
				$("#messageBody").val('')

	Template.login.events =
		"submit": (event, template)->
			event.preventDefault()
			Session.set "nickname", $("#nickname").val()
			$("#login").fadeOut()
			$("#chat").fadeIn()
