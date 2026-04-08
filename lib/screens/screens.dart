import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/ferme_models.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../theme.dart';
import '../widgets/form_sheet.dart';
import '../widgets/widgets.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    this.onOpenCheptelCategory,
    this.onOpenFinances,
  });

  final ValueChanged<String>? onOpenCheptelCategory;
  final VoidCallback? onOpenFinances;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final stock = provider.stock;
    final now = DateTime.now();
    final depenses = provider.depensesMois(now);
    final revenus = provider.revenusGlobauxMois(now);
    final bilan = revenus - depenses;
    final monthName = DateFormat('MMMM yyyy', 'fr_FR').format(now);
    final recentMouvements = provider.recentHerdMovements.take(4).toList();
    final recentDepenses = provider.depensesFiltrees.take(2).toList();
    final recentRevenus = provider.revenusFiltres
        .where((item) {
          final text = '${item.categorie} ${item.remarque}'.toLowerCase();
          return !text.contains('chevre') &&
              !text.contains('chèvre') &&
              !text.contains('lait');
        })
        .take(2)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const FermeFilterBar(),
          const SizedBox(height: 4),
          Row(
            children: <Widget>[
              Expanded(
                child: _ActionBtn(
                  label: 'Revenus',
                  emoji: '💰',
                  color: const Color(0xFF1B7A46),
                  splashColor: const Color(0xFF27A260),
                  onTap: onOpenFinances ?? () => showRevForm(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionBtn(
                  label: 'Mouvement',
                  emoji: '🔄',
                  color: const Color(0xFF245C3D),
                  splashColor: const Color(0xFF328458),
                  onTap: () => showMvtForm(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SectionTitle('Accueil cheptel', sub: monthName),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: <Color>[Color(0xFF256F49), Color(0xFF3BAA74)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(26),
            ),
            child: Stack(
              children: <Widget>[
                const Positioned(
                  right: 0,
                  top: 0,
                  child: Text('🐑', style: TextStyle(fontSize: 80, color: Colors.white24)),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '${stock.total}',
                      style: const TextStyle(
                        fontSize: 62,
                        height: 1,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Cheptel total Sardi',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${stock.femelles} brebis · ${stock.males} beliers · ${stock.agneauxF + stock.agneauxM} agneaux',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white70),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Revenus Sardi: ${fmtMAD(provider.sheepRevenueForMonth(now))}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.22,
            padding: const EdgeInsets.only(bottom: 14),
            children: <Widget>[
              KpiCard(emoji: '🐑', value: '${provider.totalAnimals}', label: 'Cheptel total'),
              KpiCard(emoji: '🐣', value: '${provider.birthsCount}', label: 'Naissances'),
              KpiCard(emoji: '📤', value: '${provider.outputsCount}', label: 'Sorties'),
              KpiCard(emoji: '💰', value: fmtMAD(provider.sheepRevenueForMonth(now)), label: 'Revenus Sardi'),
            ],
          ),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              FinSumCard(value: fmtMAD(depenses), label: 'Depenses du mois', color: AppColors.red),
              FinSumCard(value: fmtMAD(revenus), label: 'Revenus du mois', color: AppColors.green2),
              FinSumCard(
                value: fmtMAD(bilan.abs()),
                label: bilan >= 0 ? 'Bilan positif' : 'Bilan negatif',
                color: bilan >= 0 ? AppColors.green2 : AppColors.red,
              ),
            ],
          ),
          const SizedBox(height: 14),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const CardTitle('ETAT ACTUEL DU CHEPTEL'),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.05,
                  children: provider.herdCategories.map((card) {
                    return _CategoryTile(
                      summary: card,
                      onTap: () => onOpenCheptelCategory?.call(card.id),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'RACCOURCIS RAPIDES',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: .6, color: AppColors.text3),
          ),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: .88,
            padding: const EdgeInsets.only(bottom: 14),
            children: <Widget>[
              QuickBtn(
                emoji: '🐑',
                label: 'Cheptel',
                onTap: () => onOpenCheptelCategory?.call('femelles'),
              ),
              QuickBtn(
                emoji: '🐣',
                label: 'Naissance',
                onTap: () => showMvtForm(context, initialType: 'naissance_agf'),
              ),
              QuickBtn(
                emoji: '💸',
                label: 'Vente',
                onTap: () => showMvtForm(context, initialType: 'vente_femelle'),
              ),
              QuickBtn(
                emoji: '📊',
                label: 'Finance',
                onTap: onOpenFinances ?? () => showDepForm(context),
              ),
            ],
          ),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const CardTitle('RECENT'),
                if (recentMouvements.isEmpty && recentDepenses.isEmpty && recentRevenus.isEmpty)
                  const EmptyState(emoji: '📭', text: 'Aucune donnee recente')
                else ...<Widget>[
                  ...recentMouvements.map(
                    (m) => RecentItem(
                      emoji: m.emoji,
                      title: m.label,
                      subtitle: fmtDate(m.date),
                      value: 'x${m.qte}',
                      valueColor: mvtFgColor(m.color),
                      bgColor: mvtBgColor(m.color),
                    ),
                  ),
                  ...recentDepenses.map(
                    (d) => RecentItem(
                      emoji: '💸',
                      title: d.categorie,
                      subtitle: fmtDate(d.date),
                      value: '-${fmtMAD(d.montant)}',
                      valueColor: AppColors.red,
                      bgColor: AppColors.redBg,
                    ),
                  ),
                  ...recentRevenus.map(
                    (r) => RecentItem(
                      emoji: '💰',
                      title: r.categorie,
                      subtitle: fmtDate(r.date),
                      value: '+${fmtMAD(r.montant)}',
                      valueColor: AppColors.green2,
                      bgColor: AppColors.greenBg,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.label,
    required this.emoji,
    required this.color,
    required this.splashColor,
    required this.onTap,
  });

  final String label;
  final String emoji;
  final Color color;
  final Color splashColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: splashColor.withOpacity(.3),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(emoji, style: const TextStyle(fontSize: 30)),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: .2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CheptelScreen extends StatefulWidget {
  const CheptelScreen({super.key, this.initialCategory = 'femelles'});

  final String initialCategory;

  @override
  State<CheptelScreen> createState() => _CheptelScreenState();
}

class _CheptelScreenState extends State<CheptelScreen> {
  late String _selectedCategory;
  final GlobalKey _historyKey = GlobalKey();
  final GlobalKey _financeKey = GlobalKey();
  final GlobalKey _reportKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
  }

  void selectCategory(String categoryId) {
    setState(() => _selectedCategory = categoryId);
  }

  Future<void> _scrollTo(GlobalKey key) async {
    final target = key.currentContext;
    if (target == null) return;
    await Scrollable.ensureVisible(
      target,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final cards = provider.herdCategories;
    final active = provider.herdCategoryById(_selectedCategory);
    final history = provider.herdCategoryHistory(_selectedCategory);
    final report = provider.herdMonthlyReport.reversed.toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SectionTitle('Cheptel Sardi', sub: 'Vue categorie, historique, finances et rapports'),
          Row(
            children: <Widget>[
              const Expanded(
                child: TextField(
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: 'Recherche categorie, mouvement, date...',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.tonalIcon(
                onPressed: () => showMvtForm(context),
                icon: const Icon(Icons.tune_rounded),
                label: const Text('Filtres'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const CardTitle('CATEGORIES CLIQUABLES'),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.05,
                  children: cards.map((card) {
                    final selected = card.id == _selectedCategory;
                    return _CategorySelectorTile(
                      summary: card,
                      selected: selected,
                      onTap: () => selectCategory(card.id),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(active.meta.emoji, style: const TextStyle(fontSize: 34)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            active.meta.label,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.green2),
                          ),
                          Text(
                            active.meta.shortLabel,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text3),
                          ),
                        ],
                      ),
                    ),
                    const _CategoryBadge(label: 'Race Sardi', color: AppColors.green2, bg: AppColors.greenBg),
                  ],
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.5,
                  children: <Widget>[
                    _MiniMetric(label: 'Stock actuel', value: '${active.total}'),
                    _MiniMetric(label: 'Mouvements', value: '${active.historyCount}'),
                    _MiniMetric(label: 'Entrees', value: '${active.entries}'),
                    _MiniMetric(label: 'Sorties', value: '${active.exits}'),
                  ],
                ),
                const SizedBox(height: 14),
                _LinkTile(title: 'Historique de la categorie', subtitle: 'Ouvrir les mouvements lies', onTap: () => _scrollTo(_historyKey)),
                const SizedBox(height: 10),
                _LinkTile(title: 'Finances du cheptel', subtitle: 'Voir l impact Sardi dans les finances', onTap: () => _scrollTo(_financeKey)),
                const SizedBox(height: 10),
                _LinkTile(title: 'Rapport 6 mois', subtitle: 'Consulter la tendance issue des mouvements', onTap: () => _scrollTo(_reportKey)),
              ],
            ),
          ),
          AppCard(
            key: _historyKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const CardTitle('HISTORIQUE LIE A LA CATEGORIE'),
                if (history.isEmpty)
                  const EmptyState(emoji: '🐑', text: 'Aucun mouvement pour cette categorie')
                else
                  ...history.map((movement) {
                    final delta = movementImpactForCategory(active.id, movement);
                    final positive = delta >= 0;
                    return HistoryItem(
                      emoji: movement.emoji,
                      title: movement.label,
                      subtitle: '${fmtDate(movement.date)}${movement.remarque.isNotEmpty ? ' · ${movement.remarque}' : ''}',
                      value: '${positive ? '+' : '-'}${delta.abs()}',
                      valueColor: positive ? AppColors.green2 : AppColors.red,
                      bgColor: positive ? AppColors.greenBg : AppColors.redBg,
                      onDelete: () => _confirmDelete(
                        context,
                        () => context.read<AppProvider>().deleteMouvement(movement.id),
                      ),
                    );
                  }),
              ],
            ),
          ),
          AppCard(
            key: _financeKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const CardTitle('FINANCES LIEES AU CHEPTEL SARDI'),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: <Widget>[
                    FinSumCard(value: fmtMAD(provider.sheepRevenueTotal), label: 'Revenus cheptel', color: AppColors.green2),
                    FinSumCard(value: fmtMAD(provider.sheepExpenseTotal), label: 'Charges cheptel', color: AppColors.red),
                    FinSumCard(
                      value: fmtMAD(provider.sheepBalance),
                      label: provider.sheepBalance >= 0 ? 'Marge Sardi' : 'Ecart Sardi',
                      color: provider.sheepBalance >= 0 ? AppColors.blue2 : AppColors.red,
                    ),
                  ],
                ),
              ],
            ),
          ),
          AppCard(
            key: _reportKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const CardTitle('RAPPORT CHEPTEL'),
                ...report.map((snapshot) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.cardSoft,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                DateFormat('MMM yyyy', 'fr_FR').format(snapshot.month),
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.text),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${snapshot.total} tetes · +${snapshot.births} naissances · -${snapshot.outputs} sorties',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.text3),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              fmtMAD(snapshot.revenues),
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.green2),
                            ),
                            Text(
                              '-${fmtMAD(snapshot.expenses)}',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.red),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          AddButton(label: 'Ajouter un mouvement', onTap: () => showMvtForm(context)),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.summary, required this.onTap});

  final HerdCategorySummary summary;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardSoft,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(summary.meta.emoji, style: const TextStyle(fontSize: 28)),
                  const Spacer(),
                  _CategoryBadge(label: '${summary.historyCount} mvts', color: AppColors.text2, bg: Colors.white),
                ],
              ),
              const Spacer(),
              Text(
                '${summary.total}',
                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: AppColors.green2),
              ),
              const SizedBox(height: 4),
              Text(summary.meta.label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.text)),
              const SizedBox(height: 2),
              const Text('Cliquer pour ouvrir le detail', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.text3)),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategorySelectorTile extends StatelessWidget {
  const _CategorySelectorTile({
    required this.summary,
    required this.selected,
    required this.onTap,
  });

  final HerdCategorySummary summary;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.green2 : Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(summary.meta.emoji, style: const TextStyle(fontSize: 28)),
                  const Spacer(),
                  _CategoryBadge(
                    label: '${summary.historyCount}',
                    color: selected ? AppColors.green2 : AppColors.text2,
                    bg: selected ? Colors.white : AppColors.cardSoft,
                  ),
                ],
              ),
              const Spacer(),
              Text(
                '${summary.total}',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: selected ? Colors.white : AppColors.green2),
              ),
              const SizedBox(height: 4),
              Text(
                summary.meta.label,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: selected ? Colors.white : AppColors.text),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({
    required this.label,
    required this.color,
    required this.bg,
  });

  final String label;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: color)),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.cardSoft, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.text3)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.text)),
        ],
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  const _LinkTile({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardSoft,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.text)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.text3)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.text3),
            ],
          ),
        ),
      ),
    );
  }
}

