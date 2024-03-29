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
}
