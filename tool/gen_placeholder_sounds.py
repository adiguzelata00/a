"""Synthesizes the placeholder sound effects in assets/audio/.

16-bit mono WAV, 22.05 kHz. Run from the project root:

    python3 tool/gen_placeholder_sounds.py

Real recordings can replace these files later; keep the file names
(the SoundId enum names in snake_case).
"""
import math
import random
import struct
import wave

SR = 22050
random.seed(7)


def env(i, n, attack=0.005, release=None):
    t = i / SR
    a = min(1.0, t / attack) if attack > 0 else 1.0
    r = 1.0 - i / n if release is None else math.exp(-t / release)
    return a * max(0.0, r)


def write(name, samples, gain=0.6):
    peak = max(1e-9, max(abs(s) for s in samples))
    with wave.open(f'assets/audio/{name}.wav', 'wb') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(b''.join(
            struct.pack('<h', int(32767 * gain * s / peak)) for s in samples))


def tone(freqs, dur, release, attack=0.004, shape='sine'):
    n = int(SR * dur)
    out = []
    for i in range(n):
        t = i / SR
        v = 0
        for f in freqs:
            ph = 2 * math.pi * f * t
            v += math.sin(ph) if shape == 'sine' else (
                math.sin(ph) + 0.3 * math.sin(2 * ph))
        out.append(v / len(freqs) * env(i, n, attack, release))
    return out


def noise(dur, release, lp=0.3):
    n = int(SR * dur)
    out = []
    prev = 0.0
    for i in range(n):
        prev = prev + lp * (random.uniform(-1, 1) - prev)
        out.append(prev * env(i, n, 0.001, release))
    return out


def mix(*parts):
    n = max(len(p) for p in parts)
    return [sum(p[i] if i < len(p) else 0 for p in parts) for i in range(n)]


def seq(notes, step, dur, release):
    out = [0.0] * int(SR * (step * len(notes) + dur))
    for k, f in enumerate(notes):
        s = tone([f, f * 2], dur, release, shape='rich')
        off = int(SR * step * k)
        for i, v in enumerate(s):
            out[off + i] += v
    return out


def drum(f0, f1, dur, release):
    n = int(SR * dur)
    out = []
    ph = 0
    for i in range(n):
        f = f1 + (f0 - f1) * math.exp(-i / SR / 0.04)
        ph += 2 * math.pi * f / SR
        out.append(math.sin(ph) * env(i, n, 0.002, release))
    return out


# Bakelite click: short bright noise + tick.
write('tile_tap', mix(noise(0.04, 0.008, 0.7),
                      [0.5 * v for v in tone([2400], 0.03, 0.006)]), 0.5)
# Tile placed on wood: low knock.
write('tile_place', mix(tone([190, 285], 0.09, 0.025),
                        [0.6 * v for v in noise(0.06, 0.012, 0.25)]), 0.6)
# Drawing tiles: soft swish.
write('tile_draw', noise(0.16, 0.05, 0.08), 0.45)
# Chips count: bright blip.
write('chips', tone([880, 1320], 0.08, 0.025), 0.45)
# Mult: lower, rounder blip.
write('mult', tone([523, 784], 0.1, 0.03, shape='rich'), 0.5)
# xMult: bright chord.
write('x_mult', tone([523, 659, 784, 1046], 0.22, 0.07, shape='rich'), 0.55)
# Kut trigger: shaman drum (pitch drop) with a skin rattle.
write('kut_trigger', mix(drum(150, 70, 0.28, 0.09),
                         [0.25 * v for v in noise(0.12, 0.03, 0.4)]), 0.7)
# Akçe: two-tone coin.
write('money', mix(tone([1318], 0.09, 0.04),
                   [0] * int(SR * 0.06) + tone([1760], 0.14, 0.05)), 0.45)
# Hand scored: quick rising arpeggio.
write('hand_scored', seq([392, 523, 659, 784], 0.045, 0.18, 0.06), 0.5)
# Round won: major arpeggio.
write('round_won', seq([523, 659, 784, 1046, 1318], 0.09, 0.4, 0.15), 0.55)
# Round lost: descending minor.
write('round_lost', seq([392, 311, 262, 196], 0.14, 0.45, 0.2), 0.5)


# ---------------------------------------------------------------- music
# 16 s seamless loop: drone on D with slowly sweeping overtones (throat-
# singing like) and plucked kopuz notes (Karplus-Strong) on a D minor
# pentatonic scale. Lower sample rate keeps the file small.
def music_loop():
    sr = 11025
    seconds = 16
    n = sr * seconds
    base = 73.5  # 73.5 Hz × 16 s = whole cycles, so the loop is seamless
    out = [0.0] * n
    for i in range(n):
        t = i / sr
        v = 0.0
        for h, w in ((1, 1.0), (2, 0.6), (3, 0.35), (4, 0.2)):
            v += w * math.sin(2 * math.pi * base * h * t)
        # Overtone "melody": harmonics 6-12 rise and fall twice per loop.
        sweep = 9 + 3 * math.sin(2 * math.pi * t / 8)
        for h in range(6, 13):
            g = math.exp(-((h - sweep) ** 2) / 0.8)
            v += 0.25 * g * math.sin(2 * math.pi * base * h * t)
        out[i] = 0.35 * v
    rng = random.Random(11)
    scale = [146.8, 174.6, 196.0, 220.0, 261.6, 293.7]
    t = 0.5
    while t < seconds - 1.5:
        f = rng.choice(scale)
        period = int(sr / f)
        buf = [rng.uniform(-1, 1) for _ in range(period)]
        start = int(t * sr)
        length = int(1.4 * sr)
        for k in range(length):
            idx = k % period
            nxt = (idx + 1) % period
            buf[idx] = 0.996 * 0.5 * (buf[idx] + buf[nxt])
            out[(start + k) % n] += 0.5 * buf[idx]
        t += rng.choice([0.5, 0.5, 1.0, 1.5])
    peak = max(abs(s) for s in out)
    with wave.open('assets/audio/music_steppe.wav', 'wb') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(sr)
        w.writeframes(b''.join(
            struct.pack('<h', int(32767 * 0.5 * s / peak)) for s in out))


music_loop()
