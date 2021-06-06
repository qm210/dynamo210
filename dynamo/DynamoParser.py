import math
from enum import Enum
from .utils import type_adjusted_args, this_and_next_element
from .glsl_utils import to_glsl

LF4 = '\n' + 4 * ' '

class TARGET(Enum):
    GLSL = 0
    RUST = 1


class DynamoParser:

    def __init__(self):
        self.bpm_block = None
        self.def_blocks = []

        self.bpm_curve = None
        self.def_curves = []

        self.target = TARGET.GLSL


    def parse_lines_to_blocks(self):
        block = None
        for line in self.content:
            parsed_line = line.split()
            if len(parsed_line) == 0 or line[0] == '#':
                continue

            cmd = parsed_line[0].lower()

            if cmd in ['bpm', 'def', 'copy']:
                self.close_block(block)
                block = DynamoParser.new_block(cmd, parsed_line)

            else:
                block['content'].append(parsed_line)

        self.close_block(block)


    @staticmethod
    def new_block(cmd, parsed_line = []):
        block = {'cmd': cmd, 'content': []}
        if len(parsed_line) == 0:
            return block
        args = {}
        header = parsed_line[1:]
        if cmd == 'def':
            block['name'] = header.pop(0)
        elif cmd == 'copy':
            block['src'] = header.pop(0)
            block['name'] = header.pop(0)
        args = type_adjusted_args(header)
        return {**block, **args}


    @staticmethod
    def calc(term):
        result = 0
        for summand in term.split('+'):
            first_factor = True
            for factor in summand.split('*'):
                try:
                    num, den = factor.split('/')
                    part = float(num)/float(den)
                except ValueError:
                    part = float(factor)
                product = part if first_factor else part * product
                first_factor = False
            result += product
        return result


    def close_block(self, block):
        if block is None:
            return
        if block['cmd'] == 'bpm':
            self.bpm_block = block
        else:
            self.def_blocks.append(block)


    def def_content(self, line):
        beat = DynamoParser.calc(line.pop(0))
        level = float(line.pop(0)) if len(line) > 0 and not "=" in line[0] else None
        args = type_adjusted_args(line, dtype=float)
        if level is None:
            level = args.get('level', 1.)
        return {'beat': beat, 'level': level, **args}

    def def_term_single(self, block, line, nextline=None, var='b'):
        shape = line.get('shape', block['shape'])
        level = line.get('level', 1.)
        line.setdefault('attack', block.get('attack', 0.01))
        line.setdefault('decay', block.get('decay', 0.25))
        line.setdefault('repeat', 0.)
        # insert here for more DEF LINE arguments

        if line['beat'] != 0:
            var = f"({var}-{to_glsl(line['beat'] / block['scale'])})"

        if line['repeat'] != 0:
            var = f"mod({var}, {line['repeat']})"

        attack_glsl = to_glsl(line['attack'])
        level_factor = to_glsl(level) + '*' if level != 1. else ''

        if shape == 'peak':
            result = f"theta({var}) * (2.*smstep(-{attack_glsl}, {attack_glsl}, {var})-1.)" + \
                f"*(1.-smstep(0., {to_glsl(line['decay'])}, {var}-{attack_glsl}))"

        elif shape == 'step':
            result = f"smstep(0., {attack_glsl}, {var})"

        elif shape == 'expeak':
            beta = math.log(2) / float(line['decay'])
            alpha = float(line['attack']) * beta
            norm = math.pow(alpha/(beta*math.e), alpha)
            result = f"{to_glsl(norm)} * pow({var}, {to_glsl(alpha)}) * exp(-{to_glsl(beta)}*{var})"

        else:
            return f"0. /* {block['name']}: shape {shape} unknown */"

        return level_factor + result


    def def_term_interval(self, block, line, nextline, var='b'):
        shape = line.get('shape', block['shape'])
        level = line.get('level', 1.)
        # insert here for more DEF LINE arguments for interval shapes

        beat_start = line['beat'] / block['scale']
        beat_end = nextline['beat'] / block['scale']

        next_level = nextline.get('level', 1.)

        if shape == 'smoof':
            # smstep does also clamping, but is mix(a,b,x) working for b < a?
            transition = f"smstep({to_glsl(beat_start)}, {to_glsl(beat_end)}, {var})"

            power = int(line.get('power', 1))
            if power > 1:
                transition = "*".join([transition] * power)

            result = f"mix({to_glsl(level)}, {to_glsl(next_level)}, {transition})"


        else:
            return f"0. /* {block['name']}: shape {shape} unknown */"

        return f"({var} <= {to_glsl(beat_end)}) ? {result} : "


    def parse_bpm_to_glsl(self):
        if self.bpm_block is None:
            quit("No BPM block defined. Can't work with shit.")

        self.bpm_block.setdefault('beats', 4)
        self.bpm_block.setdefault('first', 0.)

        def parse_bpm_line(line):
            args = type_adjusted_args(line[2:], dtype=float)
            beat = DynamoParser.calc(line[0])

            return {
                'beat': max(0, beat - self.bpm_block['first']),
                'bpm': float(line[1]) / self.bpm_block['beats'],
                **args
            }

        self.bpm_block['content'] = list(map(parse_bpm_line, self.bpm_block['content']))

        print("BPM", self.bpm_block)

        # we have a problem if the bpm list doesnt start with 0 / the "first" value. just make it start with 0.
        current_minute = 0.
        beat_table = [{'time': current_minute, 'beat': 0.}]

        for start, end in this_and_next_element(self.bpm_block['content']):
            b_start = start['beat']
            b_end = end['beat']
            if 'slope' in start:
                slope = start['slope']
            else:
                slope = (end['bpm'] - start['bpm']) / (b_end - b_start)
            flat_time = (b_end - b_start) / start['bpm']

            if slope == 0:
                current_minute += flat_time
                beat_factor = start['bpm'] / 60.
            else:
                current_minute += math.log((slope * flat_time + 1)) / slope
                beat_factor = start['bpm'] / slope

            beat_table[-1]['slope'] = slope / 60
            beat_table[-1]['factor'] = beat_factor
            beat_table.append({'time': current_minute, 'beat': end['beat']})

            b_start = to_glsl(b_start)
            b_end = to_glsl(b_end)
            slope = to_glsl(slope)

        beat_table[-1]['slope'] = 0.0
        beat_table[-1]['factor'] = end['bpm'] / 60.
        N = len(beat_table)

        def get_floatarray(name, selector):
            array = []
            for step in beat_table:
                array.append(selector(step))
            return f"float {name}[{N}] = float[{N}]({','.join(array)});"

        array_t = get_floatarray('_t_', lambda step: to_glsl(60 * step['time']))
        array_b = get_floatarray('_b_', lambda step: to_glsl(step['beat']))
        array_fac = get_floatarray('_fac_', lambda step: to_glsl(step['factor']))
        array_slope = get_floatarray('_slope_', lambda step: to_glsl(step['slope']))

        function = 'float _beat(float t)\n{' + LF4
        function += f"int it; for(it = 0; it < {N - 1} && _t_[it + 1] < t; it++);" + LF4
        function += "if (_slope_[it] == 0.) return _b_[it] + (t - _t_[it]) * _fac_[it];" + LF4
        function += "return _b_[it] + _fac_[it] * (exp(_slope_[it]*(t - _t_[it])) - 1.);"
        function += "\n}\n"

        return "\n".join([array_t, array_b, array_fac, array_slope, function])

    def parse_def_to_curve(self, block):
        block.setdefault('shape', 'expeak')
        block.setdefault('start', 0.)
        block.setdefault('end', 0.)
        block.setdefault('repeat', 0.)
        block.setdefault('default', 0.)
        block.setdefault('scale', 1.)
        block.setdefault('attack', 0.01)
        block.setdefault('decay', 0.25)
        # insert here for more DEF HEADER arguments

        table = list(map(self.def_content, block['content']))
        is_interval_block = block['shape'] == 'smoof'
        if is_interval_block and len(table) > 0:
            block['default'] = table[-1]['level']

        block_start = float(block['start']) - self.bpm_block['first']
        block_length = float(block['end']) - float(block['start'])

        function = f"float {block['name']}(float b)\n{{" + LF4

        function += f"float r = {to_glsl(float(block['default']))};" + LF4

        if block_start > 0:
            function += f"b -= {to_glsl(block_start)};" + LF4

        function += "if (b<0.) return r;" + LF4

        if block_length > 0:
            function += f"if (b>{to_glsl(block_length)}) return r;" + LF4

        if block['repeat'] > 0:
            function += f"b = mod(b, {to_glsl(float(block['repeat']))});" + LF4

        if is_interval_block:
            function += 'return '
            for line, nextline in this_and_next_element(table):
                # interval terms are chains of "condition ? result : "
                function += self.def_term_interval(block, line, nextline)
            function += 'r;'

        else:
            for line in table:
                # single terms are contributing each on their own, i.e. all superimposed
                term = self.def_term_single(block, line)
                function += 'r += ' + term + ';' + LF4
            function += f"return r * theta(b);"

        return function + '\n}'

    def process_def_copies(self, block):
        try:
            original = next((it for it in self.def_blocks if it['name'] == block['src']))
        except StopIteration:
            print("copy", block['name'], "requires definition of", block['src'], "-- but found none.")
            return ''

        shift = float(block['start']) - float(original['start'])
        return f"float {block['name']}(float b) {{return {block['src']}(b-{to_glsl(shift)});}}"

    def parse_defs_to_curves(self):
        def_codes = [self.parse_def_to_curve(block) for block in self.def_blocks if block['cmd'] == 'def']
        copy_codes = [self.process_def_copies(block) for block in self.def_blocks if block['cmd'] == 'copy']
        return '\n'.join([*def_codes, *copy_codes])
