import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class L10nService extends ChangeNotifier {
  static const String _localeKey = 'locale';

  static const supportedLocales = {'zh': '中文', 'en': 'English'};

  Locale _locale = const Locale('zh');
  Locale get locale => _locale;

  bool _initialized = false;
  bool get initialized => _initialized;

  // ─────────────────────────────────────────────
  // Translation maps
  // ─────────────────────────────────────────────

  static const Map<String, String> _zh = {
    // App & Navigation
    'app_title': '宝宝记录',
    'home': '首页',
    'history': '历史',
    'stats': '统计',
    'settings': '设置',

    // Home screen
    'today': '今日',
    'quick_records': '快捷记录',
    'recent_feeding': '最近喂奶',
    'recent_diaper': '最近换尿布',
    'no_records_today': '今日暂无记录',
    'feeding': '喂奶',
    'milk_amount': '奶量',
    'diaper': '换尿布',
    'sleep': '睡眠',
    'ad_vitamin': 'AD',
    'd3_vitamin': 'D3',
    'sleeping': '睡眠中',
    'times': '次',
    'minutes': '分钟',

    // Feeding screen
    'feeding_record': '喂奶记录',
    'add_record': '新增记录',
    'breast_direct': '亲喂',
    'breast_bottle': '母乳瓶喂',
    'formula': '奶粉',
    'duration': '时长',
    'milk_amount_ml': '喝奶量 (ml)',
    'note_optional': '备注 (可选)',
    'note_hint': '如：厌奶/呛奶/精神好',
    'save_record': '保存记录',
    'start_timer': '开始计时',
    'stop_timer': '停止计时',
    'reset': '重置',
    'seconds': '秒',
    'breast_side': '喂养侧别',
    'left_side': '左侧',
    'right_side': '右侧',
    'switch_side': '换边',
    'completed_15min': '已完成 15 分钟',

    // Diaper screen
    'diaper_record': '换尿布记录',
    'pee': '小便',
    'poop': '大便',
    'both': '两者都有',
    'poop_color': '大便颜色',
    'poop_hint': '如：形状异常/血丝等',

    // Supplement screen
    'supplement': '营养补充',
    'today_supplement': '今日营养补充',
    'vitamin_ad': '维生素 AD',
    'vitamin_ad_desc': '促进骨骼发育、免疫力',
    'vitamin_d3': '维生素 D3',
    'vitamin_d3_desc': '促进钙吸收、预防佝偻病',
    'save': '保存',
    'tip': '小贴士',
    'tip_content': 'AD 和 D3 通常在宝宝出生后 15 天开始补充，建议在早上喂奶后服用。具体用量请遵医嘱。',

    // Sleep screen
    'sleep_record': '睡眠记录',
    'baby_sleeping': '宝宝正在睡觉 😴',
    'baby_awake': '宝宝醒着 ☀️',
    'has_slept': '已睡',
    'hours': '小时',
    'minutes2': '分钟',
    'start_record_sleep': '开始记录睡眠',
    'sleep_quality': '睡眠质量',
    'quality_good': '好',
    'quality_normal': '一般',
    'quality_crying': '哭闹',
    'wake_up': '醒来 - 结束睡眠',
    'sleep_history': '历史记录',
    'no_history': '暂无历史记录',
    'sleep_duration': '睡眠时长',
    'quality': '质量',

    // Growth screen
    'growth_record': '身高体重记录',
    'latest_record': '最新记录',
    'weight_kg': '体重 (kg)',
    'height_cm': '身长 (cm)',
    'head_cm': '头围 (cm)',
    'weight': '体重',
    'height': '身长',
    'head': '头围',
    'history_records': '历史记录',

    // Milestone screen
    'milestone': '里程碑 & 备忘',
    'milestone_tab': '🌟 里程碑',
    'hospital_tab': '🏥 就医',
    'vaccine_tab': '💉 疫苗',
    'title': '标题',
    'date': '日期',
    // Preset milestones
    'first_smile': '第一次微笑',
    'roll_over': '翻身',
    'sit_up': '独坐',
    'crawl': '爬行',
    'stand': '站立',
    'first_steps': '迈步走',
    'first_words': '叫爸爸妈妈',
    'teething': '长牙',
    'recognize_people': '认人',
    'stranger_anxiety': '认生',
    'checkup': '体检',
    'visit': '就诊',
    'review': '复查',
    'medicine': '用药',
    'vaccination': '疫苗接种',

    // History screen
    'history_title': '历史记录',
    'no_records': '当日无记录',
    'pee_poop': '小便/大便',

    // Stats screen
    'stats_title': '数据统计',
    'today_overview': '今日概况',
    'feeding_times': '喂奶次数',
    'total_milk': '总奶量',
    'diaper_count': '换尿布',
    'diaper_detail': '小便/大便',
    'sleep_duration2': '睡眠时长',
    'breast_duration': '母乳时长',
    'week_feeding_trend': '近7天喂奶次数',
    'week_diaper_trend': '近7天换尿布次数',
    'times2': '次',

    // Settings screen
    'baby_info': '宝宝信息',
    'baby_name': '宝宝姓名',
    'birth_date': '出生日期',
    'please_fill': '请填写宝宝姓名和出生日期',
    'saved': '已保存！',
    'language': '语言',
    'chinese': '中文',
    'english': 'English',
    'version': '版本',
    'about': '关于',
    'about_subtitle': '宝宝喂养记录 App — 用心陪伴每一步',
    'data_export': '数据导出 (开发中)',
    'data_export_desc': '导出 Excel 方便给医生查看',
    'dev_in_progress': '开发中',
    'about_app': '宝宝记录',
    'about_version': '1.0.0',
    'about_description': '记录宝宝成长每一步',
    'about_features': '功能: 喂奶 | 换尿布 | 睡眠 | 营养补充 | 生长发育 | 里程碑',

    // Weekdays
    'mon': '周一',
    'tue': '周二',
    'wed': '周三',
    'thu': '周四',
    'fri': '周五',
    'sat': '周六',
    'sun': '周日',

    // Age display
    'months': '个月',
    'years': '岁',
  };

  static const Map<String, String> _en = {
    // App & Navigation
    'app_title': 'Baby Tracker',
    'home': 'Home',
    'history': 'History',
    'stats': 'Stats',
    'settings': 'Settings',

    // Home screen
    'today': 'Today',
    'quick_records': 'Quick Add',
    'recent_feeding': 'Recent Feedings',
    'recent_diaper': 'Recent Diapers',
    'no_records_today': 'No records today',
    'feeding': 'Feeding',
    'milk_amount': 'Milk',
    'diaper': 'Diaper',
    'sleep': 'Sleep',
    'ad_vitamin': 'AD',
    'd3_vitamin': 'D3',
    'sleeping': 'Sleeping',
    'times': 'x',
    'minutes': 'min',

    // Feeding screen
    'feeding_record': 'Feeding Record',
    'add_record': 'Add Record',
    'breast_direct': 'Breast',
    'breast_bottle': 'Bottle (EBM)',
    'formula': 'Formula',
    'duration': 'Duration',
    'milk_amount_ml': 'Amount (ml)',
    'note_optional': 'Note (optional)',
    'note_hint': 'e.g. refused/sneezed/active',
    'save_record': 'Save Record',
    'start_timer': 'Start Timer',
    'stop_timer': 'Stop Timer',
    'reset': 'Reset',
    'seconds': 's',
    'breast_side': 'Side',
    'left_side': 'Left',
    'right_side': 'Right',
    'switch_side': 'Switch',
    'completed_15min': '15 min completed',

    // Diaper screen
    'diaper_record': 'Diaper Record',
    'pee': 'Wet',
    'poop': 'Dirty',
    'both': 'Both',
    'poop_color': 'Poop Color',
    'poop_hint': 'e.g. abnormal shape/blood',

    // Supplement screen
    'supplement': 'Supplements',
    'today_supplement': "Today's Supplements",
    'vitamin_ad': 'Vitamin AD',
    'vitamin_ad_desc': 'Bone & immune support',
    'vitamin_d3': 'Vitamin D3',
    'vitamin_d3_desc': 'Calcium absorption',
    'save': 'Save',
    'tip': '💡 Tip',
    'tip_content': 'AD & D3 usually start 15 days after birth, best taken after morning feed. Follow your doctor\'s advice.',

    // Sleep screen
    'sleep_record': 'Sleep Record',
    'baby_sleeping': 'Baby is sleeping 😴',
    'baby_awake': 'Baby is awake ☀️',
    'has_slept': 'Asleep for',
    'hours': 'h',
    'minutes2': 'm',
    'start_record_sleep': 'Start Sleep Record',
    'sleep_quality': 'Sleep Quality',
    'quality_good': 'Good',
    'quality_normal': 'Fair',
    'quality_crying': 'Fussy',
    'wake_up': 'Wake Up — End Sleep',
    'sleep_history': 'History',
    'no_history': 'No history yet',
    'sleep_duration': 'Duration',
    'quality': 'Quality',

    // Growth screen
    'growth_record': 'Growth Record',
    'latest_record': 'Latest',
    'weight_kg': 'Weight (kg)',
    'height_cm': 'Height (cm)',
    'head_cm': 'Head (cm)',
    'weight': 'Weight',
    'height': 'Height',
    'head': 'Head',
    'history_records': 'History',

    // Milestone screen
    'milestone': 'Milestones',
    'milestone_tab': '🌟 Milestone',
    'hospital_tab': '🏥 Medical',
    'vaccine_tab': '💉 Vaccine',
    'title': 'Title',
    'date': 'Date',
    // Preset milestones
    'first_smile': 'First Smile',
    'roll_over': 'Roll Over',
    'sit_up': 'Sit Up',
    'crawl': 'Crawl',
    'stand': 'Stand',
    'first_steps': 'First Steps',
    'first_words': 'First Words',
    'teething': 'Teething',
    'recognize_people': 'Recognizes Faces',
    'stranger_anxiety': 'Stranger Anxiety',
    'checkup': 'Checkup',
    'visit': 'Doctor Visit',
    'review': 'Follow-up',
    'medicine': 'Medication',
    'vaccination': 'Vaccination',

    // History screen
    'history_title': 'History',
    'no_records': 'No records',
    'pee_poop': 'Wet/Dirty',

    // Stats screen
    'stats_title': 'Statistics',
    'today_overview': "Today's Overview",
    'feeding_times': 'Feedings',
    'total_milk': 'Total Milk',
    'diaper_count': 'Diapers',
    'diaper_detail': 'Wet/Dirty',
    'sleep_duration2': 'Sleep',
    'breast_duration': 'Breastfeeding',
    'week_feeding_trend': 'Feeding (Last 7 Days)',
    'week_diaper_trend': 'Diapers (Last 7 Days)',
    'times2': 'x',

    // Settings screen
    'baby_info': 'Baby Info',
    'baby_name': 'Baby Name',
    'birth_date': 'Birth Date',
    'please_fill': 'Please fill in baby name and birth date',
    'saved': 'Saved!',
    'language': 'Language',
    'chinese': '中文',
    'english': 'English',
    'version': 'Version',
    'about': 'About',
    'about_subtitle': 'Baby Tracker —记录宝宝成长每一步',
    'data_export': 'Export Data (Coming Soon)',
    'data_export_desc': 'Export to Excel for doctor visits',
    'dev_in_progress': 'Coming Soon',
    'about_app': 'Baby Tracker',
    'about_version': '2.0.0',
    'about_description': 'Track every step of your baby\'s growth',
    'about_features': 'Features: Feeding | Diapers | Sleep | Supplements | Growth | Milestones',

    // Weekdays
    'mon': 'Mon',
    'tue': 'Tue',
    'wed': 'Wed',
    'thu': 'Thu',
    'fri': 'Fri',
    'sat': 'Sat',
    'sun': 'Sun',

    // Age display
    'months': 'mo',
    'years': 'yr',
  };

  // ─────────────────────────────────────────────
  // Init & locale management
  // ─────────────────────────────────────────────

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_localeKey);
    if (saved != null && supportedLocales.containsKey(saved)) {
      _locale = Locale(saved);
    }
    _initialized = true;
    notifyListeners();
  }

  Future<void> setLocale(String lang) async {
    if (!supportedLocales.containsKey(lang)) return;
    _locale = Locale(lang);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, lang);
    notifyListeners();
  }

  String t(String key) {
    final map = _locale.languageCode == 'en' ? _en : _zh;
    return map[key] ?? key;
  }
}
