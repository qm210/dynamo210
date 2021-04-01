
// dynamo210 beat/light sync GLSL function generator by QM (April 2021, corona fuck yeah)
// usage: get current beat by
// float B =_beat(iTime);
// depending on the nature of stuff, you might need a constant offset like iTime - 0.05, idk
// then call your curve functions with argument B

float smstep(float a, float b, float x) {return smoothstep(a, b, clamp(x, a, b));}
float theta(float x) { return smstep(0.,1e-3,x); }
float _t_[2] = float[2](0.,17.282);
float _b_[2] = float[2](0.,32.);
float _fac_[2] = float[2](1.852,2.228); // fac is bps for flat segments, else... something else.
float _slope_[2] = float[2](0.,0.);
float _beat(float t)
{
    int it; for(it = 0; it < 1 && _t_[it + 1] < t; it++);
    if (_slope_[it] == 0.) return _b_[it] + (t - _t_[it]) * _fac_[it];
    return _b_[it] + _fac_[it] * (exp(_slope_[it]*(t - _t_[it])) - 1.);
}
float FOUR_ON_FLOOR(float b)
{
    float r = 0.;
    r += 0.991 * pow(mod(b, 1.0), 0.001) * exp(-1.154*mod(b, 1.0));
    return r * theta(b);
}