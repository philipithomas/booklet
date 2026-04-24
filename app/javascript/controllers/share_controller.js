import { Controller } from "@hotwired/stimulus";
import ClipboardJS from "clipboard";

export default class extends Controller {
  static values = {
    title: String,
    text: String,
    url: String,
    shareableLabel: String,
    copySuccessMessage: String,
    copyErrorMessage: String,
    shareErrorMessage: String,
  };

  connect() {
    if (navigator.canShare) {
      this.element.textContent = this.shareableLabelValue;
      this.element.addEventListener("click", () => this.share());
    } else {
      // If canShare is not available, the text remains unchanged and the clipboard functionality is set up
      this.clipboard = new ClipboardJS(this.element, {
        text: () => this.urlValue,
      });

      this.clipboard.on("success", (e) => {
        this.showMessage(this.copySuccessMessageValue);
        e.clearSelection();
      });

      this.clipboard.on("error", (e) => {
        this.showMessage(this.copyErrorMessageValue);
      });
    }
  }

  async share() {
    try {
      await navigator.share({
        title: this.titleValue,
        text: this.textValue,
        url: this.urlValue,
      });
    } catch (error) {
      this.showMessage(this.shareErrorMessageValue.replace("%error%", error));
    }
  }

  showMessage(message) {
    const template = document.getElementById("js-flash-template").innerHTML;
    const messageFormatted = template.replace("MESSAGE", message);
    Turbo.renderStreamMessage(
      `<turbo-stream action="append" target="flash_messages">
      <template>
        ${messageFormatted}
      </template>
    </turbo-stream>`,
    );
  }

  disconnect() {
    if (this.clipboard) {
      this.clipboard.destroy();
    }
  }
}
