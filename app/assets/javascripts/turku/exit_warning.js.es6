//= require jquery

$(() => {
  const $exitWarningModal = $("#exitWarningModal")
  if ($exitWarningModal.length === 0) {
    return
  }

  const $signOutLink = $("#user-menu").find(".sign-out-link")
  const $continueButton = $exitWarningModal.find("#continueVoting")
  const popup = new Foundation.Reveal($exitWarningModal);

  $signOutLink.removeAttr("href")
  $signOutLink.removeAttr("data-method")
  $signOutLink.on("click", (event) => {
    event.preventDefault()
    popup.open()
  })

  $continueButton.on("click", () => {
    popup.close()
  })
})
