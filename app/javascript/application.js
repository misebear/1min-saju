// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

document.addEventListener("click", (event) => {
  const trackedElement = event.target.closest("[data-analytics-event]")
  if (!trackedElement || typeof window.gtag !== "function") return

  const {
    analyticsEvent,
    analyticsPageType,
    analyticsSourceSection,
    analyticsTargetTool
  } = trackedElement.dataset

  if (!analyticsEvent) return

  window.gtag("event", analyticsEvent, {
    page_type: analyticsPageType || "unknown",
    source_section: analyticsSourceSection || "unknown",
    target_tool: analyticsTargetTool || "unknown"
  })
})
