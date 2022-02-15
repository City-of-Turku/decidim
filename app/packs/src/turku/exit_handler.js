const allowExitFrom = ($el) => {
  const $budgetSummary = $(".budget-summary__progressbox");
  const currentAllocation = parseInt($budgetSummary.attr("data-current-allocation"), 10);

  if (currentAllocation === 0) {
    return true;
  } else if ($el.attr("target") === "_blank") {
    return true;
  } else if ($el.hasClass("sign-out-link")) {
    return true;
  } else if ($el.attr("href") && $el.attr("href").startsWith("#") ||
    $el.attr("href").startsWith(`${location.pathname}#`) ||
    $el.attr("href").startsWith(`${location.href}#`)
  ) {
    return true;
  } else if ($el.attr("id") && $el.attr("id") === "exit-notification-link") {
    return true;
  } else if ($el.parents(".voting-wrapper").length > 0) {
    return true;
  }

  return false;
}

$(() => {
  const $exitNotification = $("#exit-notification");
  const $exitLink = $("#exit-notification-link");
  const defaultExitUrl = $exitLink.attr("href");
  const defaultExitLinkText = $exitLink.text();
  let exitLinkText = defaultExitLinkText;

  if ($exitNotification.length < 1) {
    // Do not apply when not inside the voting pipeline
    return;
  }

  const openExitNotification = (url, method = null) => {
    if (method && method !== "get") {
      $exitLink.attr("data-method", method);
    } else {
      $exitLink.removeAttr("data-method");
    }

    $exitLink.attr("href", url);
    $exitLink.html(exitLinkText);
    $exitNotification.foundation();
    $exitNotification.foundation("open");
  };

  // Handle "beforeunload"
  window.allowExit = false;
  $(document).on("click", "a", (event) => {
    exitLinkText = defaultExitLinkText;
    window.allowExit = false;

    const $link = $(event.currentTarget);
    if (allowExitFrom($link)) {
      window.allowExit = true;
    } else {
      event.preventDefault();
      openExitNotification($link.attr("href"), $link.data("method"));
    }
  });
  // Custom handling for the header sign out so that it won't trigger the
  // logout form submit and so that it changes the exit link text. This does
  // not trigger the document link click listener because it has the
  // data-method attribute to trigger a form submit event.
  $(".menu a.sign-out-link").on("click", (event) => {
    event.preventDefault();
    event.stopPropagation();

    const $link = $(event.currentTarget);
    exitLinkText = $link.text();
    openExitNotification($link.attr("href"), $link.data("method"));
  });
  // Custom handling for the exit link which needs to change the exit link
  // text to the default text as this is not handled by the document click
  // listener.
  $("a[data-open='exit-notification']").on("click", () => {
    exitLinkText = defaultExitLinkText;
    openExitNotification(defaultExitUrl);
  });
  // Allow all form submits on the page, including language change and sign
  // out form (when triggered by the exit link click).
  $(document).on("submit", "form", () => {
    window.allowExit = true;
  });

  window.addEventListener("beforeunload", (event) => {
    const allowExit = window.allowExit;
    window.allowExit = false;

    if (allowExit) {
      return;
    }

    event.returnValue = true;
  });
});
