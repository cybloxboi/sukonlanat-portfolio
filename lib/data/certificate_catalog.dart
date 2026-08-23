import 'package:flutter/material.dart';
import 'package:sukonlanat_portfolio/models/award_categories.dart';
import 'package:sukonlanat_portfolio/models/certificate_model.dart';
import 'package:sukonlanat_portfolio/models/competition_level.dart';

const certificateImageUrl =
    'https://images.unsplash.com/photo-1590372648787-fa5a935c2c40?fm=jpg&q=60&w=3000&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxleHBsb3JlLWZlZWR8MXx8fGVufDB8fHx8fA%3D%3D';

final certificateCatalog = List<CertificateModel>.unmodifiable([
  CertificateModel(
    id: 'certificate-0',
    name: 'การแข่งขันพัฒนาซอฟต์แวร์แห่งประเทศไทยครั้งที่ 27',
    backgroundUrl: certificateImageUrl,
    description: 'รายละเอียดการแข่งขันและผลงานพัฒนาซอฟต์แวร์',
    organizer: 'สมาคมอุตสาหกรรมเทคโนโลยีสารสนเทศไทย',
    awardCategories: AwardCategories(
      name: 'รางวัลชนะเลิศ',
      color: Color(0xFFFFC107),
    ),
    competitionLevel: CompetitionLevel(
      name: 'ระดับประเทศ',
      color: Color(0xFF42A5F5),
    ),
  ),
  CertificateModel(
    id: 'certificate-1',
    name: 'รางวัลชนะเลิศการพัฒนาแอปพลิเคชัน',
    backgroundUrl: certificateImageUrl,
    description: 'ผลงานการออกแบบและพัฒนาแอปพลิเคชัน',
    organizer: 'คณะกรรมการจัดการแข่งขัน',
    awardCategories: AwardCategories(
      name: 'รางวัลชนะเลิศ',
      color: Color(0xFF66BB6A),
    ),
    competitionLevel: CompetitionLevel(
      name: 'ระดับภาค',
      color: Color(0xFFAB47BC),
    ),
  ),
  CertificateModel(
    id: 'certificate-2',
    name: 'เข้าร่วมค่ายโอลิมปิกวิชาการ สอวน.',
    backgroundUrl:
        'https://upload.wikimedia.org/wikipedia/commons/d/d3/July_night_sky_%2835972569256%29.jpg?utm_source=en.wikipedia.org&utm_campaign=index&utm_content=original',
    description: 'เข้าร่วมกิจกรรมค่ายโอลิมปิกวิชาการ สาขาคอมพิวเตอร์',
    organizer: 'มูลนิธิส่งเสริมโอลิมปิกวิชาการ',
    awardCategories: AwardCategories(
      name: 'เข้าร่วมกิจกรรม',
      color: Color(0xFFEF5350),
    ),
    competitionLevel: CompetitionLevel(
      name: 'ระดับค่าย',
      color: Color(0xFFFFC107),
    ),
  ),
  CertificateModel(
    id: 'certificate-3',
    name: 'ผ่านการอบรมด้าน Mobile Application',
    backgroundUrl: certificateImageUrl,
    description: 'อบรมการพัฒนา Mobile Application ด้วย Flutter',
    organizer: 'Flutter Community Thailand',
    awardCategories: AwardCategories(
      name: 'ผ่านการอบรม',
      color: Color(0xFF42A5F5),
    ),
    competitionLevel: CompetitionLevel(
      name: 'ระดับอบรม',
      color: Color(0xFF66BB6A),
    ),
  ),
  CertificateModel(
    id: 'certificate-4',
    name: 'ผลงานและกิจกรรมด้านเทคโนโลยี',
    backgroundUrl: certificateImageUrl,
    description: 'รวบรวมผลงานและกิจกรรมด้านเทคโนโลยีสารสนเทศ',
    organizer: 'ชมรมคอมพิวเตอร์',
    awardCategories: AwardCategories(
      name: 'ผลงานเด่น',
      color: Color(0xFFAB47BC),
    ),
    competitionLevel: CompetitionLevel(
      name: 'ระดับโรงเรียน',
      color: Color(0xFFEF5350),
    ),
  ),
]);

CertificateModel certificateById(String id) {
  return certificateCatalog.firstWhere(
    (certificate) => certificate.id == id,
    orElse: () => certificateCatalog.first,
  );
}
