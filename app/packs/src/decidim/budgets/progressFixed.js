$(() => {
  const checkProgressPosition = () => {
    let progressFix = document.querySelector("[data-progressbox-fixed]"),
        progressRef = document.querySelector("[data-progress-reference]"),
        progressVisibleClass = "is-progressbox-visible";

    // Turku doesnt show progress bar when user has voted in another budget (except koko turku)!
    if (!progressRef || !progressFix) {
      return;
    }

    let progressPosition = progressRef.getBoundingClientRect().bottom;
    if (progressPosition > 0) {
      progressFix.classList.remove(progressVisibleClass);
    } else {
      progressFix.classList.add(progressVisibleClass);
    }
  }

  window.addEventListener("scroll", checkProgressPosition);

  window.DecidimBudgets = window.DecidimBudgets || {};
  window.DecidimBudgets.checkProgressPosition = checkProgressPosition;
});
