import { Controller } from "@hotwired/stimulus";
import ClipboardJS from "clipboard";

export default class extends Controller {
  static values = {
    templateId: String,
  };

  connect() {
    this.clipboard = new ClipboardJS(this.element);
    const self = this;
    const html = document.getElementById(self.templateIdValue).innerHTML;

    this.clipboard.on("success", function (e) {
      if (!self.hasTemplateIdValue) {
        e.clearSelection();
        return;
      }

      Turbo.renderStreamMessage(`<turbo-stream action="append" target="flash_messages">
        <template>
          ${html}
        </template>
      </turbo-stream>`);

      e.clearSelection();
    });
  }
}
