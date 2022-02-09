Shiny.addCustomMessageHandler("setTimeout", function (msg) {
  if (!msg.timeout) return;
  var resetTimer, t, w;
  t = setTimeout(idlerLogout, msg.timeout);
  if (msg.warning && msg.warning < msg.timeout) {
    w = setTimeout(idlerWarning, msg.warning);
    var idlerWarning = () => {
      Shiny.setInputValue("idler-warning", msg.timeout - msg.warning, {
        priority: "event",
      });
    };
    resetTimer = () => {
      clearTimeout(t);
      clearTimeout(w);
      t = setTimeout(idlerLogout, msg.timeout);
      w = setTimeout(idlerWarning, msg.warning);
    };
  } else {
    resetTimer = () => {
      clearTimeout(t);
      t = setTimeout(idlerLogout, msg.timeout);
    };
  }
  window.onmousemove = resetTimer; // catches mouse movements
  window.onmousedown = resetTimer; // catches mouse movements
  window.onclick = resetTimer; // catches mouse clicks
  window.onscroll = resetTimer; // catches scrolling
  window.onkeypress = resetTimer; //catches keyboard actions
  function idlerLogout() {
    Shiny.setInputValue("idler-timeout", msg.timeout);
    // ShinyProxy adds a ui property to the window.parent.Shiny object
    if (!("ui" in window.parent.Shiny)) {
      return;
    }
    let ShinyProxy = window.parent.Shiny;
    // End ShinyProxy session and show UI for a stopped page
    ShinyProxy.instances._deleteInstance(
      ShinyProxy.app.staticState.appInstanceName,
      function () {
        ShinyProxy.ui.showStoppedPage();
      }
    );
  }
});
