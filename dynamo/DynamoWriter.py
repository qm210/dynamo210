import pyperclip
import struct
from pathlib import Path
from os import getcwd

from dynamo.defs import DynamoTarget
from dynamo.utils import safe_ceiled_division

helper_code = """
// dynamo210 beat/light sync GLSL function generator by QM (April 2021, corona fuck yeah)
// usage: get current beat by
// float b =_beat(iTime);
// depending on the nature of stuff, you might need a constant offset like iTime - 0.05, idk
// then call your curve functions with argument b

float smstep(float a, float b, float x) {return smoothstep(a, b, clamp(x, a, b));}
float theta(float x) { return smstep(0.,1e-3,x); }
"""


class DynamoWriter:

    def __init__(self, parent):
        self.args = parent.args
        self.def_blocks = parent.def_blocks
        self.target = parent.target
        self.name = parent.config_name

    def write(self, bpm_code, def_code):
        match self.target:
            case DynamoTarget.GLSL:
                return self._write_to_glsl(bpm_code, def_code)
            case DynamoTarget.Rust:
                raise Exception("SOMEONE didn't implement the writing to Rust yet")
            case DynamoTarget.Alki:
                return self._write_to_alki()
            case _:
                raise Exception(f"Target Format not given/defined: {self.target}")

    def _write_to_glsl(self, bpm_code, def_code):
        out_file = Path(getcwd()) / f"{self.name}.glsl"
        with open(out_file, 'w') as file:
            file.write(helper_code)
            file.write(bpm_code)
            if def_code is not None:
                file.write(def_code)
        print("Written:", out_file)

        open_file = self.args.print or self.args.clip
        if open_file:
            content = open(out_file, 'r').read()
            if self.args.print:
                print("=== Content:")
                print(content)
            if self.args.clip:
                pyperclip.copy(content)
                print("Copied to Clipboard.")

    def _write_to_alki(self):
        track_map = self.create_track_map(self.def_blocks)
        info = {
            'n_tracks': len(track_map),
            'tracks': [],
            'patterns': {},
        }
        pattern_start_offset = 0
        for track_number, track_patterns in track_map.items():
            track_info = {
                'n_patterns': len(track_patterns),
                'patterns': []
            }
            for pattern in track_patterns:
                mapper, shape_id = self.get_alki_mapping(pattern['shape'])
                pattern_length = pattern['repeat'] if pattern['repeat'] > 0 else pattern['end'] - pattern['start']
                pattern_events = self.get_events_from_pattern(pattern)
                pattern_id = pattern.get('src', pattern['name'])
                pattern_info = {
                    'shape_id': shape_id,
                    'start_beat': pattern['start'],
                    'end_beat': pattern['end'],
                    'length_in_beats': pattern_length,
                    'pattern_id': pattern_id
                }
                track_info['patterns'].append(pattern_info)
                if pattern_id not in info['patterns']:
                    info['patterns'][pattern_id] = {
                        'events': list(map(mapper, pattern_events)),
                        'start_offset': pattern_start_offset
                    }
                    pattern_start_offset += len(pattern_events)

            info['tracks'].append(track_info)

        '''
        structure is as follows:
        
        * 1 item:
            number of tracks
        * 2 items for each track:
            start index for pattern details of this track
            number of patterns in this track
        * 6 items for each track pattern details:
            start index for this pattern
            number of events in this pattern
            id for what shape these events have, e.g. exponential decay, etc.
                (note: shader must interpret these, it must also know the correct number of parameters for each shape!)
            start beat for this pattern in this track
            end beat for this pattern in this track
            length of this pattern in beats (e.g. repeat events after this amount of beats each)
        * then all the patterns in their individual length:
            <first pattern, first event: beat / when to play>
            <first pattern, first event: velocity>
            <first pattern, first event: ... more parameters depending on the shape>
            ...
            <first pattern, last event: last parameter>
            <second pattern, first event: beat / when to play>
            ...
            <last pattern, last event: last parameter>
        '''

        result = [
            info['n_tracks'],
        ]
        track_header_size = 2
        pattern_header_size = 6

        cursor = len(result) + info['n_tracks'] * track_header_size

        for track_info in info['tracks']:
            result.extend([
                cursor,
                track_info['n_patterns']
            ])
            cursor += track_info['n_patterns'] * pattern_header_size

        for track_info in info['tracks']:
            for pattern_info in track_info['patterns']:
                pattern = info['patterns'][pattern_info['pattern_id']]
                print("yop", pattern_info, pattern)
                result.extend([
                    cursor + pattern['start_offset'],
                    len(pattern['events']),
                    pattern_info['shape_id'],
                    pattern_info['start_beat'],
                    pattern_info['end_beat'],
                    pattern_info['length_in_beats'],
                ])

        for pattern in info['patterns'].values():
            for event in pattern['events']:
                result.extend(event)

        print("result", result)

        out_file = Path(getcwd()) / f"{self.name}.alkisync"
        result_struct = struct.pack('f' * len(result), *result)
        with open(out_file, 'wb') as f:
            f.write(result_struct)
        print("Written:", out_file, f"(number of elements {len(result)})")

    @staticmethod
    def get_alki_mapping(shape):
        match shape:
            case "expeak":
                mapper = lambda e: [e['beat'], e['level'], e['attack'], e['decay']]
                shape_id = 0
            case "smoof":
                mapper = lambda e: [e['beat'], e['level']]
                shape_id = 1
            case "peak":
                mapper = lambda e: [e['beat'], e['level'], e['attack'], e['decay']]
                shape_id = 2
            case _:
                raise KeyError("this track shape is not a registered ALKI shape ID: " + shape)
        return mapper, shape_id

    @staticmethod
    def get_events_from_pattern(pattern):
        events = []
        for step in pattern['table']:
            step_repetitions = safe_ceiled_division(pattern['repeat'], step['repeat'])
            for s in range(step_repetitions):
                beat = step['beat'] + s * step['repeat']
                events.append({**step, 'beat': beat})
        return events

    @staticmethod
    def create_track_map(def_blocks):
        track_map = {}
        for block in def_blocks:
            tracks = block['track'].split(',') if isinstance(block['track'], str) else [str(block['track'])]
            for track in tracks:
                try:
                    track_map[track].append(block)
                except KeyError:
                    track_map[track] = [block]

        for track_list in track_map.values():
            track_list.sort(key=lambda t: t['start'])

        return track_map

    def print_cumuls(self, var):
        cumuls = {}
        for block in self.def_blocks:
            cumul = block.get('cumul')
            if cumul is None:
                continue
            if cumul not in cumuls:
                cumuls[cumul] = []
            cumuls[cumul].append(f"{block['name']}({var})")

        print()
        print(f"float {var} = _beat(iTime);")
        for cumul in cumuls:
            cumulated = '+'.join(cumuls[cumul])
            print(f"float {cumul} = clamp({cumulated},0.,1.);")