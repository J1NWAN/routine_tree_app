import 'package:hive/hive.dart';

part 'tree_progress.g.dart';

@HiveType(typeId: 4)
class TreeProgress extends HiveObject {
  @HiveField(0)
  String routineId;

  @HiveField(1)
  int level; // 나무 레벨 (1~10)

  @HiveField(2)
  int experience; // 현재 경험치

  @HiveField(3)
  int experienceToNext; // 다음 레벨까지 필요 경험치

  @HiveField(4)
  TreeType treeType; // 나무 종류

  @HiveField(5)
  List<String> collectedFruits; // 수집한 열매들

  @HiveField(6)
  List<String> collectedLeaves; // 수집한 잎들

  @HiveField(7)
  DateTime lastUpdated;

  @HiveField(8)
  SeasonType currentSeason; // 현재 계절

  TreeProgress({
    required this.routineId,
    this.level = 1,
    this.experience = 0,
    this.experienceToNext = 10,
    this.treeType = TreeType.oak,
    this.collectedFruits = const [],
    this.collectedLeaves = const [],
    required this.lastUpdated,
    this.currentSeason = SeasonType.spring,
  });

  // 경험치 추가 및 레벨업 확인
  bool addExperience(int exp) {
    experience += exp;

    if (experience >= experienceToNext && level < 10) {
      level++;
      experience -= experienceToNext;
      experienceToNext = level * 15; // 레벨업할 때마다 필요 경험치 증가
      return true; // 레벨업 발생
    }
    return false;
  }

  // 진행률 계산 (0.0 ~ 1.0)
  double get progressToNext {
    if (level >= 10) return 1.0;
    return experience / experienceToNext;
  }

  // 나무 성장 단계 계산
  TreeGrowthStage get growthStage {
    if (level <= 2) return TreeGrowthStage.seedling;
    if (level <= 4) return TreeGrowthStage.young;
    if (level <= 6) return TreeGrowthStage.growing;
    if (level <= 8) return TreeGrowthStage.mature;
    return TreeGrowthStage.ancient;
  }

  // 계절 업데이트
  void updateSeason() {
    final now = DateTime.now();
    final month = now.month;

    if (month >= 3 && month <= 5) {
      currentSeason = SeasonType.spring;
    } else if (month >= 6 && month <= 8) {
      currentSeason = SeasonType.summer;
    } else if (month >= 9 && month <= 11) {
      currentSeason = SeasonType.autumn;
    } else {
      currentSeason = SeasonType.winter;
    }
  }
}

@HiveType(typeId: 5)
enum TreeType {
  @HiveField(0)
  oak, // 참나무

  @HiveField(1)
  pine, // 소나무

  @HiveField(2)
  cherry, // 벚나무

  @HiveField(3)
  maple, // 단풍나무

  @HiveField(4)
  willow, // 버드나무
}

@HiveType(typeId: 6)
enum SeasonType {
  @HiveField(0)
  spring, // 봄

  @HiveField(1)
  summer, // 여름

  @HiveField(2)
  autumn, // 가을

  @HiveField(3)
  winter, // 겨울
}

@HiveType(typeId: 7)
enum TreeGrowthStage {
  @HiveField(0)
  seedling, // 새싹

  @HiveField(1)
  young, // 어린나무

  @HiveField(2)
  growing, // 성장중

  @HiveField(3)
  mature, // 성숙한 나무

  @HiveField(4)
  ancient, // 거대한 나무
}
