import 'package:equatable/equatable.dart';

/// UI-only models for the candidate profile. Replace with domain entities
/// once the profile API is wired up.
class CandidateProfile extends Equatable {
  const CandidateProfile({
    required this.name,
    required this.initials,
    required this.headline,
    required this.location,
    required this.experienceLabel,
    required this.qualification,
    required this.about,
    required this.stats,
    required this.skills,
    required this.experience,
    required this.education,
    this.cv,
    this.isVerified = false,
    this.tip,
  });

  final String name;
  final String initials;
  final String headline;
  final String location;
  final String experienceLabel;
  final String qualification;
  final String about;
  final ProfileStats stats;
  final List<String> skills;
  final List<ProfileExperience> experience;
  final List<ProfileEducation> education;
  final ProfileCv? cv;
  final bool isVerified;
  final String? tip;

  ProfileExperience? get currentRole {
    for (final item in experience) {
      if (item.isCurrent) return item;
    }
    return null;
  }

  @override
  List<Object?> get props => [
    name,
    initials,
    headline,
    location,
    experienceLabel,
    qualification,
    about,
    stats,
    skills,
    experience,
    education,
    cv,
    isVerified,
    tip,
  ];
}

class ProfileStats extends Equatable {
  const ProfileStats({
    required this.views,
    required this.applied,
    required this.shortlisted,
  });

  final int views;
  final int applied;
  final int shortlisted;

  @override
  List<Object?> get props => [views, applied, shortlisted];
}

class ProfileExperience extends Equatable {
  const ProfileExperience({
    required this.role,
    required this.employer,
    required this.period,
    required this.duration,
    this.employmentType,
    this.description,
    this.isCurrent = false,
  });

  final String role;
  final String employer;
  final String period;
  final String duration;
  final String? employmentType;
  final String? description;
  final bool isCurrent;

  @override
  List<Object?> get props => [
    role,
    employer,
    period,
    duration,
    employmentType,
    description,
    isCurrent,
  ];
}

class ProfileEducation extends Equatable {
  const ProfileEducation({
    required this.degree,
    required this.institution,
    required this.period,
    this.score,
  });

  final String degree;
  final String institution;
  final String period;
  final String? score;

  @override
  List<Object?> get props => [degree, institution, period, score];
}

class ProfileCv extends Equatable {
  const ProfileCv({
    required this.fileName,
    required this.sizeLabel,
    required this.pages,
    required this.updatedLabel,
    this.isVisibleToRecruiters = true,
  });

  final String fileName;
  final String sizeLabel;
  final int pages;
  final String updatedLabel;
  final bool isVisibleToRecruiters;

  @override
  List<Object?> get props => [
    fileName,
    sizeLabel,
    pages,
    updatedLabel,
    isVisibleToRecruiters,
  ];
}

/// Placeholder content shown until real data is available.
abstract final class ProfileSampleData {
  static const candidate = CandidateProfile(
    name: 'Priya Sharma',
    initials: 'PS',
    headline: 'Staff nurse, Intensive care unit',
    location: 'Kolkata',
    experienceLabel: '4 yrs',
    qualification: 'B.Sc Nursing',
    isVerified: true,
    about:
        'ICU nurse with 4 years in critical care, ventilator management and '
        'patient monitoring at leading Kolkata hospitals.',
    stats: ProfileStats(views: 48, applied: 6, shortlisted: 2),
    skills: ['Critical care', 'Ventilator care', 'IV therapy', 'BLS / ACLS'],
    experience: [
      ProfileExperience(
        role: 'Staff nurse, ICU',
        employer: 'Apollo Gleneagles Hospital',
        period: 'Jun 2022 – Present',
        duration: '2 yrs 5 mos',
        employmentType: 'Full-time',
        description:
            'Care for a 6-bed ICU, ventilator management and new staff '
            'training.',
        isCurrent: true,
      ),
      ProfileExperience(
        role: 'Junior nurse',
        employer: 'AMRI Hospitals',
        period: 'Jul 2020 – May 2022',
        duration: '1 yr 11 mos',
        employmentType: 'Full-time',
      ),
    ],
    education: [
      ProfileEducation(
        degree: 'B.Sc Nursing',
        institution: 'WB University of Health Sciences',
        period: '2016 – 2020',
        score: '78%',
      ),
      ProfileEducation(
        degree: 'Higher secondary (Science)',
        institution: 'WBCHSE',
        period: '2014 – 2016',
        score: '84%',
      ),
    ],
    cv: ProfileCv(
      fileName: 'Priya_Sharma_CV.pdf',
      sizeLabel: '240 KB',
      pages: 2,
      updatedLabel: 'Updated 2 days ago',
    ),
    tip: 'Renew BLS / ACLS before May to stay eligible for ICU roles.',
  );
}
