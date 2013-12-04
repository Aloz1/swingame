//
//  SGSDK2Audio.cpp
//  sgsdl2
//
//  Created by Andrew Cain on 28/11/2013.
//  Copyright (c) 2013 Andrew Cain. All rights reserved.
//

#include "SGSDL2Audio.h"
#include "SDL.h"
#include "SDL_Mixer.h"
#include "sgBackendUtils.h"

#define SG_MAX_CHANNELS 64

Mix_Chunk * _sgsdl2_sound_channels[SG_MAX_CHANNELS];
Mix_Music * _current_music;

extern sg_system_data _sgsdk_system_data;


void sgsdl2_init_audio()
{
    Mix_Init(~0);
}

void sgsdl2_open_audio()
{
    if ( Mix_OpenAudio(MIX_DEFAULT_FREQUENCY, MIX_DEFAULT_FORMAT, 2, 4096 ) < 0 )
    {
        set_error_state("Unable to load audio. Mix_OpenAudio failed.");
        return;
    }

    Uint16 format;
    Mix_QuerySpec(&_sgsdk_system_data.audio_specs.audio_rate, &format, &_sgsdk_system_data.audio_specs.audio_channels);
    _sgsdk_system_data.audio_specs.times_opened++;
    _sgsdk_system_data.audio_specs.audio_format = format;
    
    Mix_AllocateChannels(SG_MAX_CHANNELS);
}

void sgsdl2_close_audio()
{
    Mix_CloseAudio();
    _sgsdk_system_data.audio_specs.times_opened--;
    if ( 0 == _sgsdk_system_data.audio_specs.times_opened )
    {
        sg_audiospec empty = { 0 };
        _sgsdk_system_data.audio_specs = empty;
    }
}

int sgsdl_get_channel(sg_sound_data *sound)
{
    for (int i = 0; i < SG_MAX_CHANNELS; i++)
    {
        if ( _sgsdl2_sound_channels[i] == sound->data && Mix_Playing(i) )
        {
            return i;
        }
    }
    return -1;
}



sg_sound_data sgsdl2_load_sound_data(const char * filename, sg_sound_kind kind)
{
    sg_sound_data result = { SGSD_UNKNOWN, NULL } ;
    
    result.kind = kind;
    
    switch (kind)
    {
        case SGSD_SOUND_EFFECT:
        {
            result.data = Mix_LoadWAV(filename);
            break;
        }
        case SGSD_MUSIC:
        {
            result.data = Mix_LoadMUS(filename);
            break;
        }
        default:
            break;
    }
    
    return result;
}

void sgsdl_close_sound_data(sg_sound_data * sound )
{
    if ( ! sound ) return;
    
    switch (sound->kind)
    {
        case SGSD_MUSIC:
            Mix_FreeMusic((Mix_Music*)sound->data);
            break;
        
        case SGSD_SOUND_EFFECT:
            Mix_FreeChunk((Mix_Chunk*)sound->data);
            break;
            
        default:
            break;
    }
    
    sound->kind = SGSD_UNKNOWN;
    sound->data = NULL;
}

void sgsdl2_play_sound(sg_sound_data * sound, int loops, float volume)
{
    if ( (!sound) || (!sound->data) ) return;
    
    switch (sound->kind)
    {
        case SGSD_SOUND_EFFECT:
        {
            Mix_Chunk *effect = (Mix_Chunk*) sound->data;
            int channel = Mix_PlayChannel( -1, effect, loops);
            if (channel >= 0 && channel < SG_MAX_CHANNELS)
            {
                Mix_Volume(channel, (int)(volume * 128));
                _sgsdl2_sound_channels[channel] = effect;   // record which channel is playing the effect
            }
            break;
        }
        case SGSD_MUSIC:
        {
            Mix_PlayMusic((Mix_Music *)sound->data, loops);
            Mix_VolumeMusic((int)volume * 128);
            _current_music = (Mix_Music *)sound->data;
            break;
        }
        default:
            break;
    }
}

float sgsdl2_sound_playing(sg_sound_data * sound)
{
    if ( ! sound ) {
        return 0.0f;
    }
    
    switch (sound->kind)
    {
        case SGSD_SOUND_EFFECT:
        {
            int idx = sgsdl_get_channel(sound);
            return ( idx >= 0 && idx < SG_MAX_CHANNELS ? 1.0f : 0.0f );
        }
        case SGSD_MUSIC:
        {
            if ( _current_music == sound->data && Mix_PlayingMusic() ) return 1.0f;
        }
            
        default:
            break;
    }
    
    return 0.0f;
}

void sgsdl2_fade_in(sg_sound_data *sound, int loops, int ms)
{
    if ( !sound ) return;
    
    switch (sound->kind)
    {
        case SGSD_SOUND_EFFECT:
        {
            int channel;
            channel = Mix_FadeInChannel(-1, (Mix_Chunk *)sound->data, loops, ms);
            if ( channel >= 0 && channel < SG_MAX_CHANNELS )
            {
                _sgsdl2_sound_channels[channel] = (Mix_Chunk *)sound->data;
            }
            break;
        }
            
        case SGSD_MUSIC:
        {
            Mix_FadeInMusic((Mix_Music *)sound->data, loops, ms);
            _current_music = (Mix_Music *)sound->data;
        }
            
        default:
            break;
    }
}

void sgsdl2_fade_out(sg_sound_data *sound, int ms)
{
    if ( !sound ) return;
    
    switch (sound->kind)
    {
        case SGSD_SOUND_EFFECT:
        {
            int channel = sgsdl_get_channel(sound);
            Mix_FadeOutChannel(channel, ms);
            break;
        }
            
        case SGSD_MUSIC:
        {
            if ( _current_music == sound->data )
                Mix_FadeOutMusic(ms);
        }
            
        default:
            break;
    }
}

void sgsdl2_load_audio_fns(sg_interface *functions)
{
    functions->audio.open_audio = & sgsdl2_open_audio;
    functions->audio.close_audio = & sgsdl2_close_audio;
    functions->audio.load_sound_data = & sgsdl2_load_sound_data;
    functions->audio.play_sound = & sgsdl2_play_sound;
    functions->audio.close_sound_data = & sgsdl_close_sound_data;
    functions->audio.sound_playing = &sgsdl2_sound_playing;
    functions->audio.fade_in = &sgsdl2_fade_in;
    functions->audio.fade_out = &sgsdl2_fade_out;
}

