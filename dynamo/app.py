import argparse
import math
from .utils import type_adjusted_args, this_and_next_element

LF4 = '\n' + 4 * ' '

class Dynamo:

    @staticmethod
    def main():
        app = Dynamo(argparse.ArgumentParser())
        app.run()

    def __init__(self, parser):
        parser.add_argument("config")
        self.args = parser.parse_args()

        config_file = f"dynamo/config/{self.args.config}.dnm"
        try:
            with open(config_file, 'r') as file:
                self.content = file.readlines()
        except FileNotFoundError:
            print("No such config file:", config_file)
            quit()

        self.bpm_block = None
        self.def_blocks = []

        self.bpm_curve = None
        self.def_curves = []


    def run(self):
        self.parse_lines_to_blocks()
        bpm_code = self.parse_bpm_to_glsl()
        def_code = self.parse_defs_to_curves()

        self.write_to_glsl(bpm_code, def_code)


    @staticmethod
    def new_block(cmd, parsed_line = []):
        block = {'cmd': cmd, 'content': []}
        if len(parsed_line) == 0:
            return block
        args = {}
        header = parsed_line[1:]
        if cmd == 'def':
            block['name'] = header.pop(0)
        args = type_adjusted_args(header)
        return {**block, **args}

    def parse_lines_to_blocks(self):
        block = None
        for line in self.content:
            parsed_line = line.split()
            if len(parsed_line) == 0 or line[0] == '#':
                continue

            cmd = parsed_line[0].lower()

            if cmd == 'bpm' or cmd == 'def':
                self.close_block(block)
                block = Dynamo.new_block(cmd, parsed_line)

            else:
                block['content'].append(parsed_line)

        self.close_block(block)


    def close_block(self, block):
        if block is None:
            return
        if block['cmd'] == 'bpm':
            self.bpm_block = block
        else:
            self.def_blocks.append(block)


    def parse_bpm_to_glsl(self):
        if self.bpm_block is None:
            quit("No BPM block defined. Can't work with shit.")

        self.bpm_block.setdefault('beats', 4)

        parse_bpm_content = lambda c: {
            'beat': float(c[0]) * self.bpm_block['beats'],
            'bpm': float(c[1])
        }

        self.bpm_block['content'] = list(map(parse_bpm_content, self.bpm_block['content']))

        def to_glsl(value):
            result = str(value)
            if type(value) == float:
                result = f"{value:.3f}"
                if result.count('.') == 0:
                    return result + '.'
                if result[-4:] == '.000':
                    return result[:-3]
            return result

        print('BPM block', self.bpm_block)

        # we have a problem if the bpm list doesnt start with 0. just make it start with 0.
        current_minute = 0.
        beat_table = [{'time': current_minute, 'beat': 0.}]

        for start, end in this_and_next_element(self.bpm_block['content']):
            b_start = start['beat']
            b_end = end['beat']
            slope = (end['bpm'] - start['bpm']) / (b_end - b_start)
            offset = start['bpm'] - slope * b_start
            flat_time = (b_end - b_start) / start['bpm']

            if slope == 0:
                current_minute += flat_time
                beat_factor = start['bpm']
            else:
                current_minute += math.log((slope * flat_time + 1)) / slope
                beat_factor = start['bpm'] / slope

            beat_table[-1]['slope'] = slope
            beat_table[-1]['factor'] = beat_factor
            beat_table.append({'time': current_minute, 'beat': end['beat']})

            b_start = to_glsl(b_start)
            b_end = to_glsl(b_end)
            slope = to_glsl(slope)
            offset = to_glsl(offset)

        beat_table[-1]['slope'] = 0.0
        beat_table[-1]['factor'] = end['bpm']
        N = len(beat_table)

        def get_floatarray(name, selector):
            array = []
            for step in beat_table:
                array.append(selector(step))
            return f"float {name}[{N}] = float[{N}]({','.join(array)});"

        array_t = get_floatarray('_t_', lambda step: to_glsl(60 * step['time']))
        array_b = get_floatarray('_b_', lambda step: to_glsl(step['beat']))
        array_fac = get_floatarray('_fac_', lambda step: to_glsl(step['factor']/60.))
        array_slope = get_floatarray('_slope_', lambda step: to_glsl(step['slope']))

        # function_body = function_body + f"if (t < {}) b += log({slope} * min(b, {b_end}) + {offset})" + LF4
        function = 'float _beat(float t)\n{' + LF4
        function += f"int it; for(it = 0; it < {N - 2} && _t_[it + 1] < t; it++);" + LF4
        function += "if (_slope_[it] == 0.) return _b_[it] + (t - _t_[it]) * _fac_[it];" + LF4
        function += "return _b_[it] + _fac_[it] * (exp(_slope_[it]*(t - _t_[it])) - 1.);"
        function += "\n}\n"

        return "\n".join([array_t, array_b, array_fac, array_slope, function])

    def parse_defs_to_curves(self):
        print()
        print(self.def_blocks)
        # for block in self.def_blocks:
            # print(block)

    def write_to_glsl(self, bpm_code, def_code):
        with open(f"dynamo/{self.args.config}.glsl", 'w') as file:
            file.write(bpm_code)
            if def_code is not None:
                file.write(def_code)

if __name__ == '__main__':
    Dynamo.main()