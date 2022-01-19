import 'shiny';

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
  }
  function resetTimer() {
    clearTimeout(t);
    t = setTimeout(logout, timeoutDuration);
  }
});
