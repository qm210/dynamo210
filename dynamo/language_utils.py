
FLOAT_PREC = 4


# GLSL UTILS

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


# RUST UTILS

def to_f32(value):
    result = str(value)
    if type(value) == float:
        result = f"{value:.{FLOAT_PREC}f}"
        if result.count('.') == 0:
            return result + '.'
        result = result.strip('0')
        if result[0] == '.':
            result = '0' + result
    return result
