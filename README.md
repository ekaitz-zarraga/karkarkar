> [Read me in Basque in README_EU.md](README_EU.md)

# Karkarkar

Listen to a Twitch chat in Basque.

## How

Karkarkar uses a modified AhoTTS library, a TTS system developed by the Aholab
team at the Bilbao Engineering school (included in the project), and OpenAL
(external library). Karkarkar connects to Twitch's IRC using a socket and a
extremely reduced IRC client implementation to listen to all the messages from
a user and play them out loud using the mentioned libraries.

## How to compile

Zig 0.11.0. These are the dependencies:

- OpenAL: [OpenAL-soft][openal] has been used, but any other implementation
  should work.

[openal]: https://openal-soft.org/

## Copyright

GPL 3.0+, same as dependencies. See LICENSE.txt.

AhoTTS needs voices and dictionaries to work, those use CC-BY 3.0 license.
