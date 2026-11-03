import 'package:flutter_test/flutter_test.dart';
import 'package:nib_ember_living/content/ecosystem_guides.dart';

void main() {
  test('ecosystem guides cover source-backed routes and widget families', () {
    const expected = {
      'components': {
        'getting-started',
        'theming',
        'forms',
        'catalog',
        'api',
        'accessibility',
        'platform-limits',
        'troubleshooting',
      },
      'genui': {
        'getting-started',
        'protocol-scope',
        'runtime',
        'api',
        'bindings-and-forms',
        'actions-and-policy',
        'accessibility',
        'platform-limits',
        'troubleshooting',
      },
    };
    for (final entry in expected.entries) {
      final articles = detailedEcosystemGuides
          .where((article) => article.packageId == entry.key)
          .toList();
      assert(
        articles.map((article) => article.id).toSet().length == articles.length,
      );
      assert(
        articles.map((article) => article.id).toSet().containsAll(entry.value),
      );
      assert(articles.length == entry.value.length);
      for (final article in articles) {
        assert(article.sections.length >= 2);
        assert(article.evidence.isNotEmpty);
        assert(
          article.sections.map((section) => section.id).toSet().length ==
              article.sections.length,
        );
        for (final section in article.sections) {
          assert(section.paragraphs.isNotEmpty);
          assert(section.paragraphs.every((paragraph) => paragraph.isNotEmpty));
          for (final api in section.api) {
            assert(api.name.isNotEmpty && api.type.isNotEmpty);
            assert(api.defaultValue.isNotEmpty && api.description.isNotEmpty);
          }
        }
      }
    }

    final catalog = detailedEcosystemGuides
        .singleWhere(
          (article) =>
              article.packageId == 'components' && article.id == 'catalog',
        )
        .sections
        .expand((section) => section.api)
        .map((entry) => entry.name)
        .join(' ');
    for (final family in [
      'NibButton',
      'NibInput',
      'NibTextarea',
      'NibCheckbox',
      'NibSwitch',
      'NibRadioGroup',
      'NibSlider',
      'NibSelect',
      'NibCombobox',
      'NibOtpInput',
      'NibToggleGroup',
      'NibDatePicker',
      'NibDialog',
      'NibBottomSheet',
      'NibPopover',
      'NibHoverCard',
      'NibContextMenu',
      'NibCommandPalette',
      'NibTabs',
      'NibBreadcrumb',
      'NibPagination',
      'NibNavigationMenu',
      'NibCard',
      'NibFlipCard',
      'NibDataTable',
      'NibAccordion',
      'NibCarousel',
      'NibResizablePanels',
      'NibSkeleton',
      'NibCircularLoader',
      'NibLiquidGlass',
    ]) {
      assert(catalog.contains(family), 'Catalog is missing $family');
    }
  });
}
