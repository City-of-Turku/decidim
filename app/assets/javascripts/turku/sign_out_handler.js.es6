//= require jquery

$(() => {
  const $signOutModal = $("#signOutModal")
  if ($signOutModal.length === 0) {
    return
  }

  const $signOutLink = $("#user-menu").find(".sign-out-link")
  const $continueButton = $signOutModal.find("#continueVoting")
  const popup = new Foundation.Reveal($signOutModal);

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
