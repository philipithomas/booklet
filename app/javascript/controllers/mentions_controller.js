import { Controller } from "@hotwired/stimulus";
import Tribute from "tributejs";
import Trix from "trix";

export default class extends Controller {
  static targets = ["field"];

  connect() {
    this.initializeTribute();
    this.disableMentionLinks();
  }

  disconnect() {
    this.tribute.detach(this.fieldTarget);
    this.enableMentionLinks();
  }

  initializeTribute() {
    this.tribute = new Tribute({
      allowSpaces: true,
      lookup: "name",
      values: this.fetchMembers,
    });
    this.tribute.attach(this.fieldTarget);
    this.tribute.range.pasteHtml = this._pasteHtml.bind(this);
    this.fieldTarget.addEventListener("tribute-replaced", this.replaced);
  }

  disableMentionLinks() {
    this.fieldTarget.addEventListener("click", this.interceptMentionClick);
  }

  enableMentionLinks() {
    this.fieldTarget.removeEventListener("click", this.interceptMentionClick);
  }

  interceptMentionClick(event) {
    if (event.target.closest(".mention")) {
      event.preventDefault();
    }
  }

  fetchMembers(text, callback) {
    fetch(`/mentions.json?query=${text}`)
      .then((response) => response.json())
      .then((members) => callback(members))
      .catch((error) => callback([]));
  }

  replaced(e) {
    let mention = e.detail.item.original;
    let attachment = new Trix.Attachment({
      sgid: mention.sgid,
      content: mention.content,
    });
    e.target.editor.insertAttachment(attachment);
    e.target.editor.insertString(" ");
  }

  _pasteHtml(html, startPos, endPos) {
    let position = this.fieldTarget.editor.getPosition();
    this.fieldTarget.editor.setSelectedRange([
      position - endPos + startPos,
      position + 1,
    ]);

    this.fieldTarget.editor.deleteInDirection("backward");
  }
}
