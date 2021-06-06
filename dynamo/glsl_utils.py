
FLOAT_PREC = 4

def to_glsl(value):
    result = str(value)
    if type(value) == float:
        result = f"{value:.{FLOAT_PREC}f}"
        if result.count('.') == 0:
            return result + '.'
        result = result.strip('0')
        if result == '.':
            return '0.'
    return result
