
// dynamo210 beat/light sync GLSL function generator by QM (April 2021, corona fuck yeah)
// usage: get current beat by
// float B =_beat(iTime);
// depending on the nature of stuff, you might need a constant offset like iTime - 0.05, idk
// then call your curve functions with argument B

float smstep(float a, float b, float x) {return smoothstep(a, b, clamp(x, a, b));}
float theta(float x) { return smstep(0.,1e-3,x); }
float _t_[2] = float[2](0.,8.062);
float _b_[2] = float[2](0.,16.);
float _fac_[2] = float[2](24.421,2.526); // fac is bps for flat segments, else... something else.
float _slope_[2] = float[2](0.063,0.);
float _beat(float t)
{
    int it; for(it = 0; it < 1 && _t_[it + 1] < t; it++);
    if (_slope_[it] == 0.) return _b_[it] + (t - _t_[it]) * _fac_[it];
    return _b_[it] + _fac_[it] * (exp(_slope_[it]*(t - _t_[it])) - 1.);
}
float FOUR_ON_FLOOR(float b)
{
    float r = 0.;
    r += 0.998 * pow(mod(b, 1.0), 0.) * exp(-0.200*mod(b, 1.0));
    return r * theta(b);
}