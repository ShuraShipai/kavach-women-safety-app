class ReportValidation {
  static const maxNoteLength = 240;

  static bool isValidNote(String value) => value.trim().length <= maxNoteLength;
}
