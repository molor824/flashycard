String? Function(String?) emptyFieldValidator(String fieldName) {
  return (value) {
    if (value == null || value.isEmpty) {
      return "Please enter $fieldName";
    }
    return null;
  };
}
