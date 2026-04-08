import 'package:flutter/foundation.dart';

import '../models/ferme_models.dart';
import '../models/models.dart';
import '../services/database_service.dart';

class AppProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;

  bool loading = true;
  String fermeFilter = 'all';

  List<Mouvement> mouvements = <Mouvement>[];
  List<Depense> depenses = <Depense>[];
  List<Revenu> revenus = <Revenu>[];
  List<Recolte> recoltes = <Recolte>[];
  List<Trituration> triturations = <Trituration>[];
  List<TravailleurSession> travailleurSessions = <TravailleurSession>[];
  List<RecurringExpense> recurringExpenses = <RecurringExpense>[];

  List<AppCategory> depCategories = <AppCategory>[];
  List<AppCategory> revCategories = <AppCategory>[];
  List<AppCategory> cultureCategories = <AppCategory>[];

  List<String> get depCatLabels => depCategories.map((c) => c.label).toList();
  List<String> get revCatLabels => revCategories
      .where((c) => !_containsExcludedSpecies(c.label))
      .map((c) => c.label)
      .toList();
  List<String> get cultureCatLabels => cultureCategories.map((c) => c.label).toList();

  Future<void> init() async => load();

  Future<void> load() async {
    loading = true;
    notifyListeners();

    mouvements = await _db.getMouvements();
    depenses = await _db.getDepenses();
    revenus = await _db.getRevenus();
    recoltes = await _db.getRecoltes();
    triturations = await _db.getTriturations();
    travailleurSessions = await _db.getTravailleurSessions();
    recurringExpenses = await _db.getRecurringExpenses();
    depCategories = await _db.getCategories('depense');
    revCategories = await _db.getCategories('revenu');
    cultureCategories = await _db.getCategories('culture');

    loading = false;
    notifyListeners();
  }

  void setFermeFilter(String filter) {
    fermeFilter = filter;
    notifyListeners();
  }

  List<Depense> get depensesFiltrees => fermeFilter == 'all'
      ? depenses
      : depenses.where((d) => d.fermeId == fermeFilter).toList();

  List<Revenu> get revenusFiltres => fermeFilter == 'all'
      ? revenus
      : revenus.where((r) => r.fermeId == fermeFilter).toList();

  List<Recolte> get recoltesFiltrees => fermeFilter == 'all'
      ? recoltes
      : recoltes.where((r) => r.fermeId == fermeFilter).toList();

  List<Trituration> get triturationsFiltrees => fermeFilter == 'all'
      ? triturations
      : triturations.where((t) => t.fermeId == fermeFilter).toList();

  List<TravailleurSession> get sessionsFiltrees => fermeFilter == 'all'
      ? travailleurSessions
      : travailleurSessions.where((s) => s.fermeId == fermeFilter).toList();

  List<RecurringExpense> get recurringFiltrees => fermeFilter == 'all'
      ? recurringExpenses
      : recurringExpenses.where((r) => r.fermeId == fermeFilter).toList();

  List<Mouvement> get herdMouvements =>
      mouvements.where((m) => m.fermeId == 'rhamna').toList();

  Stock get stock {
    var current = const Stock();
    for (final mouvement in herdMouvements) {
      current = current.apply(mouvement.type, mouvement.qte);
    }
    return current;
  }

  int get totalAnimals => stock.total;

  int get birthsCount => herdMouvements
      .where((m) => m.isBirth)
      .fold(0, (sum, item) => sum + item.qte);

  int get outputsCount => herdMouvements
      .where((m) => m.isExit)
      .fold(0, (sum, item) => sum + item.qte);

  List<HerdCategorySummary> get herdCategories {
    return herdCategoryOrder.map((categoryId) {
      final meta = herdCategoryMetas[categoryId]!;
      final related = herdMouvements
          .where((mouvement) => movementTouchesCategory(categoryId, mouvement))
          .toList();
      final total = related.fold<int>(
        0,
        (sum, mouvement) => sum + movementImpactForCategory(categoryId, mouvement),
      );
      final entries = related.fold<int>(
        0,
        (sum, mouvement) {
          final delta = movementImpactForCategory(categoryId, mouvement);
          return sum + (delta > 0 ? delta : 0);
        },
      );
      final exits = related.fold<int>(
        0,
        (sum, mouvement) {
          final delta = movementImpactForCategory(categoryId, mouvement);
          return sum + (delta < 0 ? -delta : 0);
        },
      );
      return HerdCategorySummary(
        meta: meta,
        total: total,
        historyCount: related.length,
        entries: entries,
        exits: exits,
        lastMovement: related.isEmpty ? null : related.last,
      );
    }).toList();
  }

  HerdCategorySummary herdCategoryById(String categoryId) {
    return herdCategories.firstWhere(
      (category) => category.id == categoryId,
      orElse: () => herdCategories.first,
    );
  }

  List<Mouvement> herdCategoryHistory(String categoryId) {
    final related = herdMouvements
        .where((mouvement) => movementTouchesCategory(categoryId, mouvement))
        .toList();
    return related.reversed.toList();
  }

  List<Mouvement> get recentHerdMovements =>
      herdMouvements.reversed.take(8).toList();

  List<Revenu> get sheepRevenues => revenus
      .where((revenu) => revenu.fermeId == 'rhamna')
      .where(_isSheepRevenue)
      .toList();

  List<Depense> get sheepExpenses => depenses
      .where((depense) => depense.fermeId == 'rhamna')
      .where(_isSheepExpense)
      .toList();

  double get sheepRevenueTotal =>
      sheepRevenues.fold<double>(0, (sum, item) => sum + item.montant);

  double get sheepExpenseTotal =>
      sheepExpenses.fold<double>(0, (sum, item) => sum + item.montant);

  double get sheepBalance => sheepRevenueTotal - sheepExpenseTotal;

  double sheepRevenueForMonth(DateTime month) => sheepRevenues
      .where((item) => item.date.year == month.year && item.date.month == month.month)
      .fold<double>(0, (sum, item) => sum + item.montant);

  double sheepExpenseForMonth(DateTime month) => sheepExpenses
      .where((item) => item.date.year == month.year && item.date.month == month.month)
      .fold<double>(0, (sum, item) => sum + item.montant);

  List<HerdMonthlySnapshot> get herdMonthlyReport {
    final now = DateTime.now();
    return List<HerdMonthlySnapshot>.generate(6, (index) {
      final month = DateTime(now.year, now.month - 5 + index, 1);
      final endOfMonth = DateTime(month.year, month.month + 1, 0);

      var stockAtMonth = const Stock();
      var births = 0;
      var outputs = 0;

      for (final mouvement in herdMouvements) {
        if (!mouvement.date.isAfter(endOfMonth)) {
          stockAtMonth = stockAtMonth.apply(mouvement.type, mouvement.qte);
          if (mouvement.isBirth &&
              mouvement.date.year == month.year &&
              mouvement.date.month == month.month) {
            births += mouvement.qte;
          }
          if (mouvement.isExit &&
              mouvement.date.year == month.year &&
              mouvement.date.month == month.month) {
            outputs += mouvement.qte;
          }
        }
      }

      return HerdMonthlySnapshot(
        month: month,
        total: stockAtMonth.total,
        births: births,
        outputs: outputs,
        revenues: sheepRevenueForMonth(month),
        expenses: sheepExpenseForMonth(month),
      );
    });
  }

  double get totalDepenses =>
      depensesFiltrees.fold(0, (sum, item) => sum + item.montant);

  double get totalRevenus =>
      revenusFiltres.fold<double>(0, (sum, item) => sum + item.montant);

  double get bilan => totalRevenus - totalDepenses;

  double depensesMois(DateTime month) => depensesFiltrees
      .where((d) => d.date.year == month.year && d.date.month == month.month)
      .fold<double>(0, (sum, item) => sum + item.montant);

  double revenusMois(DateTime month) => revenusFiltres
      .where((r) => r.date.year == month.year && r.date.month == month.month)
      .fold<double>(0, (sum, item) => sum + item.montant);

  double revenusGlobauxMois(DateTime month) => revenusMois(month);

  List<Map<String, dynamic>> get last6MonthsData {
    return herdMonthlyReport.map((snapshot) {
      return <String, dynamic>{
        'month': snapshot.month,
        'total': snapshot.total,
        'depenses': snapshot.expenses,
        'revenus': snapshot.revenues,
      };
    }).toList();
  }

  Map<String, double> depensesByCategorie() {
    final result = <String, double>{};
    for (final item in depensesFiltrees) {
      result[item.categorie] = (result[item.categorie] ?? 0) + item.montant;
    }
    return Map.fromEntries(
      result.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
    );
  }

  Map<String, double> revenusByCategorie() {
    final result = <String, double>{};
    for (final item in revenusFiltres) {
      if (_containsExcludedSpecies('${item.categorie} ${item.remarque}')) {
        continue;
      }
      result[item.categorie] = (result[item.categorie] ?? 0) + item.montant;
    }
    return Map.fromEntries(
      result.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
    );
  }

  Future<void> addMouvement(Mouvement mouvement) async {
    await _db.insertMouvement(mouvement);
    mouvements = await _db.getMouvements();
    notifyListeners();
  }

  Future<void> deleteMouvement(String id) async {
    await _db.deleteMouvement(id);
    mouvements.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  Future<void> addDepense(Depense depense) async {
    await _db.insertDepense(depense);
    depenses = await _db.getDepenses();
    notifyListeners();
  }

  Future<void> deleteDepense(String id) async {
    await _db.deleteDepense(id);
    depenses.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  Future<void> updateDepense(Depense depense) async {
    await _db.updateDepense(depense);
    depenses = await _db.getDepenses();
    notifyListeners();
  }

  Future<void> addRevenu(Revenu revenu) async {
    await _db.insertRevenu(revenu);
    revenus = await _db.getRevenus();
    notifyListeners();
  }

  Future<void> deleteRevenu(String id) async {
    await _db.deleteRevenu(id);
    revenus.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  Future<void> updateRevenu(Revenu revenu) async {
    await _db.updateRevenu(revenu);
    revenus = await _db.getRevenus();
    notifyListeners();
  }

  Future<void> addRecolte(Recolte recolte) async {
    await _db.insertRecolte(recolte);
    recoltes = await _db.getRecoltes();
    notifyListeners();
  }

  Future<void> deleteRecolte(String id) async {
    await _db.deleteRecolte(id);
    recoltes.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  Future<void> updateRecolte(Recolte recolte) async {
    await _db.updateRecolte(recolte);
    recoltes = await _db.getRecoltes();
    notifyListeners();
  }

  Future<void> addTrituration(Trituration t) async {
    await _db.insertTrituration(t);

    if (t.coutTrituration > 0) {
      await _db.insertDepense(Depense(
        montant: t.coutTrituration,
        date: t.date,
        categorie: 'Trituration',
        remarque: 'Moulin ${t.saison} · ${t.kgOlives.toStringAsFixed(0)} kg olives',
        fermeId: t.fermeId,
      ));
      depenses = await _db.getDepenses();
    }

    if (t.revenusVente > 0) {
      await _db.insertRevenu(Revenu(
        montant: t.revenusVente,
        date: t.date,
        categorie: "Vente huile d'olive",
        remarque:
            '${t.litresVente.toStringAsFixed(1)} L x ${t.prixVenteLitre.toStringAsFixed(0)} MAD/L',
        fermeId: t.fermeId,
      ));
      revenus = await _db.getRevenus();
    }

    triturations = await _db.getTriturations();
    notifyListeners();
  }

  Future<void> deleteTrituration(String id) async {
    await _db.deleteTrituration(id);
    triturations.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  Future<void> updateTrituration(Trituration t) async {
    await _db.updateTrituration(t);
    triturations = await _db.getTriturations();
    notifyListeners();
  }

  Future<void> addTravailleurSession(TravailleurSession session) async {
    await _db.insertTravailleurSession(session);

    await _db.insertDepense(Depense(
      montant: session.total,
      date: session.date,
      categorie: "Main-d'oeuvre",
      remarque:
          '${session.nom} · ${session.nbJours.toStringAsFixed(1)} j x ${session.salaireJournalier.toStringAsFixed(0)} MAD',
      fermeId: session.fermeId,
    ));
    depenses = await _db.getDepenses();

    travailleurSessions = await _db.getTravailleurSessions();
    notifyListeners();
  }

  Future<void> deleteTravailleurSession(String id) async {
    await _db.deleteTravailleurSession(id);
    travailleurSessions.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  Future<void> updateTravailleurSession(TravailleurSession session) async {
    await _db.updateTravailleurSession(session);
    travailleurSessions = await _db.getTravailleurSessions();
    notifyListeners();
  }

  Future<void> addRecurringExpense(RecurringExpense expense) async {
    await _db.insertRecurringExpense(expense);
    recurringExpenses = await _db.getRecurringExpenses();
    notifyListeners();
  }

  Future<void> toggleRecurringExpense(RecurringExpense expense) async {
    final updated = expense.copyWith(actif: !expense.actif);
    await _db.updateRecurringExpense(updated);
    recurringExpenses = await _db.getRecurringExpenses();
    notifyListeners();
  }

  Future<void> deleteRecurringExpense(String id) async {
    await _db.deleteRecurringExpense(id);
    recurringExpenses.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  Future<void> payRecurring(RecurringExpense expense) async {
    final updated = expense.copyWith(lastPaidAt: DateTime.now());
    await _db.updateRecurringExpense(updated);

    await _db.insertDepense(Depense(
      montant: expense.montant,
      date: DateTime.now(),
      categorie: "Main-d'oeuvre",
      remarque: expense.label,
      fermeId: expense.fermeId,
    ));

    depenses = await _db.getDepenses();
    recurringExpenses = await _db.getRecurringExpenses();
    notifyListeners();
  }

  Future<void> addCategory(AppCategory category) async {
    await _db.insertCategory(category);
    await _reloadCategories();
  }

  Future<void> updateCategory(AppCategory category) async {
    await _db.updateCategory(category);
    await _reloadCategories();
  }

  Future<void> deleteCategory(String id) async {
    await _db.deleteCategory(id);
    await _reloadCategories();
  }

  Future<void> exportDatabase() => _db.exportDatabase();

  Future<void> clearAll() async {
    await _db.clearAll();
    mouvements = <Mouvement>[];
    depenses = <Depense>[];
    revenus = <Revenu>[];
    recoltes = <Recolte>[];
    triturations = <Trituration>[];
    travailleurSessions = <TravailleurSession>[];
    recurringExpenses = <RecurringExpense>[];
    notifyListeners();
  }

  Future<void> _reloadCategories() async {
    depCategories = await _db.getCategories('depense');
    revCategories = await _db.getCategories('revenu');
    cultureCategories = await _db.getCategories('culture');
    notifyListeners();
  }

  bool _isSheepExpense(Depense depense) {
    final text = '${depense.categorie} ${depense.remarque}'.toLowerCase();
    if (_containsExcludedSpecies(text)) {
      return false;
    }
    return text.contains('betail') ||
        text.contains('mouton') ||
        text.contains('brebis') ||
        text.contains('agne') ||
        text.contains('belier') ||
        text.contains('ovin') ||
        text.contains('sardi') ||
        text.contains('veterinaire') ||
        text.contains('alimentation') ||
        text.contains('aid');
  }

  bool _isSheepRevenue(Revenu revenu) {
    final text = '${revenu.categorie} ${revenu.remarque}'.toLowerCase();
    if (_containsExcludedSpecies(text)) {
      return false;
    }
    return text.contains('vente brebis') ||
        text.contains('vente belier') ||
        text.contains('vente agneau') ||
        text.contains('vente betail') ||
        text.contains('mouton') ||
        text.contains('brebis') ||
        text.contains('agne') ||
        text.contains('belier') ||
        text.contains('ovin') ||
        text.contains('sardi') ||
        text.contains('aid');
  }

  bool _containsExcludedSpecies(String value) {
    final text = value.toLowerCase();
    return text.contains('chevre') ||
        text.contains('chèvre') ||
        text.contains('goat') ||
        text.contains('lait');
  }
}
