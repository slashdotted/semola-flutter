/// Semola is used to hyphenate italian words. It mainly uses regular expressions
/// built upon the rules of the Accademia della Crusca but also has some built-in
/// exceptions and allows for user-defined exceptions.
/// The *hyphenate* method accepts a word (String) and returns a list the syllables.
/// The *addException* method is used to add a user-defined exception (a String where syllables
/// are separated using '-'), whereas the *clearExceptions* method is used do delete
/// all user-defined exceptions.
library semola;

/* 
This file is part of the Semola package / library
Copyright (c)2022-2023 Amos Brocco <contact@amosbrocco.ch>.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

    1. Redistributions of source code must retain the above copyright
       notice, this list of conditions and the following disclaimer.
    2. Redistributions in binary form must reproduce the above copyright
       notice, this list of conditions and the following disclaimer in
       the documentation and/or other materials provided with the distribution.
    3. Neither the name of the copyright holder nor the names of its 
       contributors may be used to endorse or promote products derived
       from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
THE POSSIBILITY OF SUCH DAMAGE.
*/

import 'dart:collection';

import 'package:semola/versioned_substitute.dart';
import 'package:substitute/substitute.dart';

/// Semola base class, meant to be used statically.
class Semola {
  static final _spaces = RegExp(r'\s');
  static final HashMap<String, List<int>> _exceptions = HashMap();
  static final HashMap<String, List<int>> _builtInExceptions = HashMap();
  static final RegExp _nonWordStart = RegExp(r'^\W+');
  static final RegExp _nonWordEnd = RegExp(r'\W+$');

  static int? _initializationVersion;

