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
import 'package:semola/semola.dart';
import 'package:test/test.dart';

void main() {
  test('Test with basic rules', () {
    expect(Semola.hyphenate(r"suonò"), ["suo", "nò"]);
    expect(Semola.hyphenate(r"pompiere"), ["pom", "pie", "re"]);
    expect(Semola.hyphenate(r"lunghissimo"), ["lun", "ghis", "si", "mo"]);
    expect(Semola.hyphenate(r"per"), ["per"]);
    expect(Semola.hyphenate(r"perché,"), ["per", "ché,"]);
    expect(Semola.hyphenate("perché\""), ["per", "ché\""]);
    expect(Semola.hyphenate("CACTUS"), ["CAC", "TUS"]);
    expect(Semola.hyphenate("Cactus"), ["Cac", "tus"]);
    expect(Semola.hyphenate("cactus"), ["cac", "tus"]);
    expect(Semola.hyphenate("appioppare"), ["ap", "piop", "pa", "re"]);
    expect(Semola.hyphenate("viola"), ["vio", "la"]);
    expect(Semola.hyphenate(r"suonò..."), ["suo", "nò..."]);
    expect(Semola.hyphenate(r"pompiere..."), ["pom", "pie", "re..."]);
    expect(Semola.hyphenate(r"lunghissimo..."), ["lun", "ghis", "si", "mo..."]);
    expect(Semola.hyphenate(r"per..."), ["per..."]);
    expect(Semola.hyphenate(r"è"), ["è"]);
    expect(Semola.hyphenate("è"), ["è"]);
    expect(Semola.hyphenate(r"à"), ["à"]);
    expect(Semola.hyphenate("à"), ["à"]);
    expect(Semola.hyphenate(r"ì"), ["ì"]);
    expect(Semola.hyphenate("ì"), ["ì"]);
  });

  test('Test with built-in exceptions', () {
    expect(Semola.hyphenate("piovra"), ["pio", "vra"]);
    expect(Semola.hyphenate("pioli"), ["pi", "o", "li"]);
    expect(Semola.hyphenate("piovra..."), ["pio", "vra..."]);
    expect(Semola.hyphenate("pioli..."), ["pi", "o", "li..."]);
    expect(Semola.hyphenate(r"è"), ["è"]);
    expect(Semola.hyphenate("è"), ["è"]);
    expect(Semola.hyphenate(r"à"), ["à"]);
    expect(Semola.hyphenate("à"), ["à"]);
    expect(Semola.hyphenate(r"ì"), ["ì"]);
    expect(Semola.hyphenate("ì"), ["ì"]);
  });

  group('Tests to remove redundant rules from v0.0.4', () {
    test('Test with "-nst-", "-rst-", "-sch-"', () {
      expect(Semola.hyphenate("consta"), ["con", "sta"]);
      expect(Semola.hyphenate("interstizio"), ["in", "ter", "sti", "zio"]);
      expect(Semola.hyphenate("raschiare"), ["ra", "schia", "re"]);
      expect(Semola.hyphenate("farseschi"), ["far", "se", "schi"]);
      expect(Semola.hyphenate("fiaschi"), ["fia", "schi"]);
    });
  });

  group('Tests with problematic cases, unsupported by v0.0.4', () {
    test('Test with "-agia", "-agie"', () {
      expect(Semola.hyphenate("magia"), ["ma", "gi", "a"]);
      expect(Semola.hyphenate("magie"), ["ma", "gi", "e"]);
      expect(Semola.hyphenate("magico"), ["ma", "gi", "co"]);
      expect(Semola.hyphenate("aerofagia"), ["a", "e", "ro", "fa", "gi", "a"]);
      expect(Semola.hyphenate("acquaragia"), ["ac", "qua", "ra", "gia"]);
    });

    test('Test with "-egia", "-egie", "-egio"', () {
      expect(Semola.hyphenate("paraplegia"), ["pa", "ra", "ple", "gi", "a"]);
      expect(Semola.hyphenate("nostalgia"), ["no", "stal", "gi", "a"]);
      expect(Semola.hyphenate("nostalgie"), ["no", "stal", "gi", "e"]);
      expect(Semola.hyphenate("bolgia"), ["bol", "gia"]);
      expect(Semola.hyphenate("bolge"), ["bol", "ge"]);
      expect(Semola.hyphenate("ciliegie"), ["ci", "lie", "gie"]);
      expect(Semola.hyphenate("egregio"), ["e", "gre", "gio"]);
      expect(Semola.hyphenate("egregia"), ["e", "gre", "gia"]);
      expect(Semola.hyphenate("elegia"), ["e", "le", "gi", "a"]);
      expect(Semola.hyphenate("elegiaco"), ["e", "le", "gi", "a", "co"]);
      // https://it.wikipedia.org/wiki/Lelegi
      expect(Semola.hyphenate("lelegie"), ["le", "le", "gie"]);
      expect(Semola.hyphenate("strategia"), ["stra", "te", "gi", "a"]);
    });

    test('Test with "-ogia", "-ogio"', () {
      expect(Semola.hyphenate("orologiaio"), ["o", "ro", "lo", "gia", "io"]);
      expect(Semola.hyphenate("mogia"), ["mo", "gia"]);
      expect(Semola.hyphenate("mogio"), ["mo", "gio"]);
      expect(Semola.hyphenate("frogia"), ["fro", "gia"]);
      expect(Semola.hyphenate("biologia"), ["bio", "lo", "gi", "a"]);
      expect(Semola.hyphenate("demagogia"), ["de", "ma", "go", "gi", "a"]);
    });

    test('Test with "-tria-"', () {
      expect(Semola.hyphenate("patria"), ["pa", "tria"]);
      expect(Semola.hyphenate("patrie"), ["pa", "trie"]);
      expect(Semola.hyphenate("triangolo"), ["tri", "an", "go", "lo"]);
      expect(Semola.hyphenate("diottria"), ["diot", "tri", "a"]);
      expect(Semola.hyphenate("diottrie"), ["diot", "tri", "e"]);
      expect(Semola.hyphenate("rimpatriata"), ["rim", "pa", "tria", "ta"]);
      expect(Semola.hyphenate("espatriava"), ["e", "spa", "tria", "va"]);
    });

    test('Test with many short "-ia" ("-ìa") words', () {
      // These words are all to be hyphenated as "i-a" and not "ia"
      List<String> words = [
        "afachia",
        "afasia",
        "afrasia",
        "agenzia",
        "ageusia",
        "agnosia",
        "agrafia",
        "albagia",
        "algesia",
        "ametria",
        "anergia",
        "anosmia",
        "anossia",
        "aplasia",
        "aplisia",
        "aritmia",
        "armeria",
        "armonia",
        "atrofia",
        "balogia",
        "bareria",
        "baronia",
        "bigamia",
        "binomia",
        "biopsia",
        "bonomia",
        "canonia",
        "cereria",
        "cerusia",
        "coieria",
        "cokeria",
        "colemia",
        "diceria",
        "difonia",
        "digamia",
        "dilalia",
        "dilogia",
        "dipodia",
        "cirusia",
        "scia",
        "stantia",
        "pazzia",
        "razzia",
        "follia",
        "mia",
        "sia",
        "zia",
        "via",
        "ovovia",
        "spia",
      ];
      for (var word in words) {
        final hyphenated = Semola.hyphenate(word);
        expect(hyphenated.last, "a",
            reason: '"$word" was hyphenated as "${hyphenated.join('-')}"');
      }
    });

    test('Test with many short "-ia" ("-ja") words', () {
      // These words are all to be hyphenated as "ia" and not "i-a"
      List<String> words = [
        "marchia",
        "ostia",
        "macchia",
        "coscia",
        "begonia",
        "camelia",
        "copia",
        "coppia",
        "scoria",
        "macerie",
        "cazzia",
        "smacchia",
        "rotaia",
        "mannaia",
        "sedia",
      ];
      for (var word in words) {
        final hyphenated = Semola.hyphenate(word);
        expect(hyphenated.last, isNot("a"),
            reason: '"$word" was hyphenated as "${hyphenated.join('-')}"');
      }
    });

    test('Test with words derived from Latin "dies"', () {
      expect(Semola.hyphenate("diario"), ["di", "a", "rio"]);
      expect(Semola.hyphenate("diaria"), ["di", "a", "ria"]);
      expect(Semola.hyphenate("diurno"), ["di", "ur", "no"]);
      expect(Semola.hyphenate("diurna"), ["di", "ur", "na"]);
      expect(Semola.hyphenate("quotidiano"), ["quo", "ti", "dia", "no"]);
    });

    test('Test with words like "VChV-', () {
      expect(Semola.hyphenate("aghi"), ["a", "ghi"]);
      expect(Semola.hyphenate("oche"), ["o", "che"]);
      expect(Semola.hyphenate("echi"), ["e", "chi"]);
      expect(Semola.hyphenate("acheo"), ["a", "che", "o"]);
      expect(Semola.hyphenate("achee"), ["a", "che", "e"]);
    });

    test('Test with words with unusual "-VCC-"', () {
      expect(Semola.hyphenate("pepsina"), ["pe", "psi", "na"]);
      expect(Semola.hyphenate("sbagli"), ["sba", "gli"]);
      expect(Semola.hyphenate("uguali"), ["u", "gua", "li"]);
      expect(Semola.hyphenate("eguali"), ["e", "gua", "li"]);
      expect(Semola.hyphenate("eguaglianza"), ["e", "gua", "glian", "za"]);
      expect(Semola.hyphenate("guaglione"), ["gua", "glio", "ne"]);
      expect(Semola.hyphenate("uguagli"), ["u", "gua", "gli"]);
      expect(Semola.hyphenate("uguaglia"), ["u", "gua", "glia"]);
      expect(Semola.hyphenate("uguagliai"), ["u", "gua", "gliai"]);
      expect(Semola.hyphenate("uguaglianza"), ["u", "gua", "glian", "za"]);
      expect(Semola.hyphenate("obli"), ["o", "bli"]);
      expect(Semola.hyphenate("obla"), ["o", "bla"]);
      expect(Semola.hyphenate("obliqui"), ["o", "bli", "qui"]);
      expect(Semola.hyphenate("obliqua"), ["o", "bli", "qua"]);
      expect(Semola.hyphenate("oblii"), ["o", "bli", "i"]);
      expect(Semola.hyphenate("oblio"), ["o", "bli", "o"]);
    });

    test('Test with "ri-"', () {
      expect(Semola.hyphenate("rianimare"), ["ri", "a", "ni", "ma", "re"]);
      expect(Semola.hyphenate("riaversi"), ["ri", "a", "ver", "si"]);
      expect(Semola.hyphenate("riarmo"), ["ri", "ar", "mo"]);
      expect(Semola.hyphenate("abbarriamo"), ["ab", "bar", "ria", "mo"]);
      expect(Semola.hyphenate("abbeveriamo"), ["ab", "be", "ve", "ria", "mo"]);
      expect(Semola.hyphenate("ria"), ["ri", "a"]);
      expect(Semola.hyphenate("rio"), ["ri", "o"]);
      expect(Semola.hyphenate("rii"), ["ri", "i"]);
      expect(Semola.hyphenate("riattivo"), ["ri", "at", "ti", "vo"]);
      expect(Semola.hyphenate("riedizione"), ["ri", "e", "di", "zio", "ne"]);
      expect(Semola.hyphenate("riuscito"), ["riu", "sci", "to"]);
      expect(Semola.hyphenate("riutilizziamolo"),
          ["ri", "u", "ti", "liz", "zia", "mo", "lo"]);
    });

    test('Test with edge cases and detected bugs', () {
      expect(Semola.hyphenate("isba"), ["i", "sba"]);
      expect(Semola.hyphenate("isbe"), ["i", "sbe"]);
      expect(Semola.hyphenate("isbaglio"), ["i", "sba", "glio"]);
      // Get the most favourable interpretation
      expect(Semola.hyphenate("circuito"), ["cir", "cu", "i", "to"]);
    });
  });

  test('Test with user exceptions', () {
    assert(Semola.getBuiltinExceptions().isNotEmpty);
    assert(Semola.getBuiltinExceptions().contains("PI-O-LO"));
    assert(Semola.getExceptions().isEmpty);
    Semola.addException("p-i-o-v-r-a");
    assert(Semola.getExceptions().isNotEmpty);
    expect(Semola.hyphenate("piovra"), ["p", "i", "o", "v", "r", "a"]);
    expect(Semola.getExceptions(), ["P-I-O-V-R-A"]);
    Semola.addException("p-i-o-v-r-e");
    expect(Semola.getExceptions(), ["P-I-O-V-R-A", "P-I-O-V-R-E"]);
    Semola.clearExceptions();
    assert(Semola.getExceptions().isEmpty);
    expect(Semola.hyphenate("piovra"), ["pio", "vra"]);
    expect(Semola.hyphenate(r"è"), ["è"]);
    expect(Semola.hyphenate("è"), ["è"]);
    expect(Semola.hyphenate(r"à"), ["à"]);
    expect(Semola.hyphenate("à"), ["à"]);
    expect(Semola.hyphenate(r"ì"), ["ì"]);
    expect(Semola.hyphenate("ì"), ["ì"]);
  });

  test('Test with versions', () {
    expect(Semola.hyphenate("isba", version: 6), ["i", "sba"]);
    expect(Semola.hyphenate("riadattare", version: 6),
        ["ri", "a", "dat", "ta", "re"]);

    expect(Semola.hyphenate("obli", version: 6), ["obli"]);
    expect(Semola.hyphenate("oblio", version: 6), ["oblio"]);
    expect(Semola.hyphenate("uguagli", version: 6), ["u", "guagli"]);
    expect(Semola.hyphenate("obli", version: 7), ["o", "bli"]);
    expect(Semola.hyphenate("oblio", version: 7), ["o", "bli", "o"]);
    expect(Semola.hyphenate("uguagli", version: 7), ["u", "gua", "gli"]);

    // Test that the default version is the latest one
    // When a new version is released, update this test with one of the latest
    // added words/rules
    expect(
        Semola.hyphenate("uguagli"), Semola.hyphenate("uguagli", version: 7));
  });
}
