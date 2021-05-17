import consumer from "./consumer"

let roomname = readCookie('username');

consumer.subscriptions.create({ channel: "MessagesChannel", room: roomname}, {
  connected() {
    console.log("Connected to room " + roomname)
  },

  disconnected() {
    console.log("Disconnected from Action Cable");
  },

  received(data) {
    // TODO set unread message counter
    switch (data.type) {
      case "message":
        let e = document.getElementById("chat-" + data.message.chat_id)
        if (e) {
          let m = document.getElementById("messages");
          fetch('/messages/'+data.message.id)
            .then(res=> res.text() )
            .then(data => m.innerHTML += data)
          // TODO scroll window down
        }
        break;
      default:
        console.log("Received unknown data:", data);
    }
  }
});

function readCookie(name) {
	var cookiename = name + "=";
	var ca = document.cookie.split(';');
	for(var i=0; i < ca.length; i++) {
		var c = ca[i];
		while (c.charAt(0)==' ') c = c.substring(1,c.length);
		if (c.indexOf(cookiename) == 0) return c.substring(cookiename.length,c.length);
	}
	return null;
}