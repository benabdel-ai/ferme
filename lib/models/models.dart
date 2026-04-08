import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class Mouvement {
  final String id;
  final String type;
  final int qte;
  final DateTime date;
  final String remarque;
  final String fermeId;

  Mouvement({
    String? id,
    required this.type,
    required this.qte,
    required this.date,
    this.remarque = '',
    this.fermeId = 'rhamna',
  }) : id = id ?? _uuid.v4();

  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'type': type,
        'qte': qte,
        'date': date.toIso8601String().split('T').first,
        'remarque': remarque,
        'fermeId': fermeId,
      };

  factory Mouvement.fromMap(Map<String, dynamic> map) => Mouvement(
        id: map['id'] as String,
        type: map['type'] as String,
        qte: map['qte'] as int,
        date: DateTime.parse(map['date'] as String),
        remarque: (map['remarque'] ?? '') as String,
        fermeId: (map['fermeId'] ?? 'rhamna') as String,
      );

  String get label => movementTypeLabel(type);
  String get emoji => movementTypeEmoji(type);
  MvtColor get color => movementTypeColor(type);
  bool get isBirth => type.startsWith('naissance_');
  bool get isExit => type.startsWith('vente_') || type.startsWith('deces_');
  bool get isTransfer => type.startsWith('passage_');
  bool get isInitial => type.startsWith('init_');
}

enum MvtColor { green, red, blue, gold }

class HerdCategoryMeta {
  const HerdCategoryMeta({
    required this.id,
    required this.label,
    required this.shortLabel,
    required this.emoji,
    required this.color,
  });

  final String id;
  final String label;
  final String shortLabel;
  final String emoji;
  final MvtColor color;
}

const List<String> herdCategoryOrder = <String>[
  'femelles',
  'males',
  'agneaux_femelles',
  'agneaux_males',
];

const Map<String, HerdCategoryMeta> herdCategoryMetas = <String, HerdCategoryMeta>{
  'femelles': HerdCategoryMeta(
    id: 'femelles',
    label: 'Femelles',
    shortLabel: 'Brebis Sardi',
    emoji: '🐑',
    color: MvtColor.green,
  ),
  'males': HerdCategoryMeta(
    id: 'males',
    label: 'Males',
    shortLabel: 'Beliers Sardi',
    emoji: '🐏',
    color: MvtColor.blue,
  ),
  'agneaux_femelles': HerdCategoryMeta(
    id: 'agneaux_femelles',
    label: 'Agneaux femelles',
    shortLabel: 'Jeunes femelles Sardi',
    emoji: '🐣',
    color: MvtColor.gold,
  ),
  'agneaux_males': HerdCategoryMeta(
    id: 'agneaux_males',
    label: 'Agneaux males',
    shortLabel: 'Jeunes males Sardi',
    emoji: '🐥',
    color: MvtColor.red,
  ),
};

class HerdCategorySummary {
  const HerdCategorySummary({
    required this.meta,
    required this.total,
    required this.historyCount,
    required this.entries,
    required this.exits,
    required this.lastMovement,
  });

  final HerdCategoryMeta meta;
  final int total;
  final int historyCount;
  final int entries;
  final int exits;
  final Mouvement? lastMovement;

  String get id => meta.id;
}

class HerdMonthlySnapshot {
  const HerdMonthlySnapshot({
    required this.month,
    required this.total,
    required this.births,
    required this.outputs,
    required this.revenues,
    required this.expenses,
  });

  final DateTime month;
  final int total;
  final int births;
  final int outputs;
  final double revenues;
  final double expenses;
}

class Depense {
  final String id;
  final double montant;
  final DateTime date;
  final String categorie;
  final String remarque;
  final String fermeId;

