extends RefCounted

const AUDIO_MIX_RATE := 22050.0


static func get_radio_tracks() -> Array:
	return [
		{"name": "Drift", "progression": [55.0, 82.41, 73.42, 98.0], "accent": [220.0, 246.94, 196.0, 164.81], "pulse": 0.125},
		{"name": "Nebula FM", "progression": [61.74, 92.5, 82.41, 110.0], "accent": [164.81, 220.0, 246.94, 293.66], "pulse": 0.142},
		{"name": "Deep Relay", "progression": [49.0, 65.41, 73.42, 87.31], "accent": [146.83, 196.0, 220.0, 174.61], "pulse": 0.11},
		{"name": "Blue Shift", "progression": [69.3, 92.5, 103.83, 82.41], "accent": [277.18, 329.63, 246.94, 220.0], "pulse": 0.133},
		{"name": "Night Freight", "progression": [41.2, 55.0, 61.74, 73.42], "accent": [123.47, 164.81, 185.0, 146.83], "pulse": 0.098},
		{"name": "Helios Late", "progression": [58.27, 87.31, 77.78, 116.54], "accent": [233.08, 261.63, 311.13, 196.0], "pulse": 0.152},
		{"name": "Ion Caravan", "progression": [46.25, 69.3, 58.27, 77.78], "accent": [138.59, 174.61, 207.65, 233.08], "pulse": 0.104},
		{"name": "Starwake", "progression": [65.41, 98.0, 87.31, 130.81], "accent": [196.0, 261.63, 293.66, 246.94], "pulse": 0.148},
		{"name": "Port Authority After Dark", "progression": [51.91, 77.78, 69.3, 92.5], "accent": [155.56, 207.65, 233.08, 185.0], "pulse": 0.119},
		{"name": "Cold Dock Lights", "progression": [43.65, 58.27, 65.41, 73.42], "accent": [130.81, 174.61, 196.0, 155.56], "pulse": 0.094},
		{"name": "Mercury Static", "progression": [73.42, 110.0, 98.0, 82.41], "accent": [246.94, 329.63, 277.18, 220.0], "pulse": 0.162},
		{"name": "Lagrange Velvet", "progression": [52.0, 69.3, 82.41, 61.74], "accent": [207.65, 233.08, 261.63, 174.61], "pulse": 0.128}
	]


static func generate_radio_sample(track: Dictionary, time_value: float) -> float:
	var progression: Array = track["progression"]
	var accent: Array = track["accent"]
	var pulse_rate: float = track["pulse"]
	var chord_index := int(floor(time_value / 3.2)) % progression.size()
	var beat_phase := fmod(time_value, 0.8) / 0.8
	var low_freq: float = progression[chord_index]
	var high_freq: float = accent[chord_index]
	var drift_a := sin(time_value * TAU * (0.021 + low_freq * 0.00008))
	var drift_b := sin(time_value * TAU * (0.015 + high_freq * 0.00004))
	var drone := sin(time_value * TAU * low_freq) * 0.13 + sin(time_value * TAU * (low_freq * 1.5 + drift_a * 0.7)) * 0.06
	var shimmer_gate := pow(max(0.0, sin(beat_phase * PI)), 3.0)
	var shimmer := sin(time_value * TAU * (high_freq + drift_b * 1.6)) * shimmer_gate * 0.032
	var pulse := sin(time_value * TAU * pulse_rate) * 0.024
	var sub := sin(time_value * TAU * (low_freq * 0.5)) * 0.032
	return drone + shimmer + pulse + sub


static func build_player_fire_stream() -> AudioStreamWAV:
	return build_tone_stream([1580.0, 1240.0, 980.0, 760.0], 0.08, 0.18, 0.05, 1.35)


static func build_enemy_fire_stream() -> AudioStreamWAV:
	return build_tone_stream([240.0, 210.0, 180.0], 0.16, 0.24, 0.1, 0.7)


static func build_dock_stream() -> AudioStreamWAV:
	return build_tone_stream([330.0, 440.0, 554.37], 0.34, 0.2, 0.12, 0.8)


static func build_hit_stream() -> AudioStreamWAV:
	return build_noise_stream(0.18, 0.26, 0.55)


static func build_alert_stream() -> AudioStreamWAV:
	return build_tone_stream([523.25, 659.25], 0.18, 0.18, 0.1, 0.75)


static func build_enemy_down_stream() -> AudioStreamWAV:
	return build_tone_stream([220.0, 164.81, 123.47], 0.28, 0.24, 0.14, 0.85)


