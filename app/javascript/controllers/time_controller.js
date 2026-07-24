import { Controller } from "@hotwired/stimulus";
import {
  format,
  formatDistanceToNow,
  formatRelative,
  isThisWeek,
  isToday,
  parseISO,
} from "date-fns";
import { utcToZonedTime, zonedTimeToUtc } from "date-fns-tz";
import { de, enUS, es, fr, it, pt } from "date-fns/locale";

export default class extends Controller {
  static values = { intervalId: Number };

  connect() {
    this.updateTime();
    this.startPeriodicUpdate();
  }

  disconnect() {
    this.stopPeriodicUpdate();
  }

  startPeriodicUpdate() {
    let jitter = Math.random() * 1000; // up to 1 second of jitter
    this.intervalIdValue = setInterval(() => {
      this.updateTime();
    }, 60000 + jitter); // Updates every minute with jitter
  }

  stopPeriodicUpdate() {
    clearInterval(this.intervalIdValue);
  }

  updateTime() {
    const element = this.element;
    const datetime = parseISO(element.getAttribute("datetime"));
    const timezone = Intl.DateTimeFormat().resolvedOptions().timeZone;
    const zonedDate = utcToZonedTime(datetime, timezone);
    const language = document.documentElement.lang || "en";
    const locale = this.getLocale(language);

    let text;
    if (isToday(zonedDate)) {
      text = formatDistanceToNow(zonedDate, { locale, addSuffix: true });
    } else if (isThisWeek(zonedDate)) {
      text = format(zonedDate, "eeee, p", { locale });
    } else {
      text = format(zonedDate, "PPp", { locale });
    }

    const titleText = format(zonedDate, "Pp", { locale });

    element.textContent = text;
    element.setAttribute("title", titleText);
    element.setAttribute("aria-label", titleText);
  }

  getLocale(language) {
    switch (language) {
      case "es":
        return es;
      case "de":
        return de;
      case "fr":
        return fr;
      case "it":
        return it;
      case "pt":
        return pt;
      default:
        return enUS;
    }
  }
}
