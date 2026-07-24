import { Controller } from "@hotwired/stimulus";
import { getCookie, setCookie } from "./lib/cookie";

export default class extends Controller {
  static targets = ["banner"];

  connect() {
    if (!getCookie("pwaBannerClosed")) {
      this.bannerTarget.classList.remove("hidden");
    }
  }

  hide() {
    setCookie("pwaBannerClosed", "true");
    this.bannerTarget.classList.add("hidden");
  }
}
