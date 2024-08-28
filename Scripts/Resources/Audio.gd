extends Node

# it's autoloaded
# this script will hold most of the audios and play them
# the method is "play" and you can access it's possible sounds

var ring = load("res://Audio/ring.wav")
var ring_spread = load("res://Audio/ring_spread.wav")
var jump = load("res://Audio/character/jump.wav")
var spin = load("res://Audio/character/spin.wav")
var step = load("res://Audio/step concrete.wav")
var attack1 = load("res://Audio/character/attack1.wav")
var attack2 = load("res://Audio/character/attack2.wav")
var attackStrong = load("res://Audio/character/attackStrong.wav")
var dash = load("res://Audio/character/dash3.wav")
var airDash = load("res://Audio/character/airDash.wav")
var bounce = load("res://Audio/character/bounce2.wav")
var spindashRelease = load("res://Audio/character/spindashRelease.wav")
var shot = load("res://Audio/character/shot.wav")
var groundSet = load("res://Audio/character/groundSet.wav")
var airSet = load("res://Audio/character/airSet.wav")
var setExplosion = load("res://Audio/character/setExplosion.wav")
var heal = load("res://Audio/character/heal.wav")
var hit = load("res://Audio/character/hit.wav")
var hitStrong = load("res://Audio/character/hitStrong.wav")

const VOLUME: int = -16

## method to play audio
func play(audio_to_play: AudioStream, object_to_add_sound: Node3D = get_tree().current_scene, new_volume = VOLUME, new_pitch = 1, return_the_player = false):
	# check if audio track exists
	if audio_to_play != null:
		# create an instance of a AudioStreamPlayer3D
		var audio_player_object = Instantiables.AUDIO_INSTANCE.instantiate()
		# the actual audio player is the child of that scene
		var audio_player = audio_player_object.get_child(0)
		
		# the following variables are optional
		# when calling an audio
		# set volume
		audio_player.volume_db = new_volume
		# set attenuation cutoff
		audio_player.attenuation_filter_cutoff_hz = 10000
		# set attenuation in decibels
		audio_player.attenuation_filter_db = 0
		# set the pitch
		audio_player.pitch_scale = new_pitch
		# set a limit to the volmue
		audio_player.max_db = new_volume
		# set which audio to play
		audio_player.stream = audio_to_play
		
		# set where the audio scene will be placed
		object_to_add_sound.add_child(audio_player_object)
		# play the audio
		audio_player.play()
		
		if return_the_player:
			return audio_player