static func build_loss_stream() -> AudioStreamWAV:
	return build_tone_stream([196.0, 146.83, 110.0, 82.41], 0.6, 0.2, 0.18, 0.95)


static func build_comms_stream() -> AudioStreamWAV:
	return build_tone_stream([880.0, 554.37, 698.46, 466.16], 0.26, 0.16, 0.08, 0.82)


static func build_autopilot_lock_stream() -> AudioStreamWAV:
	return build_tone_stream([392.0, 523.25, 659.25, 783.99], 0.22, 0.18, 0.03, 1.05)


static func build_launch_stream() -> AudioStreamWAV:
	return build_tone_stream([220.0, 330.0, 440.0, 554.37], 0.42, 0.24, 0.08, 0.95)


static func build_radio_loop_stream(track_index: int = 0) -> AudioStreamWAV:
	var duration := 24.0
	var sample_count := int(AUDIO_MIX_RATE * duration)
	var data := PackedByteArray()
	data.resize(sample_count * 2)
	var phase_a := 0.0
	var phase_b := 0.0
	var phase_c := 0.0
	var tracks := get_radio_tracks()
	var selected_track: Dictionary = tracks[clamp(track_index, 0, tracks.size() - 1)]
	var progression: Array = selected_track["progression"]
	var accent: Array = selected_track["accent"]
	var pulse_rate: float = selected_track["pulse"]
	for i in range(sample_count):
		var t := float(i) / AUDIO_MIX_RATE
		var chord_index := int(floor(t / 3.2)) % progression.size()
		var beat_phase := fmod(t, 0.8) / 0.8
		var low_freq: float = progression[chord_index]
		var high_freq: float = accent[chord_index]
		phase_a += TAU * low_freq / AUDIO_MIX_RATE
		phase_b += TAU * (low_freq * 1.5) / AUDIO_MIX_RATE
		phase_c += TAU * high_freq / AUDIO_MIX_RATE
		var drone := sin(phase_a) * 0.18 + sin(phase_b) * 0.09
		var shimmer_gate := pow(max(0.0, sin(beat_phase * PI)), 3.0)
		var shimmer := sin(phase_c) * shimmer_gate * 0.04
		var pulse := sin(t * TAU * pulse_rate) * 0.02
		write_pcm16_sample(data, i, clamp(drone + shimmer + pulse, -0.55, 0.55))
	var stream := create_wav_stream(data)
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = sample_count
	return stream


static func build_tone_stream(
	frequencies: Array,
	duration: float,
	amplitude: float,
	vibrato_depth: float,
	decay_power: float
) -> AudioStreamWAV:
	var sample_count := int(AUDIO_MIX_RATE * duration)
	var data := PackedByteArray()
	data.resize(sample_count * 2)
	var phase := 0.0
	for i in range(sample_count):
		var t := float(i) / AUDIO_MIX_RATE
		var envelope := pow(max(0.0, 1.0 - t / duration), decay_power)
		var freq: float = frequencies[min(int(floor(t / duration * frequencies.size())), frequencies.size() - 1)]
		var modulated_freq := freq * (1.0 + sin(t * TAU * 5.0) * vibrato_depth * 0.02)
		phase += TAU * modulated_freq / AUDIO_MIX_RATE
		var sample := sin(phase) * amplitude * envelope + sin(phase * 0.5) * amplitude * 0.18 * envelope
		write_pcm16_sample(data, i, sample)
	return create_wav_stream(data)


static func build_noise_stream(duration: float, amplitude: float, decay_power: float) -> AudioStreamWAV:
	var sample_count := int(AUDIO_MIX_RATE * duration)
	var data := PackedByteArray()
	data.resize(sample_count * 2)
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var filter := 0.0
	for i in range(sample_count):
		var t := float(i) / AUDIO_MIX_RATE
		var envelope := pow(max(0.0, 1.0 - t / duration), decay_power)
		filter = lerp(filter, rng.randf_range(-1.0, 1.0), 0.42)
		var sample := filter * amplitude * envelope
		write_pcm16_sample(data, i, sample)
	return create_wav_stream(data)


static func write_pcm16_sample(data: PackedByteArray, index: int, sample: float) -> void:
	var clamped: float = clamp(sample, -1.0, 1.0)
	var pcm := int(round(clamped * 32767.0))
	if pcm < 0:
		pcm += 65536
	data[index * 2] = pcm & 0xff
	data[index * 2 + 1] = (pcm >> 8) & 0xff


static func create_wav_stream(data: PackedByteArray) -> AudioStreamWAV:
	var stream := AudioStreamWAV.new()
	stream.data = data
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = AUDIO_MIX_RATE
	stream.stereo = false
	return stream
