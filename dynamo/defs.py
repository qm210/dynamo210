from enum import Enum


class DynamoTarget(Enum):
    GLSL = 0,
    Rust = 1,
    Alki = 2,


LF4 = '\n' + 4 * ' '
