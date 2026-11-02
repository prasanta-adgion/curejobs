/// Options for the dashboard job filters, in display order.
enum JobType {
  fullTime('Full-time'),
  partTime('Part-time'),
  contract('Contract'),
  temporary('Temporary'),
  internship('Internship'),
  freelance('Freelance');

  const JobType(this.label);

  final String label;
}

enum ExperienceLevel {
  fresher('Fresher'),
  oneToThree('1–3 years'),
  threeToFive('3–5 years'),
  fivePlus('5+ years');

  const ExperienceLevel(this.label);

  final String label;
}

enum DatePosted {
  last24Hours('Last 24 hours'),
  last3Days('Last 3 days'),
  last7Days('Last 7 days'),
  last14Days('Last 14 days');

  const DatePosted(this.label);

  final String label;
}