  Depense({
    String? id,
    required this.montant,
    required this.date,
    required this.categorie,
    this.remarque = '',
    this.fermeId = 'rhamna',
  }) : id = id ?? _uuid.v4();

  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'montant': montant,
        'date': date.toIso8601String().split('T').first,
        'categorie': categorie,
        'remarque': remarque,
        'fermeId': fermeId,
      };

  factory Depense.fromMap(Map<String, dynamic> map) => Depense(
        id: map['id'] as String,
        montant: (map['montant'] as num).toDouble(),
        date: DateTime.parse(map['date'] as String),
        categorie: (map['categorie'] ?? '') as String,
        remarque: (map['remarque'] ?? '') as String,
        fermeId: (map['fermeId'] ?? 'rhamna') as String,
      );

  Depense copyWith({
    double? montant,
    DateTime? date,
    String? categorie,
    String? remarque,
    String? fermeId,
  }) =>
      Depense(
        id: id,
        montant: montant ?? this.montant,
        date: date ?? this.date,
        categorie: categorie ?? this.categorie,
        remarque: remarque ?? this.remarque,
        fermeId: fermeId ?? this.fermeId,
      );
}

class Revenu {
  final String id;
  final double montant;
  final DateTime date;
  final String categorie;
  final String remarque;
  final String fermeId;

  Revenu({
    String? id,
    required this.montant,
    required this.date,
    required this.categorie,
    this.remarque = '',
    this.fermeId = 'rhamna',
  }) : id = id ?? _uuid.v4();

  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'montant': montant,
        'date': date.toIso8601String().split('T').first,
        'categorie': categorie,
        'remarque': remarque,
        'fermeId': fermeId,
      };

  factory Revenu.fromMap(Map<String, dynamic> map) => Revenu(
        id: map['id'] as String,
        montant: (map['montant'] as num).toDouble(),
        date: DateTime.parse(map['date'] as String),
        categorie: (map['categorie'] ?? '') as String,
        remarque: (map['remarque'] ?? '') as String,
        fermeId: (map['fermeId'] ?? 'rhamna') as String,
      );

  Revenu copyWith({
    double? montant,
    DateTime? date,
    String? categorie,
    String? remarque,
    String? fermeId,
  }) =>
      Revenu(
        id: id,
        montant: montant ?? this.montant,
        date: date ?? this.date,
        categorie: categorie ?? this.categorie,
        remarque: remarque ?? this.remarque,
        fermeId: fermeId ?? this.fermeId,
      );
}

class Stock {
  final int femelles;
  final int males;
  final int agneauxF;
  final int agneauxM;

  const Stock({
    this.femelles = 0,
    this.males = 0,
    this.agneauxF = 0,
    this.agneauxM = 0,
  });

  int get total => femelles + males + agneauxF + agneauxM;

  int totalForCategory(String categoryId) {
    switch (categoryId) {
      case 'femelles':
        return femelles;
      case 'males':
        return males;
      case 'agneaux_femelles':
        return agneauxF;
      case 'agneaux_males':
        return agneauxM;
      default:
        return 0;
    }
  }

  Stock apply(String type, int qte) {
    var f = femelles;
    var m = males;
    var af = agneauxF;
    var am = agneauxM;

    switch (type) {
      case 'init_femelles':
      case 'achat_femelle':
        f += qte;
        break;
      case 'init_males':
      case 'achat_male':
        m += qte;
        break;
      case 'init_agf':
      case 'naissance_agf':
        af += qte;
        break;
      case 'init_agm':
      case 'naissance_agm':
        am += qte;
        break;
      case 'vente_femelle':
      case 'deces_femelle':
        f = (f - qte).clamp(0, 999999);
        break;
      case 'vente_male':
      case 'deces_male':
        m = (m - qte).clamp(0, 999999);
        break;
      case 'passage_agf':
        af = (af - qte).clamp(0, 999999);
        f += qte;
        break;
      case 'passage_agm':
        am = (am - qte).clamp(0, 999999);
        m += qte;
        break;
    }

    return Stock(femelles: f, males: m, agneauxF: af, agneauxM: am);
  }
}

const List<String> depCategories = <String>[
  'Alimentation',
  'Veterinaire',
  'Transport',
  'Achat betail',
  "Main-d'oeuvre",
  'Equipement',
  'Eau / Electricite',
  'Trituration',
  'Engrais / Produits',
  'Autre',
];

