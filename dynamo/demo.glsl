
// dynamo210 beat/light sync GLSL function generator by QM (April 2021, corona fuck yeah)
// usage: get current beat by
// float B =_beat(iTime);
// then call your curve functions with argument B

float smstep(float a, float b, float x) {return smoothstep(a, b, clamp(x, a, b));}
float theta(float x) { return smstep(0.,1e-3,x); }
float _t_[2] = float[2](0.,15.731);
float _b_[2] = float[2](0.,32.);
float _fac_[2] = float[2](2.622,2.228);
float _slope_[2] = float[2](0.706,0.);
float _beat(float t)
{
    int it; for(it = 0; it < 0 && _t_[it + 1] < t; it++);
    if (_slope_[it] == 0.) return _b_[it] + (t - _t_[it]) * _fac_[it];
    return _b_[it] + _fac_[it] * (exp(_slope_[it]*(t - _t_[it])) - 1.);
}
float FOUR_ON_FLOOR(float b)
{
    float r = 0.;
    r += 0.991 * pow(b, 0.001) * exp(-1.154*b);
    return r * theta(b);
}