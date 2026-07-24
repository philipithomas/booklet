import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  pasteHandler(event) {
    const pastedText = event.clipboardData?.getData?.("Text");
    if (
      !!pastedText &&
      !!pastedText.match(
        /^(https?:\/\/(?:www\.|(?!www))[^\s\.]+\.[^\s]{2,}|www\.[^\s]+\.[^\s]{2,})$/ig,
      )
    ) {
      this.pasteUrl(event.currentTarget.editor, pastedText);
    }
  }

  pasteUrl(editor, pastedText) {
    let displayText = pastedText.replace(/^(?:https?:\/\/)?(?:www\.)?/i, "")
      .replace(/\/$/, "");
    let currentText = editor.getDocument().toString();
    let currentSelection = editor.getSelectedRange();
    let textWeAreInterestedIn = currentText.substring(0, currentSelection[0]);

    let startOfPastedText = textWeAreInterestedIn.lastIndexOf(pastedText);
    editor.recordUndoEntry("Auto Link Paste");
    editor.setSelectedRange([startOfPastedText, currentSelection[0]]);
    editor.activateAttribute("href", pastedText);
    editor.insertString(displayText);
    editor.setSelectedRange(currentSelection);
  }
}