  static final List<Substitute> _substitutions = [
//
// *************************************************
// Regole di divisione
// *************************************************

// Da: https://accademiadellacrusca.it/it/consulenza/divisione-in-sillabe/302
// Si dividono i gruppi consonantici che non sono ammessi ad inizio di parola
// (del tipo cn, lm, rc, bd, mb, mn, ld, ng, nd, tm): tet-to; ac-qua; ri-sciac-quo; cal-ma; ri-cer-ca; rab-do-man-te; im-bu-to; cal-do; in-ge-gne-re; quan-do; am-ni-sti-a; Gian-mar-co; tec-ni-co, a-rit-me-ti-ca.
    Substitute.fromSedExpr(r"s/(c)(q)/\1-\2/Ig"),
    Substitute.fromSedExpr(r"s/(c)(n)/\1-\2/Ig"),
    Substitute.fromSedExpr(r"s/(l)(m)/\1-\2/Ig"),
    Substitute.fromSedExpr(r"s/(r)(c)/\1-\2/Ig"),
    Substitute.fromSedExpr(r"s/(b)(d)/\1-\2/Ig"),
    Substitute.fromSedExpr(r"s/(m)(b)/\1-\2/Ig"),
    Substitute.fromSedExpr(r"s/(m)(n)/\1-\2/Ig"),
    Substitute.fromSedExpr(r"s/(l)(d)/\1-\2/Ig"),
    Substitute.fromSedExpr(r"s/(n)(g)/\1-\2/Ig"),
    Substitute.fromSedExpr(r"s/(n)(d)/\1-\2/Ig"),
    Substitute.fromSedExpr(r"s/(t)(m)/\1-\2/Ig"),

// Da: https://accademiadellacrusca.it/it/consulenza/divisione-in-sillabe/302
// Una vocale iniziale seguita da una sola consonante costituisce una sillaba: e-la-bo-ra-re; a-lian-te; u-mi-do;i-do-lo; o-do-re, u-no.
    Substitute.fromSedExpr(
        r"s/\b([aeiouàèìòùáéíóú])([bcdfghlmnpqrstvzjkwxy])([aeiouàèìòùáéíóú])/-\1-\2\3/Ig"),

// Da: https://accademiadellacrusca.it/it/consulenza/divisione-in-sillabe/302
// Si possono dividere invece i gruppi vocalici che formano uno iato, che si realizza di massima in tre casi:
// 1) se nessuna delle due vocali è i o u: quindi ma-e-stra; a-e-ro-pla-no; po-e-ta; pa-e-sag-gio;
    Substitute.fromSedExpr(r"s/([aeoáéóàèò])([aeoáéóàèò])/\1-\2/Ig"),
// 2) se una delle due vocali è i tonica (cioè sulla quale cade l'accento di parola) o u tonica e l'altra è a, e, o, quindi  mí-e; bu-gí-a; scí-a; pa-ú-ra (in alcuni casi anche se la seconda vocale è una i o una u, quindi le sequenze iu o ui, come ad esempio in di-úr-no, su-í-no);
    Substitute.fromSedExpr(r"s/([íú])([aeiouàèìòùáéíóú])/\1-\2/Ig"),
// 3) nelle composizioni, purché sia ancora ben definito il rapporto tra prefisso e base, del tipo ri-em-pi-re; ri-a-ve-re, ri-u-sa-re (solo in questi composti, lo iato si può produrre anche nell'incontro tra u e i).
    Substitute.fromSedExpr(r"s/([^-])(i)(e)([^-]\w|\b)/\1\2-\3\4/Ig"),
    Substitute.fromSedExpr(r"s/([^-])(i)(u)([^-]\w|\b)/\1\2-\3\4/Ig"),
    Substitute.fromSedExpr(r"s/([^-])(i)(a)([^-]\w|\b)/\1\2-\3\4/Ig"),

// Da: https://accademiadellacrusca.it/it/consulenza/divisione-in-sillabe/302
// Nei gruppi consonantici formati da tre o più consonanti (rst, ntr, ltr, rtr, btr) si divide prima della seconda consonante,
// anche in presenza di prefissi come inter-, trans-, iper-, sub-, super-:
// con-trol-lo, ven-tri-co-lo, al-tro, scal-tro, in-ter-sti-zio, tran-stel-la-re, i-per-tro-fi-co, sub-tro-pi-ca-le, su-per-cri-ti-ci-tà.
// Da: https://scriveregrammaticando.it/2019/12/30/la-divisione-in-sillabe-le-regole-fondamentali/
// Se il gruppo è formato da tre o più consonanti, la prima consonante va con la vocale precedente, le altre con la vocale successiva
    Substitute.fromSedExpr(
        r"s/([bcdfghlmnpqrstvzjkwxy])([bcdfghlmnpqrstvzjkwxy])([bcdfghlmnpqrstvzjkwxy])/\1-\2\3/Ig"),

// Da: https://accademiadellacrusca.it/it/consulenza/divisione-in-sillabe/302
// Una consonante semplice forma una sillaba con la vocale seguente: da-do; pe-ra.
    Substitute.fromSedExpr(
        r"s/([bcdfghlmnpqrstvzjkwxy][aeiouàèìòùáéíóú])/-\1-/Ig"),

// *************************************************
// Regole di non divisione
// *************************************************
    Substitute.fromSedExpr(r"s/-+/-/g"),
// Da: https://accademiadellacrusca.it/it/consulenza/divisione-in-sillabe/302
// Non si divide mai un gruppo di consonanti formato da b, c, d, f, g, p, t, v + l oppure r: a-tle-ti-ca; bi-bli-co; bro-do; in-cli-to; cre-de-re; dro-me-da-rio; fle-bi-le; a-fri-ca-no; gla-di-o-lo; gre-co; pe-plo; pre-go; tre-no; a-vrà.
    Substitute.fromSedExpr(r"s/([bcdfgptv])-([lr])/\1\2/Ig"),

// Da: https://accademiadellacrusca.it/it/consulenza/divisione-in-sillabe/302
// Non si divide mai un gruppo formato da s + consonante/i: o-stra-ci-smo; te-schio; co-sto-la; sco-iat-to-lo; co-stru-i-re; ca-spi-ta, stri-scio-ne.
    Substitute.fromSedExpr(r"s/(s)-([bcdfghlmnpqrstvzjkwxy]+)/\1\2/Ig"),

// Da: https://accademiadellacrusca.it/it/consulenza/divisione-in-sillabe/302
// Il dittongo è un gruppo costituito da una vocale preceduta da una semiconsonante (i, u, quindi le sequenze ia, ie, io, iu, ua, ue, uo, ui) o seguita da una semivocale (i, u, quindi le sequenze ai, ei, oi, ui, au, eu).
// Nelle regole di divisione in sillabe i dittonghi non possono essere spezzati
    Substitute.fromSedExpr(r"s/([iu])-([aeiouàèìòùáéíóú])/\1\2/Ig"),
    Substitute.fromSedExpr(r"s/([aeiouàèìòùáéíóú])-([iu])/\1\2/Ig"),
// NB: Non c'è modo di sapere a priori se una i o una u è semiconsonante o semivocale,
// quindi questa regola è problematica e va aggiustata caso per caso.

// Da: https://accademiadellacrusca.it/it/consulenza/divisione-in-sillabe/302
// Ultimo punto critico della scansione sillabica sono i gruppi formati da tre vocali che vanno distinti in due casi:
// Quando formano un trittongo, in cui si può avere l'incontro di una semiconsonante, una vocale e una semivocale (es. iai, iei, uoi, uai, uei), oppure di due semiconsonanti e una vocale (solo iuo che nell'italiano contemporaneo tende a passare a io: barcaiuolo>barcaiolo; aiuola>aiola). Anche i trittonghi, in questi casi, formano un'unica sillaba e non andrebbero spezzati, quindi quei, miei, puoi, suoi, buoi, guai sono monosillabi;
    Substitute.fromSedExpr(r"s/([iu])-?([aeiouàèìòùáéíóú])-?([iu])/\1\2\3/Ig"),
// quando invece si tratta di una vocale seguita da un dittongo (es. aia, aio, aiu), si può andare a capo dopo la vocale, quindi ma-ia-le, cen-ti-na-io, a-iu-ta-re, pa-io-lo.
    Substitute.fromSedExpr(
        r"s/([aeiouàèìòùáéíóú])([iu][aeiouàèìòùáéíóú])/\1-\2/Ig"),

// *************************************************
// Altre regole
// *************************************************
    Substitute.fromSedExpr(r"s/-+/-/g"),

// Da: https://accademiadellacrusca.it/it/consulenza/divisione-in-sillabe/302
// Si dividono i gruppi costituiti da due consonanti uguali (tt, dd, ecc. e anche cq)
    Substitute.fromSedExpr(r"s/([bcdfghlmnpqrstvzjkwxy])\1/\1-\1/Ig"),

// Da: https://scriveregrammaticando.it/2019/12/30/la-divisione-in-sillabe-le-regole-fondamentali/
// Vocale seguita da un gruppo di due o più consonanti che può stare anche a inizio parola
    VersionedSubstitute.fromSedExpr(
        r"s/([aeiouàèìòùáéíóú])-?(g-?n|b-?r|c-?r|c-?l|d-?r|f-?l|f-?r|g-?r|m-?n|p-?n|p-?s|p-?r|p-?t|s-?c|s-?f|s-?n|s-?m|s-?p|s-?q|s-?r|s-?t|s-?v|t-?r|t-?l)/\1-\2/Ig",
        maxVersion: 6),
    VersionedSubstitute.fromSedExpr(
        r"s/([aeiouàèìòùáéíóú])-?(g-?n|b-?l|b-?r|c-?r|c-?l|d-?r|f-?l|f-?r|g-?l|g-?r|m-?n|p-?n|p-?s|p-?r|p-?t|s-?c|s-?f|s-?n|s-?m|s-?p|s-?q|s-?r|s-?t|s-?v|t-?r|t-?l)/\1-\2/Ig",
        minVersion: 7),

// Da: https://www.comunicaresulweb.com/scrittura/divisione-in-sillabe-sillabazione/
// Gruppi di consonanti che producono un suono unico
    Substitute.fromSedExpr(r"s/([cg])-([hnl])-?([aeiouàèìòùáéíóú])/\1\2\3/Ig"),
    Substitute.fromSedExpr(r"s/([cg]i)-([aeiouàèìòùáéíóú])/\1\2/Ig"),
    Substitute.fromSedExpr(r"s/p-s/ps/Ig"),
// NB: Non c'è modo di sapere a priori se una i in questi gruppi è muta o no,
// quindi questa regola è problematica e va aggiustata caso per caso.

// Da: https://www.comunicaresulweb.com/scrittura/divisione-in-sillabe-sillabazione/
// Una sillaba contiene sempre almeno una vocale, che costituisce una sorta di nucleo della sillaba stessa.
    Substitute.fromSedExpr(
        r"s/-([bcdfghlmnpqrstvzjkwxy])([^aeiouàèìòùáéíóúbcdfghlmnpqrstvzjkwxy'])/\1\2/Ig"),
    Substitute.fromSedExpr(r"s/-(([bcdfghlmnpqrstvzjkwxy])+)([ -])/\1\3/Ig"),
    Substitute.fromSedExpr(r"s/-([bcdfghlmnpqrstvzjkwxy])-/\1-/Ig"),
    Substitute.fromSedExpr(
        r"s/-([bcdfghlmnpqrstvzjkwxy])[^aeiouàèìòùáéíóúbcdfghlmnpqrstvzjkwxy']/\1-/Ig"), // can't use \b because accented letters are considered as boundary

// *************************************************
// Euristiche per casi particolari
// *************************************************

    // I derivati di "elegia" ma non di "lelegi" hanno la i accentata.
    Substitute.fromSedExpr(r"s/e-le-gi([ae])/e-le-gi-\1/Ig"),
    Substitute.fromSedExpr(r"s/le-le-gi-([ae])/le-le-gi\1/Ig"),

    // I derivati di "scia" e "spia" hanno la i accentata.
    Substitute.fromSedExpr(r"s/ scia/ sci-a/Ig"),
    Substitute.fromSedExpr(r"s/ spia/ spi-a/Ig"),

    // L'affisso -tria- ha spesso la i accentata, con qualche prevedibile
    // eccezione.
    Substitute.fromSedExpr(r"s/tria/tri-a/Ig"),
    Substitute.fromSedExpr(r"s/trie /tri-e /Ig"),
    Substitute.fromSedExpr(r"s/pa-tri-([ae]) /pa-tri\1 /Ig"),
    Substitute.fromSedExpr(r"s/e-spa-tri-a/e-spa-tria/Ig"),
    Substitute.fromSedExpr(r"s/rim-pa-tri-a/rim-pa-tria/Ig"),

    // Una serie di suffissi che finiscono in -ia e -ie hanno la i accentata
    Substitute.fromSedExpr(r"s/("
        r"lo-g|go-g|fa-g|ple-g|al-g|-tro-f|e-r|e-s|a-s|os-s|sm|i-s|[^r]-n"
        r"|[^m]m|ps|la-l|a-ch|cra-z|man-z|u-s|o-s|a-f|r-ra-g|er-g|o-d|t|v"
        r")i([ae]) /\1i-\2 /Ig"),

    // I plurali e i verbi in -ii hanno la prima i accentata.
    Substitute.fromSedExpr(r"s/ii /i-i /Ig"),

    Substitute.fromSedExpr(r"s/ia-c(a|o|i|he) /i-a-c\1 /Ig"),

    // Gli infissi "-ch-" e "-gh-" sono fusi alla vocale successiva, non a
    // quella precedente.
    Substitute.fromSedExpr(r"s/([aeiouàèìòùáéíóú])([cg]h[eièìéí])/\1-\2/Ig"),

    // Le parole che iniziano per "ri-" seguite da vocale si dividono dopo il
    // prefisso.
    Substitute.fromSedExpr(r"s/ -ri([aeiouàèìòùáéíóú])/ ri-\1/Ig"),
    Substitute.fromSedExpr(r"s/ ri-u-sc/ riu-sc/Ig"),

// *************************************************
// Ripulitura finale
// *************************************************

    Substitute.fromSedExpr(r"s/(\W)-([a-z])/\1\2/Ig"),
    Substitute.fromSedExpr(r"s/([a-z])-(\W)/\1\2/Ig"),
    Substitute.fromSedExpr(r"s/^-//g"),
    Substitute.fromSedExpr(r"s/-([^0-9a-zÀ-ÿ]*)$/\1/Ig"),
  ];

