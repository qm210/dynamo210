import argparse
from .utils import type_adjusted_args

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


    def run(self):
        self.parse_lines_to_blocks()
        spb_code = self.parse_bpm_to_spb_function()
        def_code = self.parse_defs_to_curves()


    @staticmethod
    def new_block(cmd, parsed_line):
        block = {'cmd': cmd, 'content': []}
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
                print("BL", block)

            else:
                print("we here", cmd, block)
                block['content'].append(parsed_line)

            self.close_block(block)


    def close_block(self, block):
        if block is None:
            return
        if block['cmd'] == 'bpm':
            self.bpm_block = block
        else:
            self.def_blocks.append(block)


    def parse_bpm_to_spb_function(self):
        if self.bpm_block is None:
            print("no BPM block defined.")
            return

        print(self.bpm_block)


    def parse_defs_to_curves(self):
        for block in self.def_blocks:
            print(block)


if __name__ == '__main__':
    Dynamo.main()