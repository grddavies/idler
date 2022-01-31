Shiny.addCustomMessageHandler("setTimeout", function (timeoutDuration) {
  if (!timeoutDuration) return;
  var t = setTimeout(logout, timeoutDuration);
  window.onmousemove = resetTimer; // catches mouse movements
  window.onmousedown = resetTimer; // catches mouse movements
  window.onclick = resetTimer; // catches mouse clicks
  window.onscroll = resetTimer; // catches scrolling
  window.onkeypress = resetTimer; //catches keyboard actions
  function logout() {
    Shiny.setInputValue("idler-timeout", timeoutDuration);
    // ShinyProxy adds a ui property to the Shiny object
    if ((window.parent != window.top) && !("ui" in window.parent.Shiny)) {
      return;
    }
    alert(window.parent.Shiny.toString());
    let ShinyProxy = window.parent.Shiny;
    // End ShinyProxy session
    ShinyProxy.instances._deleteInstance(
      ShinyProxy.app.staticState.appInstanceName,
      function () {
        ShinyProxy.ui.showStoppedPage();
      }
    );
  }
  function resetTimer() {
    clearTimeout(t);
    t = setTimeout(logout, timeoutDuration);
  }
});