class DepensesScreen extends StatelessWidget {
  const DepensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final now = DateTime.now();
    final categories = provider.depensesByCategorie();
    final total = provider.totalDepenses;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const FermeFilterBar(),
          const SectionTitle('Depenses', sub: 'Vue synthese et journal des sorties'),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              FinSumCard(value: fmtMAD(provider.depensesMois(now)), label: 'Ce mois', color: AppColors.red),
              FinSumCard(value: fmtMAD(total), label: 'Total', color: AppColors.red),
              FinSumCard(value: fmtMAD(provider.sheepExpenseTotal), label: 'Cheptel Sardi', color: AppColors.orange2),
            ],
          ),
          const SizedBox(height: 14),
          AddButton(label: 'Ajouter une depense', onTap: () => showDepForm(context), color: AppColors.red2),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const CardTitle('PAR CATEGORIE'),
                if (categories.isEmpty)
                  const EmptyState(emoji: '📊', text: 'Aucune depense')
                else
                  ...categories.entries.map(
                    (entry) => CatRow(cat: entry.key, amount: entry.value, total: total, color: AppColors.red),
                  ),
              ],
            ),
          ),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const CardTitle('TOUTES LES DEPENSES'),
                if (provider.depensesFiltrees.isEmpty)
                  const EmptyState(emoji: '💸', text: 'Aucune depense enregistree')
                else
                  ...provider.depensesFiltrees.map(
                    (depense) => HistoryItem(
                      emoji: '💸',
                      title: depense.categorie,
                      subtitle: '${fmtDate(depense.date)}${depense.remarque.isNotEmpty ? ' · ${depense.remarque}' : ''}',
                      value: '-${fmtMAD(depense.montant)}',
                      valueColor: AppColors.red,
                      bgColor: AppColors.redBg,
                      onDelete: () => _confirmDelete(context, () => context.read<AppProvider>().deleteDepense(depense.id)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RevenusScreen extends StatelessWidget {
  const RevenusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final now = DateTime.now();
    final categories = provider.revenusByCategorie();
    final total = provider.totalRevenus;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const FermeFilterBar(),
          const SectionTitle('Revenus', sub: 'Vue synthese et journal des encaissements'),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              FinSumCard(value: fmtMAD(provider.revenusMois(now)), label: 'Ce mois', color: AppColors.green2),
              FinSumCard(value: fmtMAD(total), label: 'Total', color: AppColors.green2),
              FinSumCard(value: fmtMAD(provider.sheepRevenueTotal), label: 'Cheptel Sardi', color: AppColors.orange2),
            ],
          ),
          const SizedBox(height: 14),
          AddButton(label: 'Ajouter un revenu', onTap: () => showRevForm(context)),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const CardTitle('PAR CATEGORIE'),
                if (categories.isEmpty)
                  const EmptyState(emoji: '📊', text: 'Aucun revenu')
                else
                  ...categories.entries.map(
                    (entry) => CatRow(cat: entry.key, amount: entry.value, total: total, color: AppColors.green2),
                  ),
              ],
            ),
          ),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const CardTitle('TOUS LES REVENUS'),
                if (provider.revenusFiltres.isEmpty)
                  const EmptyState(emoji: '💰', text: 'Aucun revenu enregistre')
                else
                  ...provider.revenusFiltres
                      .where((revenu) {
                        final text = '${revenu.categorie} ${revenu.remarque}'.toLowerCase();
                        return !text.contains('chevre') &&
                            !text.contains('chèvre') &&
                            !text.contains('lait');
                      })
                      .map(
                        (revenu) => HistoryItem(
                          emoji: '💰',
                          title: revenu.categorie,
                          subtitle: '${fmtDate(revenu.date)}${revenu.remarque.isNotEmpty ? ' · ${revenu.remarque}' : ''}',
                          value: '+${fmtMAD(revenu.montant)}',
                          valueColor: AppColors.green2,
                          bgColor: AppColors.greenBg,
                          onDelete: () => _confirmDelete(context, () => context.read<AppProvider>().deleteRevenu(revenu.id)),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HistoriqueScreen extends StatefulWidget {
  const HistoriqueScreen({super.key});

  @override
  State<HistoriqueScreen> createState() => _HistoriqueScreenState();
}

class _HistoriqueScreenState extends State<HistoriqueScreen> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final items = <({DateTime date, String type, dynamic item})>[
      if (_filter == 'all' || _filter == 'mvt') ...provider.herdMouvements.map((m) => (date: m.date, type: 'mvt', item: m)),
      if (_filter == 'all' || _filter == 'dep') ...provider.depensesFiltrees.map((d) => (date: d.date, type: 'dep', item: d)),
      if (_filter == 'all' || _filter == 'rev')
        ...provider.revenusFiltres
            .where((revenu) {
              final text = '${revenu.categorie} ${revenu.remarque}'.toLowerCase();
              return !text.contains('chevre') &&
                  !text.contains('chèvre') &&
                  !text.contains('lait');
            })
            .map((r) => (date: r.date, type: 'rev', item: r)),
    ]..sort((a, b) => b.date.compareTo(a.date));

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SectionTitle('Historique', sub: 'Cheptel, finances et operations recentes'),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: <Widget>[
                    _chip('Tout', 'all'),
                    _chip('Cheptel', 'mvt'),
                    _chip('Depenses', 'dep'),
                    _chip('Revenus', 'rev'),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? const EmptyState(emoji: '📭', text: 'Aucune donnee')
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final entry = items[index];
                    if (entry.type == 'mvt') {
                      final movement = entry.item as Mouvement;
                      return HistoryItem(
                        emoji: movement.emoji,
                        title: movement.label,
                        subtitle: '${fmtDate(movement.date)}${movement.remarque.isNotEmpty ? ' · ${movement.remarque}' : ''}',
                        value: 'x${movement.qte}',
                        valueColor: mvtFgColor(movement.color),
                        bgColor: mvtBgColor(movement.color),
                      );
                    }
                    if (entry.type == 'dep') {
                      final depense = entry.item as Depense;
                      return HistoryItem(
                        emoji: '💸',
                        title: depense.categorie,
                        subtitle: '${fmtDate(depense.date)}${depense.remarque.isNotEmpty ? ' · ${depense.remarque}' : ''}',
                        value: '-${fmtMAD(depense.montant)}',
                        valueColor: AppColors.red,
                        bgColor: AppColors.redBg,
                      );
                    }
                    final revenu = entry.item as Revenu;
                    return HistoryItem(
                      emoji: '💰',
                      title: revenu.categorie,
                      subtitle: '${fmtDate(revenu.date)}${revenu.remarque.isNotEmpty ? ' · ${revenu.remarque}' : ''}',
                      value: '+${fmtMAD(revenu.montant)}',
                      valueColor: AppColors.green2,
                      bgColor: AppColors.greenBg,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _chip(String label, String value) {
    final selected = _filter == value;
    return GestureDetector(
      onTap: () => setState(() => _filter = value),
      child: Container(
        margin: const EdgeInsets.only(right: 8, bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.green2 : AppColors.bg2,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: selected ? AppColors.green2 : AppColors.border),
        ),
        child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: selected ? Colors.white : AppColors.text2)),
      ),
    );
  }
}

