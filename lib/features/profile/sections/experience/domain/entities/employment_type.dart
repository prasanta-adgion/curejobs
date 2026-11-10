/// Employment types the API accepts for a position.
enum EmploymentType {
  fullTime('FULL_TIME', 'Full time'),
  partTime('PART_TIME', 'Part time'),
  contract('CONTRACT', 'Contract'),
  internship('INTERNSHIP', 'Internship'),
  temporary('TEMPORARY', 'Temporary');

  const EmploymentType(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static EmploymentType? fromApi(String? value) {
    for (final type in values) {
      if (type.apiValue == value) return type;
    }
    return null;
  }
}
