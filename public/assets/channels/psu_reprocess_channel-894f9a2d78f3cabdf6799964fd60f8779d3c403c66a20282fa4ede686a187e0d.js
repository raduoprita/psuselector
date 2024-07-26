import consumer from "./consumer"

consumer.subscriptions.create("PsuReprocessChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
    // console.log('connected to cable');
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    // Called when there's incoming data on the websocket for this channel

    if (data.head === 200 && data.notice === true) {
      document.getElementById("notice").innerText = data.message;
    }

    if (data.head === 302 && data.path) {
      window.location.pathname = data.path;
    }
  }
});