  /// Returns the hyphanetion points in the word (used to preserve the original case)
  static List<int> _getHyphenationPoints(String hyphenation) {
    List<int> positions = [];
    var dash = '-'.codeUnits.first;
    var pos = 0;
    for (var c in hyphenation.runes) {
      if (c == dash) {
        positions.add(pos - positions.length);
      }
      ++pos;
    }
    return positions;
  }

  /// Internal method used to hyphenate a word and preserve the original case
  static String _hyphenateAs(String word, List<int> positions) {
    var s = word.split('');
    for (var p in positions.reversed) {
      s.insert(p, '-');
    }
    return s.join();
  }

  /// Adds a user-define exception to the engine. The exception must
  /// be written as to include hyphenation dashes (for example, "pom-pie-re")
  static void addException(String hyphenation) {
    _exceptions.addAll({
      hyphenation.replaceAll('-', '').toUpperCase().trim():
          _getHyphenationPoints(hyphenation)
    });
  }

  /// Returns the list of current user-defined exceptions
  static List<String> getExceptions() {
    return _exceptions.keys.map((exception) {
      return _hyphenateAs(exception, _exceptions[exception.toUpperCase()]!);
    }).toList();
  }

  /// Returns the list of current built-in exceptions
  static List<String> getBuiltinExceptions() {
    return _builtInExceptions.keys.map((exception) {
      return _hyphenateAs(
          exception, _builtInExceptions[exception.toUpperCase()]!);
    }).toList();
  }

