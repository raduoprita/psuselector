import consumer from "channels/consumer"

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

    // console.log("PsuReprocessChannel", data);

    if (data.head === 200 || data.head === 302) {
      if (data.notice) {
        document.getElementById("notice").innerText = data.notice;
      }

      if (data.path) {
        window.location.pathname = data.path;
        if (data.notice) {
          document.getElementById("notice").innerText = data.notice;
        }
      }
    }

    // if (data.head === 200 && data.notice === true) {
    //   document.getElementById("notice").innerText = data.message;
    // }
    //
    // if (data.head === 302 && data.path) {
    //   window.location.pathname = data.path;
    // }
  }
});
