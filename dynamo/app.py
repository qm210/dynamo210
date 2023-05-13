import argparse

from dynamo.defs import DynamoTarget
from .DynamoParser import DynamoParser
from .DynamoWriter import DynamoWriter


class Dynamo(DynamoParser):

    @staticmethod
    def main():
        app = Dynamo(argparse.ArgumentParser())
        app.run()

    def __init__(self, parser):
        parser.add_argument("config")
        parser.add_argument("--print", action="store_true")
        parser.add_argument("--clip", action="store_true")
        parser.add_argument("--rust", action="store_true")
        parser.add_argument("--alki", action="store_true")
        self.args = parser.parse_args()

        self.config_file = self.args.config.replace('\\', '/')
        if self.config_file.count('/') == 0:
            self.config_file = f"dynamo/config/{self.config_file}.dnm"
        self.config_name = self.config_file.split('/')[-1].split('.')[0]

        target = DynamoTarget.Rust if self.args.rust \
            else DynamoTarget.Alki if self.args.alki \
            else DynamoTarget.GLSL

        super().__init__(target=target)

        try:
            with open(self.config_file, 'r') as file:
                self.content = file.readlines()
        except FileNotFoundError:
            print("No such config file:", self.config_file)
            quit()

    def run(self):
        self.parse_lines_to_blocks()
        bpm_code = self.parse_bpm_to_code()
        def_code = self.parse_defs_to_curves()

        writer = DynamoWriter(self)
        writer.write(bpm_code, def_code)
        writer.print_cumuls('b')


if __name__ == '__main__':
    Dynamo.main()