const List<String> revCategories = <String>[
  'Vente brebis',
  'Vente belier',
  'Vente agneau male',
  'Vente agneau femelle',
  "Vente huile d'olive",
  'Vente olives',
  'Vente luzerne',
  'Vente fruits',
  'Autre',
];

class AidMouton {
  final String id;
  final String numero;
  final String race;
  final double prixAchat;
  final double coutRevient;
  final bool sold;
  final bool reserved;
  final double prixVente;
  final String acheteur;
  final DateTime createdAt;
  final DateTime? reservedAt;
  final DateTime? soldAt;

  AidMouton({
    String? id,
    required this.numero,
    required this.race,
    required this.prixAchat,
    this.coutRevient = 0,
    this.sold = false,
    this.reserved = false,
    this.prixVente = 0,
    this.acheteur = '',
    DateTime? createdAt,
    this.reservedAt,
    this.soldAt,
  })  : id = id ?? _uuid.v4(),
        createdAt = createdAt ?? DateTime.now();

  double get coutTotal => prixAchat + coutRevient;
  double get benefice => prixVente - coutTotal;
  bool get isAvailable => !sold && !reserved;

  AidMouton copyWith({
    String? id,
    String? numero,
    String? race,
    double? prixAchat,
    double? coutRevient,
    bool? sold,
    bool? reserved,
    double? prixVente,
    String? acheteur,
    DateTime? createdAt,
    DateTime? reservedAt,
    DateTime? soldAt,
  }) {
    return AidMouton(
      id: id ?? this.id,
      numero: numero ?? this.numero,
      race: race ?? this.race,
      prixAchat: prixAchat ?? this.prixAchat,
      coutRevient: coutRevient ?? this.coutRevient,
      sold: sold ?? this.sold,
      reserved: reserved ?? this.reserved,
      prixVente: prixVente ?? this.prixVente,
      acheteur: acheteur ?? this.acheteur,
      createdAt: createdAt ?? this.createdAt,
      reservedAt: reservedAt ?? this.reservedAt,
      soldAt: soldAt ?? this.soldAt,
    );
  }

  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'numero': numero,
        'race': race,
        'prixAchat': prixAchat,
        'coutRevient': coutRevient,
        'sold': sold ? 1 : 0,
        'reserved': reserved ? 1 : 0,
        'prixVente': prixVente,
        'acheteur': acheteur,
        'createdAt': createdAt.toIso8601String(),
        'reservedAt': reservedAt?.toIso8601String(),
        'soldAt': soldAt?.toIso8601String(),
      };

  factory AidMouton.fromMap(Map<String, dynamic> map) => AidMouton(
        id: map['id'] as String,
        numero: map['numero'] as String,
        race: map['race'] as String,
        prixAchat: (map['prixAchat'] as num).toDouble(),
        coutRevient: (map['coutRevient'] as num? ?? 0).toDouble(),
        sold: (map['sold'] as int? ?? 0) == 1,
        reserved: (map['reserved'] as int? ?? 0) == 1,
        prixVente: (map['prixVente'] as num? ?? 0).toDouble(),
        acheteur: (map['acheteur'] ?? '') as String,
        createdAt: DateTime.parse(
          (map['createdAt'] ?? DateTime.now().toIso8601String()) as String,
        ),
        reservedAt:
            map['reservedAt'] != null && (map['reservedAt'] as String).isNotEmpty
                ? DateTime.parse(map['reservedAt'] as String)
                : null,
        soldAt: map['soldAt'] != null && (map['soldAt'] as String).isNotEmpty
            ? DateTime.parse(map['soldAt'] as String)
            : null,
      );
}

const List<String> aidRaces = <String>[
  'Sardi',
];

