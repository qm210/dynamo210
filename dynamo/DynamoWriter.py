import pyperclip

from dynamo.app import DynamoTarget

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
        self.out_file = f"dynamo/{parent.args.config}.glsl"
        self.args = parent.args
        self.def_blocks = parent.def_blocks
        self.target = parent.target

    def write(self, bpm_code, def_code):
        match self.target:
            case DynamoTarget.GLSL:
                return self._write_to_glsl(bpm_code, def_code)
            case DynamoTarget.Rust:
                raise Exception("SOMEONE didn't implement the writing to Rust yet")
            case DynamoTarget.Alki:
                return self._write_to_alki(bpm_code, def_code)
            case _:
                raise Exception(f"Target Format not given/defined: {self.target}")

    def _write_to_glsl(self, bpm_code, def_code):
        with open(self.out_file, 'w') as file:
            file.write(helper_code)
            file.write(bpm_code)
            if def_code is not None:
                file.write(def_code)
        print("Written:", self.out_file)

        open_file = self.args.print or self.args.clip
        if open_file:
            content = open(self.out_file, 'r').read()
            if self.args.print:
                print("=== Content:")
                print(content)
            if self.args.clip:
                pyperclip.copy(content)
                print("Copied to Clipboard.")

    def _write_to_alki(self, bpm_code, def_code):
        print("Would write to alki", bpm_code, def_code)

    def print_cumuls(self, var):
        LF = '\n'
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