  /// Clears user-define exceptions
  static void clearExceptions() {
    _exceptions.clear();
  }

  /// Initializes the built-in exceptions
  static void _initBuiltInExceptions([int? version]) {
    if (_builtInExceptions.isEmpty || version != _initializationVersion) {
      _builtInExceptions.clear();
      final exceptions = [
        "li-u-to/i",
        "pi-o-lo/i",
        "pio-vra/e",
        "ma-gi-a/e",
        "al-ba-gi-a/e",
        "stra-te-gi-a/e",
        "con-tro-stra-te-gi-a/e",
        "se-ria/e",
        "fuo-ri-se-rie",
        "ar-de-sia/e",
        "ce-sia/e",
        "a-gen-zi-a/e",
        "mer-can-zi-a/e",
        "fe-ten-zi-a/e",
        "am-bro-sia/e",
        "ov-ve-ro-sia",
        "so-sia",
        "ma-fia/e",
        "pa-tria/e",
        "ar-te-mi-sia/e",
        "o-dia",
        "an-gu-stia/e",
        "zi-a/e",
        "zi-o/i",
        "paz-zi-a/e",
        "raz-zi-a/e",
        "fol-li-a/e",
        "re-gi-a/e",
        "si-a",
        "si-a-no",
        "man-gro-via/e",
        "o-stia/e",
        "be-go-nia/e",
        "i-o",
        "sci-o/i",
        "fot-ti-o/i",
        "schi-fi-o/i",
        "di-o",
        "mi-o",
        "fi-o",
        "pi-o/i",
        "ri-o/i",
        "fru-sci-o/i",
        "scal-pic-ci-o/i",
        "ca-lo-ri-a/e",
        "ri-a/e",
        "u-to-pi-a/e",
        "di-a-ria/e",
        "di-a-rio",
        "di-a-ri",
        "di-ur-no/i",
        "di-ur-na/e",
        "i-sba/e",
        "i-sba-glio",
        "i-sba-gli",
        "cir-cu-i-ta/e",
        "cir-cu-i-to/i",

        // When releasing new versions, move these exceptions to the unversioned
        // block above, update the version number and place new versioned
        // exceptions in this block below.
        if (version == null || version >= 7) ...[
          "o-bli-o/i",
        ]
      ];
      for (var e in exceptions) {
        int firstVariantEnd = e.indexOf('/');
        if (firstVariantEnd == -1) {
          _addBuiltInException(e);
        } else {
          _addBuiltInException(e.substring(0, firstVariantEnd));
          final secondVariant = e.substring(0, firstVariantEnd - 1) +
              e.substring(firstVariantEnd + 1);
          _addBuiltInException(secondVariant);
        }
      }
    }
  }

