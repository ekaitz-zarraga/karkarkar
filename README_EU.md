> [Read me in English in README.md](README.md)

# Karkarkar

Twitch kanal baten txata entzun.

## Nola

Karkarkarrek AhoTTS, Aholab Bilboko Ingenieritza eskolan kokatutako ikerkuntza
taldeak garatutako TTS sistemaren bertsio aldatu bat eta OpenAL erabiltzen
ditu. Karkarkar  oso IRC bezero sinple bat erabiliz  socket baten bitartez
Twitch-en IRC-ra konektatzen da eta mezu guztiak hartu eta ozenean irakurtzen
ditu aipatutako liburutegiak erabiliz.

## Kodea konpilatzeko

Zig 0.11.0 erabili behar da kodea konpilatzeko eta hauek dira kodearen
dependentziak:

- OpenAL-en implementazio bat: [OpenAL-soft][openal] erabili da, baina beste
  edozein erabili daiteke.

[openal]: https://openal-soft.org/

- [AhoTTS-ren bertsio aldatua][ahotts]. Planak daude AhoTTS asko aldatzeko,
  arazo estrukturalak eta bugak dituelako.

[ahotts]: https://github.com/ekaitz-zarraga/AhoTTS

## Copyrighta

GPL 3.0+, azpiliburutegiek erabiltzen duten lizentzia bera. Ikusi LICENSE.txt.

AhoTTSrekin ahotsak eta hiztegiak instalatu behar dira, horiek CC-BY 3.0
lizentzia dute.
