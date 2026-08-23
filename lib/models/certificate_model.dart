import 'package:sukonlanat_portfolio/models/award_categories.dart';
import 'package:sukonlanat_portfolio/models/competition_level.dart';

class CertificateModel {
  final String id;
  final String name;
  final String backgroundUrl;
  final String description;
  final String organizer;
  final AwardCategories awardCategories;
  final CompetitionLevel competitionLevel;

  CertificateModel({
    required this.id,
    required this.name,
    required this.description,
    required this.organizer,
    required this.awardCategories,
    required this.competitionLevel,
    required this.backgroundUrl,
  });
}