  static _addBuiltInException(String e) {
    _builtInExceptions[e.replaceAll('-', '').toUpperCase().trim()] =
        _getHyphenationPoints(e);
  }

  /// Hyphenates an input word and returns a list of syllables.
  /// User-defined exceptions are processed first, followed by built-in
  /// exceptions.
  static List<String> hyphenate(String word, {int? version}) {
    _initBuiltInExceptions(version);
    VersionedSubstitute.currentVersion = version;
    if (word.contains(_spaces)) {
      throw "$word is not a single word";
    }

    var isolatedWord =
        word.replaceAll(_nonWordStart, '').replaceAll(_nonWordEnd, '');
    word = word.replaceAll(
        '-', String.fromCharCode(0)); // Preserve the '-' character

    // Process user defined exceptions
    if (_exceptions.containsKey(isolatedWord.toUpperCase().trim())) {
      var before = _nonWordStart.firstMatch(word);
      var after = _nonWordEnd.firstMatch(word);
      var result =
          _hyphenateAs(isolatedWord, _exceptions[isolatedWord.toUpperCase()]!);
      result = result.replaceAll(
          String.fromCharCode(0), '-'); // Restore the '-' character
      var syllables = result.split('-');
      if (before != null && syllables.isNotEmpty) {
        syllables.first = before[0]! + syllables.first;
      }
      if (after != null && syllables.isNotEmpty) {
        syllables.last += after[0]!;
      }
      return syllables;
    }
    // Process built-in exceptions
    if (_builtInExceptions.containsKey(isolatedWord.toUpperCase().trim())) {
      var before = _nonWordStart.firstMatch(word);
      var after = _nonWordEnd.firstMatch(word);
      var result = _hyphenateAs(
          isolatedWord, _builtInExceptions[isolatedWord.toUpperCase()]!);
      result = result.replaceAll(
          String.fromCharCode(0), '-'); // Restore the '-' character
      var syllables = result.split('-');
      if (before != null && syllables.isNotEmpty) {
        syllables.first = before[0]! + syllables.first;
      }
      if (after != null && syllables.isNotEmpty) {
        syllables.last += after[0]!;
      }
      return syllables;
    }
    word = " $word "; // Add spaces around the word (since \b does not work)
    // Apply substitutions
    for (var s in _substitutions) {
      word = s.apply(word);
    }
    word = word.replaceAll(
        String.fromCharCode(0), '-'); // Restore the '-' character
    word = word.trim(); // Remove the spaces used to delimit the word
    return word.split('-');
  }
}