class FinancesScreen extends StatefulWidget {
  const FinancesScreen({super.key});

  @override
  State<FinancesScreen> createState() => _FinancesScreenState();
}

class _FinancesScreenState extends State<FinancesScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: AppCard(
            margin: EdgeInsets.zero,
            child: Row(
              children: <Widget>[
                Expanded(child: _FinanceHeaderMetric(label: 'Revenus Sardi', value: fmtMAD(provider.sheepRevenueTotal), color: AppColors.green2)),
                Expanded(child: _FinanceHeaderMetric(label: 'Charges Sardi', value: fmtMAD(provider.sheepExpenseTotal), color: AppColors.red)),
                Expanded(
                  child: _FinanceHeaderMetric(
                    label: 'Marge Sardi',
                    value: fmtMAD(provider.sheepBalance),
                    color: provider.sheepBalance >= 0 ? AppColors.blue2 : AppColors.red,
                  ),
                ),
              ],
            ),
          ),
        ),
        TabBar(
          controller: _tab,
          labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
          unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          tabs: const <Tab>[
            Tab(text: 'Depenses'),
            Tab(text: 'Revenus'),
            Tab(text: 'Historique'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tab,
            children: const <Widget>[
              DepensesScreen(),
              RevenusScreen(),
              HistoriqueScreen(),
            ],
          ),
        ),
      ],
    );
  }
}

