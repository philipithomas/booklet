import { Controller } from "@hotwired/stimulus";
import debounce from "lodash.debounce";

export default class extends Controller {
  connect() {
    this.debouncedSave = debounce(this.save.bind(this), 1500);
  }

  save(event) {
    // Check if the event is a keyup event and not from pasting
    if (event.type === "keyup" && event.inputType !== "insertFromPaste") {
      this.element.requestSubmit();
    }
  }
}
