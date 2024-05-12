/* SPDX-License-Identifier: GPL-2.0-or-later */

#ifndef __WAVE_H__
#define __WAVE_H__

#include <stdint.h>
#include <stdio.h>

struct SimpleWAV
{
    char ck0ID[5], waveID[5], formatID[5], dataID[5];
    uint32_t ck0size, formatSize;
    uint32_t nSamplesPerSec, dataRate;
    uint16_t formatTag, nChannels;
    uint16_t blockAlign, bitsPerSample;
    uint32_t dataSize;
};

void dumpWAVheader(struct SimpleWAV *wav);
int getWAVHeader(char *buf, struct SimpleWAV *wav);
void initWAV(struct SimpleWAV *wav, uint32_t samples_per_second, uint32_t duration);
int parseWAVHeader(FILE *fp, struct SimpleWAV *wav);

// Wavetable functions

struct WavetableFixed {
    uint16_t fixed_index;
    uint16_t fixed_incr;
};

void get_table_samples(struct WavetableFixed *table, uint8_t *buffer, uint16_t len);
void init_wavetable(struct WavetableFixed *table, int table_len, double frequency, uint32_t samples_per_second);

#endif