const List<(String, String)> movementTypeOptions = <(String, String)>[
  ('naissance_agf', 'Naissance agneau femelle'),
  ('naissance_agm', 'Naissance agneau male'),
  ('achat_femelle', 'Achat femelle'),
  ('achat_male', 'Achat male'),
  ('vente_femelle', 'Vente femelle'),
  ('vente_male', 'Vente male'),
  ('deces_femelle', 'Deces femelle'),
  ('deces_male', 'Deces male'),
  ('passage_agf', 'Passage agneau femelle vers femelle'),
  ('passage_agm', 'Passage agneau male vers male'),
  ('init_femelles', 'Stock initial femelles'),
  ('init_males', 'Stock initial males'),
  ('init_agf', 'Stock initial agneaux femelles'),
  ('init_agm', 'Stock initial agneaux males'),
];

String movementTypeLabel(String type) {
  switch (type) {
    case 'init_femelles':
      return 'Stock initial femelles';
    case 'init_males':
      return 'Stock initial males';
    case 'init_agf':
      return 'Stock initial agneaux femelles';
    case 'init_agm':
      return 'Stock initial agneaux males';
    case 'naissance_agf':
      return 'Naissance agneau femelle';
    case 'naissance_agm':
      return 'Naissance agneau male';
    case 'achat_femelle':
      return 'Achat femelle';
    case 'achat_male':
      return 'Achat male';
    case 'vente_femelle':
      return 'Vente femelle';
    case 'vente_male':
      return 'Vente male';
    case 'deces_femelle':
      return 'Deces femelle';
    case 'deces_male':
      return 'Deces male';
    case 'passage_agf':
      return 'Passage agneau femelle vers femelle';
    case 'passage_agm':
      return 'Passage agneau male vers male';
    default:
      return type;
  }
}

String movementTypeEmoji(String type) {
  switch (type) {
    case 'init_femelles':
      return '🐑';
    case 'init_males':
      return '🐏';
    case 'init_agf':
    case 'naissance_agf':
      return '🐣';
    case 'init_agm':
    case 'naissance_agm':
      return '🐥';
    case 'achat_femelle':
    case 'achat_male':
      return '🛒';
    case 'vente_femelle':
    case 'vente_male':
      return '💸';
    case 'deces_femelle':
    case 'deces_male':
      return '💀';
    case 'passage_agf':
    case 'passage_agm':
      return '🔄';
    default:
      return '📋';
  }
}

MvtColor movementTypeColor(String type) {
  switch (type) {
    case 'vente_femelle':
    case 'vente_male':
      return MvtColor.gold;
    case 'deces_femelle':
    case 'deces_male':
      return MvtColor.red;
    case 'achat_femelle':
    case 'achat_male':
    case 'passage_agf':
    case 'passage_agm':
      return MvtColor.blue;
    default:
      return MvtColor.green;
  }
}

int movementImpactForCategory(String categoryId, Mouvement mouvement) {
  switch (mouvement.type) {
    case 'init_femelles':
    case 'achat_femelle':
      return categoryId == 'femelles' ? mouvement.qte : 0;
    case 'init_males':
    case 'achat_male':
      return categoryId == 'males' ? mouvement.qte : 0;
    case 'init_agf':
    case 'naissance_agf':
      return categoryId == 'agneaux_femelles' ? mouvement.qte : 0;
    case 'init_agm':
    case 'naissance_agm':
      return categoryId == 'agneaux_males' ? mouvement.qte : 0;
    case 'vente_femelle':
    case 'deces_femelle':
      return categoryId == 'femelles' ? -mouvement.qte : 0;
    case 'vente_male':
    case 'deces_male':
      return categoryId == 'males' ? -mouvement.qte : 0;
    case 'passage_agf':
      if (categoryId == 'agneaux_femelles') return -mouvement.qte;
      if (categoryId == 'femelles') return mouvement.qte;
      return 0;
    case 'passage_agm':
      if (categoryId == 'agneaux_males') return -mouvement.qte;
      if (categoryId == 'males') return mouvement.qte;
      return 0;
    default:
      return 0;
  }
}

bool movementTouchesCategory(String categoryId, Mouvement mouvement) =>
    movementImpactForCategory(categoryId, mouvement) != 0;
