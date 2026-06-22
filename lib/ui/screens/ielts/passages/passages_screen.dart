import 'package:flutter/material.dart';
import 'package:totoki_extract/theme/appTheme.dart';
import 'package:totoki_extract/widget/reviewScreen.dart';

class PassagesScreen extends StatefulWidget {
  const PassagesScreen({super.key});

  @override
  State<PassagesScreen> createState() => _PassagesScreenState();
}

class _PassagesScreenState extends State<PassagesScreen> {
  int _currentQ = 0;
  int? _selected;
  bool _answered = false;

  final _article =
      "The concept of sustainable development has gained significant traction in recent decades as societies grapple with the complex interplay between economic growth, environmental preservation, and social equity. At its core, sustainable development seeks to meet the needs of the present without compromising the ability of future generations to meet their own needs.\n\n"
      "One of the primary challenges in achieving sustainable development lies in the tension between short-term economic gains and long-term environmental costs. Industrial activities, while driving economic prosperity, often result in resource depletion and environmental degradation. The extraction of fossil fuels, deforestation for agricultural expansion, and the discharge of pollutants into waterways represent just a few examples of this inherent conflict.\n\n"
      "However, sustainable development is not antithetical to economic progress. On the contrary, many economists and environmentalists argue that sustainable practices can drive innovation, create new markets, and enhance long-term profitability. The renewable energy sector, for instance, has experienced exponential growth, generating employment opportunities while reducing carbon emissions. Similarly, circular economy models that prioritize waste reduction and resource efficiency have demonstrated both environmental and economic benefits.\n\n"
      "Social equity represents the third pillar of sustainable development, emphasizing that the benefits of development must be distributed fairly across society. This includes access to education, healthcare, clean water, and economic opportunities. Marginalized communities often bear the disproportionate burden of environmental degradation, a phenomenon known as environmental injustice. Addressing these disparities is essential for achieving truly sustainable development.\n\n"
      "International cooperation plays a crucial role in advancing sustainable development goals. Agreements such as the Paris Climate Accord and the United Nations Sustainable Development Goals (SDGs) provide frameworks for collective action. Yet, implementation remains challenging due to varying national priorities, economic disparities, and political will. The transition to sustainable development requires coordinated efforts across governments, businesses, civil society, and individuals.";

  final _questions = [
    {
      "q": "What is the primary challenge in achieving sustainable development according to the passage?",
      "options": [
        "Lack of international cooperation",
        "Tension between short-term economic gains and long-term environmental costs",
        "Insufficient technological innovation",
        "Population growth in developing countries",
      ],
      "answer": 1,
    },
    {
      "q": "What does the author suggest about sustainable development and economic progress?",
      "options": [
        "They are fundamentally incompatible",
        "Sustainable practices always reduce profitability",
        "They can complement each other through innovation",
        "Economic progress should take priority",
      ],
      "answer": 2,
    },
    {
      "q": "What does 'environmental injustice' refer to in the passage?",
      "options": [
        "Lack of environmental regulations",
        "Marginalized communities bearing disproportionate environmental burden",
        "Unequal distribution of natural resources",
        "Corporate exploitation of natural resources",
      ],
      "answer": 1,
    },
  ];

  void _submit() {
    if (_selected == null) return;
    setState(() => _answered = true);
  }

  void _next() {
    if (_currentQ < _questions.length - 1) {
      setState(() {
        _currentQ++;
        _selected = null;
        _answered = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = _questions[_currentQ];
    final correct = _selected == q["answer"];

    return Scaffold(
      backgroundColor: AppTheme.darkBase,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.darkBorder, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Reading", style: AppTheme.screenTitleStyle),
        backgroundColor: AppTheme.darkBase,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                children: [
                  Expanded(
                    flex: 5,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.darkSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.darkBorder, width: 2),
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          _article,
                          style: AppTheme.bodyLargeStyle.copyWith(height: 1.6),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    flex: 4,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.darkSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.darkBorder, width: 2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            "Question ${_currentQ + 1}/${_questions.length}",
                            style: AppTheme.captionStyle.copyWith(fontSize: 13),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            q["q"] as String,
                            style: AppTheme.sectionHeaderStyle.copyWith(fontSize: 16),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: ListView(
                              children: List.generate(
                                (q["options"] as List<String>).length,
                                (i) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: _OptionBtn(
                                    label: (q["options"] as List<String>)[i],
                                    isSelected: _selected == i,
                                    onTap: _answered ? null : () => setState(() => _selected = i),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (!_answered)
                            GestureDetector(
                              onTap: _selected != null ? _submit : null,
                              child: Container(
                                width: double.infinity,
                                height: 52,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  color: _selected != null ? AppTheme.greenPrimary : AppTheme.darkCard,
                                  boxShadow: _selected != null
                                      ? [BoxShadow(color: AppTheme.greenPrimary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
                                      : [],
                                ),
                                child: Center(
                                  child: Text(
                                    "SUBMIT ANSWER",
                                    style: AppTheme.bodyLargeStyle.copyWith(
                                      color: _selected != null ? AppTheme.darkBase : AppTheme.lightText.withOpacity(0.5),
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              bottom: _answered ? 0 : -MediaQuery.of(context).size.height,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height,
              child: ReviewScreen(
                right: correct,
                answer: (q["options"] as List<String>)[q["answer"] as int],
                onPressed: _next,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionBtn extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const _OptionBtn({required this.label, required this.isSelected, this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          side: BorderSide(color: isSelected ? AppTheme.greenPrimary : AppTheme.darkBorder, width: 2),
          backgroundColor: isSelected ? AppTheme.darkCard : AppTheme.darkSurface,
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Text(
          label,
          style: AppTheme.bodyLargeStyle.copyWith(
            color: isSelected ? AppTheme.greenPrimary : AppTheme.lightText,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          textAlign: TextAlign.left,
        ),
      ),
    );
  }
}
