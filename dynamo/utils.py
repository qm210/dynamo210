def type_adjusted_args(list, dtype=None):
    result = {}
    for elem in list:
        key, value = elem.split('=')
        if dtype is not None:
            value = dtype(value)
        result[key] = type_adjusted_value(value)
    return result

def type_adjusted_value(value):
    try:
        if str(int(value)) == value:
            return int(value)
    except ValueError:
        pass
    try:
        if str(float(value)) == value:
            return float(value)
    except ValueError:
        pass
    return value

def this_and_next_element(list):
    return zip(list, list[1:])