class _FinanceHeaderMetric extends StatelessWidget {
  const _FinanceHeaderMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.text3)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: color)),
        ],
      ),
    );
  }
}

class ManagementHubScreen extends StatefulWidget {
  const ManagementHubScreen({super.key});

  @override
  State<ManagementHubScreen> createState() => _ManagementHubScreenState();
}

class _ManagementHubScreenState extends State<ManagementHubScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilotage & Parametres'),
        bottom: TabBar(
          controller: _tab,
          tabs: const <Tab>[
            Tab(text: '💸 Depenses'),
            Tab(text: '💰 Revenus'),
            Tab(text: '🌾 Cultures'),
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.bg2,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: const <Widget>[
                Expanded(child: _FermeInfo(emoji: '🐑', name: 'Ferme Rhamna', desc: 'Sardi · Oliviers · Fassa')),
                SizedBox(width: 1, child: ColoredBox(color: AppColors.border)),
                Expanded(child: _FermeInfo(emoji: '🫒', name: 'Ferme Srahna', desc: 'Oliviers · Luzerne')),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: _ToolBtn(
                    emoji: '💾',
                    label: 'Exporter sauvegarde',
                    color: AppColors.green2,
                    onTap: () async {
                      try {
                        await context.read<AppProvider>().exportDatabase();
                      } catch (error) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erreur export: $error'), backgroundColor: AppColors.red),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ToolBtn(
                    emoji: '🗑️',
                    label: 'Vider les donnees',
                    color: AppColors.red2,
                    onTap: () => _confirmDelete(context, () => context.read<AppProvider>().clearAll()),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: const <Widget>[
                _CatList(type: 'depense'),
                _CatList(type: 'revenu'),
                _CatList(type: 'culture'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FermeInfo extends StatelessWidget {
  const _FermeInfo({required this.emoji, required this.name, required this.desc});

  final String emoji;
  final String name;
  final String desc;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(emoji, style: const TextStyle(fontSize: 26)),
        const SizedBox(height: 4),
        Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.text)),
        Text(desc, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.text3), textAlign: TextAlign.center),
      ],
    );
  }
}

class _ToolBtn extends StatelessWidget {
  const _ToolBtn({required this.emoji, required this.label, required this.color, required this.onTap});

  final String emoji;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            children: <Widget>[
              Text(emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

class _CatList extends StatelessWidget {
  const _CatList({required this.type});

  final String type;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final cats = type == 'depense'
        ? provider.depCategories
        : type == 'revenu'
            ? provider.revCategories.where((cat) {
                final label = cat.label.toLowerCase();
                return !label.contains('lait') && !label.contains('chevre') && !label.contains('chèvre');
              }).toList()
            : provider.cultureCategories;

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showCatForm(context, type),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Ajouter une categorie'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.green2, minimumSize: const Size.fromHeight(50)),
            ),
          ),
        ),
        Expanded(
          child: cats.isEmpty
              ? const Center(child: Text('Aucune categorie', style: TextStyle(color: AppColors.text3)))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: cats.length,
                  itemBuilder: (ctx, i) {
                    final cat = cats[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(color: AppColors.bg2, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(color: AppColors.greenBg, borderRadius: BorderRadius.circular(12)),
                          child: Center(
                            child: Text(type == 'depense' ? '💸' : type == 'revenu' ? '💰' : '🌾', style: const TextStyle(fontSize: 18)),
                          ),
                        ),
                        title: Text(cat.label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            IconButton(icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.green2), onPressed: () => _showCatForm(context, type, existing: cat)),
                            IconButton(icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.red), onPressed: () => _confirmDelete(context, () => context.read<AppProvider>().deleteCategory(cat.id))),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showCatForm(BuildContext context, String type, {AppCategory? existing}) {
    final ctrl = TextEditingController(text: existing?.label ?? '');
    final title = existing == null ? 'Ajouter categorie' : 'Modifier categorie';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(color: AppColors.bg2, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 16),
                Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: AppColors.green2)),
                const SizedBox(height: 20),
                TextField(
                  controller: ctrl,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'Nom de la categorie',
                    hintText: 'Ex: Vente brebis',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final label = ctrl.text.trim();
                      if (label.isEmpty) return;
                      final lower = label.toLowerCase();
                      if (type == 'revenu' && (lower.contains('lait') || lower.contains('chevre') || lower.contains('chèvre'))) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Categorie non prise en charge pour Ma Ferme Pro.')),
                        );
                        return;
                      }
                      final provider = context.read<AppProvider>();
                      if (existing == null) {
                        final cats = type == 'depense' ? provider.depCategories : type == 'revenu' ? provider.revCategories : provider.cultureCategories;
                        await provider.addCategory(AppCategory(type: type, label: label, ordre: cats.length));
                      } else {
                        await provider.updateCategory(AppCategory(id: existing.id, type: type, label: label, ordre: existing.ordre));
                      }
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.green2, minimumSize: const Size.fromHeight(54)),
                    child: Text(existing == null ? 'Ajouter' : 'Enregistrer'),
                  ),
                ),
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler', style: TextStyle(color: AppColors.text3, fontWeight: FontWeight.w700))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void _confirmDelete(BuildContext context, VoidCallback onConfirm) {
  showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.bg2,
      title: const Text('Confirmer'),
      content: const Text('Supprimer cet enregistrement ?'),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Annuler')),
        TextButton(
          onPressed: () {
            Navigator.pop(dialogContext);
            onConfirm();
          },
          child: const Text('Supprimer', style: TextStyle(color: AppColors.red)),
        ),
      ],
    ),
  );
}
